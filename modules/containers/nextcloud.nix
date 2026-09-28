# modules/containers/nextcloud.nix
{
  delib,
  config,
  pkgs,
  ...
}:
delib.module {
  name = "containers.nextcloud";

  options = delib.singleCascadeEnableOption;

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

      secretPath = name: config.sops.secrets."nextcloud/${name}".path;

      # 旧 TrueNAS 側では postgres コンテナ自身のブートストラップ用スーパーユーザー
      # (nextcloud) と、Nextcloud アプリ本体が実際に使う権限を絞ったロール
      # (oc_admin、CREATEDB のみ) が分かれていた。同じ構成に合わせる。
      initOcAdminRole = pkgs.writeShellScript "init-oc-admin-role.sh" ''
        set -euo pipefail
        ocAdminPassword=$(cat /run/secrets/oc-admin-password)
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -c \
          "SELECT 'CREATE ROLE oc_admin WITH LOGIN CREATEDB PASSWORD ''$ocAdminPassword''' WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname='oc_admin')\gexec"
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -c \
          "GRANT ALL PRIVILEGES ON DATABASE \"$POSTGRES_DB\" TO oc_admin;"
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
          'dbtableprefix' => 'oc_',
          'skeletondirectory' => "",
          'preview_max_filesize_image' => -1,
          'preview_max_memory' => 1024,
          'preview_imaginary_url' => 'http://nextcloud-imaginary:9000',
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
      # containers.enable が false な間はこのモジュール自体が評価されないので、
      # secret.yaml 側にまだキーが無くてもビルドは壊れない。sopsFile は
      # modules/sops.nix の defaultSopsFile (secret.yaml) をそのまま使う。
      sops.secrets = {
        "nextcloud/postgres-password" = { };
        "nextcloud/oc-admin-password" = { };
        "nextcloud/admin-password" = { };
        "nextcloud/redis-password" = { };
      };

      virtualisation = {
        podman = {
          enable = true;
          dockerCompat = true;
          defaultNetwork.settings.dns_enabled = true;
          autoPrune.enable = true;
        };

        oci-containers = {
          backend = "podman";
          containers = {
            # ブートストラップ用スーパーユーザー。Nextcloud 本体はこれでは
            # 繋がず、下の initOcAdminRole が作る oc_admin ロールを使う。
            nextcloud-postgres = {
              image = "docker.io/library/postgres:18.6";
              environment = {
                POSTGRES_DB = "nextcloud";
                POSTGRES_USER = "nextcloud";
                POSTGRES_PASSWORD_FILE = "/run/secrets/postgres-password";
              };
              volumes = [
                # postgres 18+ の公式イメージは /var/lib/postgresql/data ではなく
                # /var/lib/postgresql 単体へのマウントを前提に変わった (内部で
                # 18/docker のようなメジャーバージョン別サブディレクトリを自分で
                # 管理する)。実データも旧TrueNAS側で既にこの新レイアウト
                # (postgres/18/docker) になっている。
                "${dataDir}/postgres:/var/lib/postgresql"
                "${secretPath "postgres-password"}:/run/secrets/postgres-password:ro"
                "${secretPath "oc-admin-password"}:/run/secrets/oc-admin-password:ro"
                "${initOcAdminRole}:/docker-entrypoint-initdb.d/init-oc-admin-role.sh:ro"
              ];
              # 実データの appdata/config.php は移行元 TrueNAS の docker-compose
              # 由来で 'dbhost' => 'postgres:5432' と決め打ちされている
              # (installed 済みの config.php は POSTGRES_HOST 環境変数を見ない
              # ので、コンテナ名を変えるより別名で解決させる方が早い)。
              extraOptions = [
                "--network=nextcloud"
                "--network-alias=postgres"
              ];
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
              image = "docker.io/valkey/valkey:9.1.2";
              entrypoint = "sh";
              cmd = [
                "-c"
                ''exec valkey-server --requirepass "$(cat /run/secrets/redis-password)"''
              ];
              volumes = [ "${secretPath "redis-password"}:/run/secrets/redis-password:ro" ];
              # config.php の 'redis' => ['host' => 'redis'] も同様に決め打ち。
              extraOptions = [
                "--network=nextcloud"
                "--network-alias=redis"
              ];
            };

            # プレビュー(サムネイル)生成。旧 TrueNAS 側の imaginary コンテナに
            # 相当する。AIO 用の日付タグではなく latest を使う (単体運用では
            # バージョンが分かれていない)。
            nextcloud-imaginary = {
              image = "ghcr.io/nextcloud-releases/aio-imaginary:latest";
              extraOptions = [ "--network=nextcloud" ];
            };

            nextcloud = {
              image = "docker.io/library/nextcloud:34-apache";
              dependsOn = [
                "nextcloud-postgres"
                "nextcloud-redis"
                "nextcloud-imaginary"
              ];
              environment = {
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
              };
              volumes = [
                # TrueNAS 側は appdata (アプリ本体・apps/custom_apps) と
                # userdata (実データ、config.php の datadirectory) を別データ
                # セット相当のディレクトリに分けていたので、同じ形に揃える。
                "${dataDir}/appdata:/var/www/html"
                "${dataDir}/userdata:/var/www/html/data"
                "/etc/localtime:/etc/localtime:ro"
                "${secretPath "oc-admin-password"}:/run/secrets/oc-admin-password:ro"
                "${secretPath "redis-password"}:/run/secrets/redis-password:ro"
                "${secretPath "admin-password"}:/run/secrets/admin-password:ro"
                "${extraConfigPhp}:/var/www/html/config/extra.config.php:ro"
                "${extraPhpIni}:/usr/local/etc/php/conf.d/zz-extra.ini:ro"
              ];
              ports = [ "127.0.0.1:${toString httpPort}:80" ];
              # 旧環境 (N100/8GB) の cpus:2/memory:4096 は非力なハード向けの
              # 制約でしかなかった。新ハード (Ryzen 5 5600G/32GB) では単一用途
              # コンテナに対するCPU制限は特に意味が無いので外し、動画プレビュー
              # 生成のような重い処理にも余裕を持たせつつ、暴走時の保険として
              # メモリ上限だけ (他サービスと共存する前提で) 8GBに設定する。
              extraOptions = [
                "--network=nextcloud"
                "--memory=8192m"
              ];
            };
          };
        };
      };

      systemd.services.podman-network-nextcloud = {
        description = "Podman network for the Nextcloud containers";
        after = [ "podman.service" ];
        wantedBy = [ "multi-user.target" ];
        path = [ config.virtualisation.podman.package ];
        serviceConfig.Type = "oneshot";
        serviceConfig.RemainAfterExit = true;
        script = ''
          podman network exists nextcloud || podman network create nextcloud
        '';
      };

      systemd.services.podman-nextcloud-redis.after = [ "podman-network-nextcloud.service" ];
      systemd.services.podman-nextcloud-imaginary.after = [ "podman-network-nextcloud.service" ];

      # postgres/appdata/userdata は tank 側の独立したデータセット。
      # systemd.tmpfiles.rules で「無ければ作る」形にすると、tank が import
      # されていない/マウント失敗時でも黙ってOS側に空ディレクトリが作られて
      # しまい、気づかないまま間違った場所にデータを書き込みかねない。
      # RequiresMountsFor で実際にマウントされているまで起動をブロックする。
      systemd.services.podman-nextcloud-postgres = {
        after = [ "podman-network-nextcloud.service" ];
        unitConfig.RequiresMountsFor = [ "${dataDir}/postgres" ];
      };

      systemd.services.podman-nextcloud = {
        after = [ "podman-network-nextcloud.service" ];
        unitConfig.RequiresMountsFor = [
          "${dataDir}/appdata"
          "${dataDir}/userdata"
        ];
      };

      # TrueNAS 側の専用 cron コンテナ (5分おき) の代わりに、systemd timer から
      # occ の cron ジョブを叩く。コンテナを1つ追加で常駐させる必要が無い分軽い。
      systemd.services.nextcloud-cron = {
        description = "Nextcloud background job runner";
        after = [ "podman-nextcloud.service" ];
        path = [ config.virtualisation.podman.package ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${config.virtualisation.podman.package}/bin/podman exec --user www-data nextcloud php -f /var/www/html/cron.php";
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
