# modules/containers/nextcloud.nix
{
  delib,
  config,
  inputs,
  pkgs,
  ...
}:
delib.module {
  name = "containers.nextcloud";

  options = delib.singleCascadeEnableOption;

  # quadlet-nixのモジュール自体はenable=falseでも読み込んでおいて問題ない
  # (オプションを増やすだけで何も有効化しない)。containers.nextcloud.enableに
  # 条件付けたいのはそれを使う側のvirtualisation.quadlet.*設定の方なので、
  # そちらはnixos.ifEnabled側に残す。
  nixos.always.imports = [ inputs.quadlet-nix.nixosModules.default ];

  nixos.ifEnabled =
    let
      # tank (旧 TrueNAS では data_pool という名前だったプール) 側の実データ
      # 置き場。TrueNAS 側の既存レイアウト (/mnt/data_pool/nextcloud) と
      # 同じ相対構造に揃えてある (zpool import 時に tank へ改名する想定)。
      # TrueNAS の慣習 (/mnt/<pool>/...) を引きずらないこと。plainasia では
      # tank データセットの mountpoint プロパティがそのまま /tank/... になっている。
      dataDir = "/tank/nextcloud";
      # cloudflared.nix の drive.melocy.cc ingress が指してるポートに合わせてある。
      httpPort = 22300;
      trustedDomains = "127.0.0.1 localhost nextcloud drive.melocy.cc";

      ncUser = config.users.users.nextcloud;
      uidStr = toString ncUser.uid;
      podman = config.virtualisation.podman.package;
      # Pinned so Apache's peer address (see trusted_proxies) is predictable.
      networkSubnet = "10.89.77.0/24";
      networkGateway = "10.89.77.1";
      # Fixed by the images: Debian's www-data and the postgres image's postgres user.
      wwwDataId = 33;
      postgresId = 999;

      secretPath = name: config.sops.secrets."nextcloud/${name}".path;
      # Per-start copies under $XDG_RUNTIME_DIR (see nextcloud-secrets below).
      stagedSecret = name: "%t/nextcloud-secrets/${name}";

      # 旧 TrueNAS 側では postgres コンテナ自身のブートストラップ用スーパーユーザー
      # (nextcloud) と、Nextcloud アプリ本体が実際に使う権限を絞ったロール
      # (oc_admin、CREATEDB のみ) が分かれていた。同じ構成に合わせる。
      # Plain .sql, since the image has no /nix/store for a shebang. The server
      # reads the secret itself, so an empty or unreadable file aborts the init
      # instead of creating a passwordless role (a failed init is never retried:
      # wipe the postgres dir). PostgreSQL 15+ no longer lets ordinary roles
      # create in public, hence the schema grant.
      initOcAdminRole = pkgs.writeText "init-oc-admin-role.sql" ''
        DO $$
        DECLARE
          pw text := rtrim(pg_read_file('/run/secrets/oc-admin-password'), E'\n');
        BEGIN
          IF length(pw) = 0 THEN
            RAISE EXCEPTION 'oc-admin-password is empty';
          END IF;
          IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'oc_admin') THEN
            EXECUTE format('CREATE ROLE oc_admin WITH LOGIN CREATEDB PASSWORD %L', pw);
          END IF;
          EXECUTE format('GRANT ALL PRIVILEGES ON DATABASE %I TO oc_admin', current_database());
          GRANT ALL ON SCHEMA public TO oc_admin;
        END
        $$;
      '';

      # sops files are owned by the host user, which is container root. Files that
      # www-data or postgres must read are copied to tmpfs and chowned to that
      # container uid; container root still reads them via CAP_DAC_OVERRIDE.
      prepareSecrets = pkgs.writeShellScript "nextcloud-prepare-secrets" ''
        set -eu
        dst="$XDG_RUNTIME_DIR/nextcloud-secrets"
        install -d -m 0700 "$dst"
        stage() {
          rm -f "$dst/$1"
          install -m 0400 "$2" "$dst/$1"
          [ "$3" = 0 ] || podman unshare chown "$3:$3" "$dst/$1"
        }
        stage postgres-password ${secretPath "postgres-password"} 0
        stage admin-password ${secretPath "admin-password"} 0
        stage oc-admin-password ${secretPath "oc-admin-password"} ${toString postgresId}
        stage redis-password ${secretPath "redis-password"} ${toString wwwDataId}
      '';

      # Container uid N>0 is the host user's subuid start + N - 1, and the start
      # is allocated per machine (/var/lib/nixos/auto-subuid-map), so derive it.
      fixOwnership = pkgs.writeShellScript "nextcloud-fix-ownership" ''
        set -eu
        subid() { awk -F: '$1 == "${ncUser.name}" { print $2; exit }' "$1"; }
        sub_uid=$(subid /etc/subuid)
        sub_gid=$(subid /etc/subgid)
        [ -n "$sub_uid" ] && [ -n "$sub_gid" ] || { echo "no subuid range for ${ncUser.name}" >&2; exit 1; }
        fix() {
          find "$1" -xdev \( -not -uid "$2" -o -not -gid "$3" \) -exec chown -h "$2:$3" {} +
        }
        www_uid=$((sub_uid + ${toString wwwDataId} - 1))
        www_gid=$((sub_gid + ${toString wwwDataId} - 1))
        pg_uid=$((sub_uid + ${toString postgresId} - 1))
        pg_gid=$((sub_gid + ${toString postgresId} - 1))
        fix ${dataDir}/appdata "$www_uid" "$www_gid"
        fix ${dataDir}/userdata "$www_uid" "$www_gid"
        fix ${dataDir}/postgres "$pg_uid" "$pg_gid"
      '';

      # 公式イメージの環境変数で賄えない設定分。config.php の元バックアップから
      # 移した (maintenance/secret/instanceid/passwordsalt/dbpassword のような、
      # 状態そのものか実データ移行時にしか意味を持たない値は含めていない)。
      extraConfigPhp = pkgs.writeText "nextcloud-extra.config.php" ''
        <?php
        $CONFIG = [
          'memcache.local' => '\OC\Memcache\APCu',
          'memcache.distributed' => '\OC\Memcache\Redis',
          'memcache.locking' => '\OC\Memcache\Redis',
          'upgrade.disable-web' => true,
          'overwriteprotocol' => 'https',
          'overwrite.cli.url' => 'https://drive.melocy.cc',
          # cloudflaredはこのホスト上で127.0.0.1:httpPortへローカル接続するだけの
          # リバースプロキシなので、trusted_proxiesを設定しないとNextcloudは
          # 全リクエストのREMOTE_ADDRを127.0.0.1だと認識してしまう(ブルート
          # フォース防御のIPごとのカウントやログイン履歴のIPが意味を失う)。
          # Cloudflareのエッジが実クライアントIPをCF-Connecting-IPに入れて
          # くれるので、ループバックからの接続だけそのヘッダーを信頼させて
          # 復元する。
          # Behind rootlessport, Apache's peer is the container's own address on
          # the nextcloud network, not 127.0.0.1.
          'trusted_proxies' => ['127.0.0.1', '::1', '${networkSubnet}'],
          'forwarded_for_headers' => ['HTTP_CF_CONNECTING_IP'],
          'dbtableprefix' => 'oc_',
          'skeletondirectory' => "",
          'preview_max_filesize_image' => -1,
          'preview_max_memory' => 1024,
          'preview_imaginary_url' => 'http://nextcloud-imaginary:9000',
          # 公式イメージにffmpegが同梱されていないため、OC\Preview\Movieが
          # 動作しない。カスタムイメージをビルドする代わりに、ホストの
          # /nix/storeをコンテナへ読み取り専用でbind mountして (下のvolumes参照)、
          # Nixが既にビルド済みのffmpegを絶対パスで直接指定する。
          'preview_ffmpeg_path' => '${pkgs.ffmpeg-headless}/bin/ffmpeg',
          'enabledPreviewProviders' => [
            'OC\Preview\PNG',
            'OC\Preview\JPEG',
            'OC\Preview\GIF',
            'OC\Preview\BMP',
            'OC\Preview\XBitmap',
            'OC\Preview\MarkDown',
            'OC\Preview\MP3',
            'OC\Preview\OpenDocument',
            'OC\Preview\TXT',
            'OC\Preview\Krita',
            'OC\Preview\Movie',
            'OC\Preview\Imaginary',
            'OC\Preview\ImaginaryPDF',
            'OC\Preview\HEIC',
            'OCA\CameraRawPreviews\Provider',
          ],
          'user_oidc' => [
            'auto_provision' => true,
            'soft_auto_provision' => true,
            'disable_account_creation' => true,
          ],
        ];
      '';

      # PHP_MEMORY_LIMIT/PHP_UPLOAD_LIMIT は公式イメージの環境変数で賄えるが、
      # max_execution_time や opcache 系は無いので php.ini の追加ファイルとして
      # 直接置く (php:apache ベースなので conf.d/*.ini が読まれる)。
      extraPhpIni = pkgs.writeText "nextcloud-extra.ini" ''
        max_execution_time = 3600
        opcache.interned_strings_buffer = 32
        opcache.memory_consumption = 128
      '';
    in
    {
      # quadlet-nix: ユニットファイルはビルド時にpodman-system-generatorを
      # 実際に走らせて生成される (oci-containers + dockerCompatの薄いpython層を
      # 経由しない)。生成されるsystemd unit名はoci-containers時代の
      # `podman-<name>.service`ではなく、属性名そのまま`<name>.service`になる
      # 点に注意 (下の各systemd.services.*の参照先もそれに追従済み)。

      # containers.enable が false な間はこのモジュール自体が評価されないので、
      # secret.yaml 側にまだキーが無くてもビルドは壊れない。sopsFile は
      # modules/sops.nix の defaultSopsFile (secret.yaml) をそのまま使う。
      # Owned by the rootless user so nextcloud-secrets can stage them. Changing a
      # secret does not restart the containers; restart nextcloud-secrets (user
      # unit) afterwards, which restarts everything that requires it.
      sops.secrets =
        let
          owned = {
            owner = ncUser.name;
            mode = "0400";
          };
        in
        {
          "nextcloud/postgres-password" = owned;
          "nextcloud/oc-admin-password" = owned;
          "nextcloud/admin-password" = owned;
          "nextcloud/redis-password" = owned;
        };

      # Same pattern as forgejo.nix. Container root maps to this user; every
      # other container uid maps into its subuid range.
      users.users.nextcloud = {
        isSystemUser = true;
        uid = 991;
        group = "nextcloud";
        home = "/var/lib/nextcloud-podman";
        createHome = true;
        linger = true;
        autoSubUidGidRange = true;
      };
      users.groups.nextcloud.gid = 991;

      virtualisation.podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled = true;
        autoPrune.enable = true;
      };

      virtualisation.quadlet = {
        enable = true;

        # oci-containers時代は`podman network create nextcloud`を叩く手製の
        # oneshot unitで代用していた。quadletなら.networkユニットとして
        # 宣言できるので、そのunitは丸ごと不要になる (コンテナ側で
        # `Network = "nextcloud.network"`と参照するだけでpodman-system-
        # generatorが依存関係(Requires=/After=nextcloud-network.service)を
        # 自動で張る)。
        networks.nextcloud = {
          inherit (ncUser) uid;
          networkConfig = {
            NetworkName = "nextcloud";
            Subnet = networkSubnet;
            Gateway = networkGateway;
          };
        };

        containers = {
          # ブートストラップ用スーパーユーザー。Nextcloud 本体はこれでは
          # 繋がず、下の initOcAdminRole が作る oc_admin ロールを使う。
          nextcloud-postgres = {
            inherit (ncUser) uid;
            containerConfig = {
              Image = "docker.io/library/postgres:18.6";
              # podmanName (実際のコンテナ名) をoci-containers時代と揃える。
              ContainerName = "nextcloud-postgres";
              Network = "nextcloud.network";
              # 実データの appdata/config.php は移行元 TrueNAS の docker-compose
              # 由来で 'dbhost' => 'postgres:5432' と決め打ちされている
              # (installed 済みの config.php は POSTGRES_HOST 環境変数を見ない
              # ので、コンテナ名を変えるより別名で解決させる方が早い)。
              NetworkAlias = "postgres";
              Environment = {
                POSTGRES_DB = "nextcloud";
                POSTGRES_USER = "nextcloud";
                POSTGRES_PASSWORD_FILE = "/run/secrets/postgres-password";
              };
              Volume = [
                # postgres 18+ の公式イメージは /var/lib/postgresql/data ではなく
                # /var/lib/postgresql 単体へのマウントを前提に変わった (内部で
                # 18/docker のようなメジャーバージョン別サブディレクトリを自分で
                # 管理する)。実データも旧TrueNAS側で既にこの新レイアウト
                # (postgres/18/docker) になっている。
                "${dataDir}/postgres:/var/lib/postgresql"
                "${stagedSecret "postgres-password"}:/run/secrets/postgres-password:ro"
                "${stagedSecret "oc-admin-password"}:/run/secrets/oc-admin-password:ro"
                "${initOcAdminRole}:/docker-entrypoint-initdb.d/init-oc-admin-role.sql:ro"
              ];
            };
            unitConfig = {
              Requires = [ "nextcloud-secrets.service" ];
              After = [ "nextcloud-secrets.service" ];
            };
          };

          # valkey/valkey の公式イメージには専用のパスワード用環境変数が無い
          # (Bitnami 版と違って VALKEY_PASSWORD 相当が存在しない)。--requirepass
          # を渡す必要があるが、cmd/environment に生のパスワードを直書きすると
          # `podman inspect` で丸見えになるため、シェル経由でマウントした
          # secret ファイルから起動時に読ませる。
          # キャッシュ/セッション/ロック用途のみで、TrueNAS 側でも永続化して
          # いなかった (storage 設定に redis 用の host_path が無い)。同様に
          # ここも永続ボリュームなしにする。
          nextcloud-redis = {
            inherit (ncUser) uid;
            containerConfig = {
              Image = "docker.io/valkey/valkey:9.1.2";
              ContainerName = "nextcloud-redis";
              Network = "nextcloud.network";
              # config.php の 'redis' => ['host' => 'redis'] も同様に決め打ち。
              NetworkAlias = "redis";
              Entrypoint = "sh";
              Exec = ''-c 'exec valkey-server --requirepass "$(cat /run/secrets/redis-password)"' '';
              Volume = [ "${stagedSecret "redis-password"}:/run/secrets/redis-password:ro" ];
            };
            unitConfig = {
              Requires = [ "nextcloud-secrets.service" ];
              After = [ "nextcloud-secrets.service" ];
            };
          };

          # プレビュー(サムネイル)生成。旧 TrueNAS 側の imaginary コンテナに
          # 相当する。AIO 用の日付タグではなく latest を使う (単体運用では
          # バージョンが分かれていない)。
          nextcloud-imaginary = {
            inherit (ncUser) uid;
            containerConfig = {
              Image = "ghcr.io/nextcloud-releases/aio-imaginary:20260929_105435";
              ContainerName = "nextcloud-imaginary";
              Network = "nextcloud.network";
            };
          };

          nextcloud = {
            inherit (ncUser) uid;
            containerConfig = {
              # Same version as the rootful container it replaced; bump separately.
              Image = "docker.io/library/nextcloud:34.0.4-apache";
              ContainerName = "nextcloud";
              Network = "nextcloud.network";
              Environment = {
                POSTGRES_HOST = "nextcloud-postgres";
                POSTGRES_DB = "nextcloud";
                POSTGRES_USER = "oc_admin";
                POSTGRES_PASSWORD_FILE = "/run/secrets/oc-admin-password";
                REDIS_HOST = "nextcloud-redis";
                REDIS_HOST_PASSWORD_FILE = "/run/secrets/redis-password";
                # ユーザー名自体は機微情報じゃないのでここに直書き。
                NEXTCLOUD_ADMIN_USER = "azlle";
                NEXTCLOUD_ADMIN_PASSWORD_FILE = "/run/secrets/admin-password";
                NEXTCLOUD_TRUSTED_DOMAINS = trustedDomains;
                PHP_MEMORY_LIMIT = "512M";
                # Cloudflare Tunnel 無料枠のアップロード上限が実質100MB程度な
                # ので、それ以上大きくしても通らない。旧環境はTrueNASのUI都合で
                # 1G未満にできなかっただけで、本来望んでいたのはこちら。
                PHP_UPLOAD_LIMIT = "100M";
                # The image's remoteip conf trusts X-Real-IP from any 10.x peer, so a
                # client could choose the address Nextcloud sees. trusted_proxies
                # already restores the real one from CF-Connecting-IP.
                APACHE_DISABLE_REWRITE_IP = "1";
              };
              Volume = [
                # TrueNAS 側は appdata (アプリ本体・apps/custom_apps) と
                # userdata (実データ、config.php の datadirectory) を別データ
                # セット相当のディレクトリに分けていたので、同じ形に揃える。
                "${dataDir}/appdata:/var/www/html"
                "${dataDir}/userdata:/var/www/html/data"
                "/etc/localtime:/etc/localtime:ro"
                # 動画プレビュー (OC\Preview\Movie) 用のffmpeg。上のpreview_ffmpeg_path
                # 参照。
                "/nix/store:/nix/store:ro"
                "${stagedSecret "oc-admin-password"}:/run/secrets/oc-admin-password:ro"
                "${stagedSecret "redis-password"}:/run/secrets/redis-password:ro"
                "${stagedSecret "admin-password"}:/run/secrets/admin-password:ro"
                "${extraConfigPhp}:/var/www/html/config/extra.config.php:ro"
                "${extraPhpIni}:/usr/local/etc/php/conf.d/zz-extra.ini:ro"
              ];
              PublishPort = [ "127.0.0.1:${toString httpPort}:80" ];
              # 旧環境 (N100/8GB) の cpus:2/memory:4096 は非力なハード向けの
              # 制約でしかなかった。新ハード (Ryzen 5 5600G/32GB) では単一用途
              # コンテナに対するCPU制限は特に意味が無いので外し、動画プレビュー
              # 生成のような重い処理にも余裕を持たせつつ、暴走時の保険として
              # メモリ上限だけ (他サービスと共存する前提で) 8GBに設定する。
              Memory = "8192m";
            };
            unitConfig = {
              # oci-containersのdependsOnに相当。Network=経由の依存とは違い、
              # コンテナ間の起動順序はquadletが自動で張ってくれないので明示する。
              After = [
                "nextcloud-postgres.service"
                "nextcloud-redis.service"
                "nextcloud-imaginary.service"
                "nextcloud-secrets.service"
              ];
              Requires = [
                "nextcloud-postgres.service"
                "nextcloud-redis.service"
                "nextcloud-imaginary.service"
                "nextcloud-secrets.service"
              ];
            };
          };
        };
      };

      # TrueNAS 側の専用 cron コンテナ (5分おき) の代わりに、systemd timer から
      # occ の cron ジョブを叩く。コンテナを1つ追加で常駐させる必要が無い分軽い。
      # コンテナはnextcloudユーザーのrootless podman側にあるのでそのユーザーで叩く。
      systemd.services.nextcloud-cron = {
        description = "Nextcloud background job runner";
        after = [ "user@${uidStr}.service" ];
        requires = [ "user@${uidStr}.service" ];
        path = [ podman ];
        serviceConfig = {
          Type = "oneshot";
          User = ncUser.name;
          Environment = "XDG_RUNTIME_DIR=/run/user/${uidStr}";
          ExecStart = "${podman}/bin/podman exec --user www-data nextcloud php -f /var/www/html/cron.php";
        };
      };

      systemd.user.services.nextcloud-secrets = {
        description = "Stage Nextcloud secrets for the rootless containers";
        unitConfig.ConditionUser = uidStr;
        path = [
          pkgs.coreutils
          podman
        ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = prepareSecrets;
        };
      };

      # Runs before the user manager, i.e. while no container can have the data open.
      systemd.services.nextcloud-fix-ownership = {
        description = "Align ${dataDir} ownership with ${ncUser.name}'s rootless uid mapping";
        unitConfig.RequiresMountsFor = [
          "${dataDir}/appdata"
          "${dataDir}/userdata"
          "${dataDir}/postgres"
        ];
        path = [
          pkgs.coreutils
          pkgs.findutils
          pkgs.gawk
        ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = fixOwnership;
        };
      };

      # Same as forgejo.nix: asDropin because user@N is an instance of a template
      # unit; RequiresMountsFor so a missing tank import blocks the containers
      # instead of letting them start on empty directories.
      systemd.services."user@${uidStr}" = {
        overrideStrategy = "asDropin";
        unitConfig = {
          RequiresMountsFor = [
            "${dataDir}/appdata"
            "${dataDir}/userdata"
            "${dataDir}/postgres"
          ];
          Requires = [ "nextcloud-fix-ownership.service" ];
          After = [ "nextcloud-fix-ownership.service" ];
        };
      };

      # autoPrune only reaches root's storage.
      systemd.services.nextcloud-podman-prune = {
        description = "Prune nextcloud's rootless podman resources";
        after = [ "user@${uidStr}.service" ];
        requires = [ "user@${uidStr}.service" ];
        startAt = "weekly";
        serviceConfig = {
          Type = "oneshot";
          User = ncUser.name;
          Environment = "XDG_RUNTIME_DIR=/run/user/${uidStr}";
          ExecStart = "${podman}/bin/podman system prune --force --all --volumes";
        };
      };

      systemd.timers.nextcloud-cron = {
        description = "Run Nextcloud background jobs every 5 minutes";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "*:0/5";
          Persistent = true;
        };
      };
    };
}
