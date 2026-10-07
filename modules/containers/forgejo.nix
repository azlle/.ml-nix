# modules/containers/forgejo.nix
{
  delib,
  config,
  inputs,
  pkgs,
  ...
}:
delib.module {
  name = "containers.forgejo";

  options = delib.singleCascadeEnableOption;

  # nextcloud.nixと同じ理由でここでも読み込んでおく (containers.forgejo.enable
  # がfalseでも問題ない)。
  nixos.always.imports = [ inputs.quadlet-nix.nixosModules.default ];

  nixos.ifEnabled =
    let
      forgejoDomain = "git.melocy.cc";
      forgejoSshDomain = "git-ssh.melocy.cc";
      forgejoHttpPort = 3080;
      forgejoSshPort = 2222;
      # necrofantasiaはM.2単発で冗長性が無かったのでtankへの定期dumpコピーで
      # 保険をかけていたが、本体をplainasiaに持ってきたならtank(IronWolf 8TB
      # ミラー)自体に直接データを置けば済む。/tank/nextcloudと同じ考え方。
      dataDir = "/tank/forgejo";

      forgejoUser = config.users.users.forgejo;
    in
    {
      # home (/var/lib/forgejo-podman) はForgejo自体のデータ(dataDir)とは
      # 別物で、rootless podman自身のストレージ(イメージ/コンテナlayer)置き場
      # でしかないのでtank配下に置く必要はない。
      users.users.forgejo = {
        isSystemUser = true;
        uid = 990;
        group = "forgejo";
        home = "/var/lib/forgejo-podman";
        createHome = true;
        linger = true;
        autoSubUidGidRange = true;
      };
      users.groups.forgejo.gid = 990;

      # 2026-10-07の移行作業で手動で一度叩いただけだった`chown -R 990:990`を
      # 宣言化する。これが無いと、古いsanoidスナップショットからの復元や
      # 再インストール後の再import等でdataDirの所有者がuid 1000 (rootful
      # 時代) に戻ってしまった場合、rootless化の設定(UserNS=keep-id)自体は
      # 正しく再現されてもForgejoコンテナ側は再現されず、docker-entrypoint.sh
      # 内の各種chmod/mkdirがEPERMで失敗する (2026-10-07に実際に踏んだ:
      # chmod: /data/git: Operation not permitted)。起動の度に
      # (ZFSデータセットとしては安価な) chownを再適用することで、tank配下の
      # データが生き残っていればuidがズレていても自己修復するようにする。
      # systemd.tmpfiles.rulesのZ型ではなく専用serviceにする理由: tmpfiles
      # はブート初期に動くためtankのZFS importより先に走る可能性があり、
      # マウント前の空ディレクトリに対して実行されてしまう (nextcloud.nixと
      # 同じ理由でtmpfiles.rulesの「無ければ作る」系を避けているのと同根)。
      # RequiresMountsForで実マウントまで待つ。
      systemd.services.forgejo-fix-ownership = {
        description = "Ensure ${dataDir} is owned by the forgejo user";
        unitConfig.RequiresMountsFor = [ dataDir ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.coreutils}/bin/chown -R ${toString forgejoUser.uid}:${toString forgejoUser.uid} ${dataDir}";
        };
      };

      # virtualisation.podman.autoPrune (nixpkgs本体) が生成するpodman-prune.
      # serviceはrequires=podman.serviceの素のsystemユニットで、root所有の
      # rootfulなpodmanストレージ(/var/lib/containers/storage)にしか
      # ExecStart = podman system prune -fを投げない。rootlessでuid 990
      # 専用のストレージ(/var/lib/forgejo-podman)に切り出した時点でそちら
      # の対象から外れる (quadlet/oci-containersの違いは無関係 — rootfulで
      # 動く限りは元々同じストレージを共有しているので、Nextcloud含め
      # 既存のautoPruneはそのまま効き続ける)。同じ理屈をforgejo自身の
      # ストレージにも適用するため、User=でuid 990として実行するだけの
      # 専用unitを用意する。
      systemd.services.forgejo-podman-prune = {
        description = "Prune forgejo's rootless podman resources";
        after = [ "user@${toString forgejoUser.uid}.service" ];
        requires = [ "user@${toString forgejoUser.uid}.service" ];
        startAt = "weekly";
        serviceConfig = {
          Type = "oneshot";
          User = forgejoUser.name;
          Environment = "XDG_RUNTIME_DIR=/run/user/${toString forgejoUser.uid}";
          ExecStart = "${config.virtualisation.podman.package}/bin/podman system prune -f";
        };
      };

      # 2026-10-06に一度踏んだ罠を先取りで回避する: デフォルトの
      # overrideStrategy (asDropinIfExists) は「同名のユニットファイルが
      # 既にパッケージから提供されているか」をファイル名の完全一致で判定する。
      # user@.serviceはテンプレートユニットなので実体ファイルとして存在する
      # のはuser@.service自身だけで、user@990.serviceというファイルはどの
      # パッケージにも存在しない。判定が外れるとドロップインではなく新規
      # ユニットとして丸ごと生成されてしまい、ExecStartを持たない空の
      # ユニットが本物のuser@.serviceテンプレートを差し替え、
      # loginctl enable-lingerが user@990.service の起動に失敗する
      # ("Exec format error")。overrideStrategy = "asDropin" を明示することで
      # 本物のuser@990.service.d/overrides.confとして生成させる。
      #
      # forgejo-fix-ownershipへのRequires/Afterも、tank未マウント時の保護
      # (RequiresMountsFor) と同じ理由でここに付ける: コンテナ本体
      # (forgejo.service) はuid 990のsystemd --userインスタンス配下にあり、
      # system側のuser@990.serviceが先に起動を終えていなければそもそも
      # 存在し得ないので、ここでchownを待たせれば十分で、forgejo.service
      # 自体に個別に依存を付ける必要は無い。
      systemd.services."user@${toString forgejoUser.uid}" = {
        overrideStrategy = "asDropin";
        unitConfig = {
          RequiresMountsFor = [ dataDir ];
          Requires = [ "forgejo-fix-ownership.service" ];
          After = [ "forgejo-fix-ownership.service" ];
        };
      };

      virtualisation.podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled = true;
        autoPrune.enable = true;
      };

      virtualisation.quadlet = {
        enable = true;

        containers.forgejo = {
          # uidを指定すると、rootfulなsystemユニットではなくこのuidのsystemd
          # --userインスタンス配下のユニットとして生成される
          # (quadlet-nixのRootless units参照)。RequiresMountsForは上の
          # systemd.services."user@990"側に付けてあるので、tank未マウント時の
          # 保護はそちらが担う。
          uid = forgejoUser.uid;

          containerConfig = {
            # 通常版イメージのPID1はs6-overlayでroot初期化が必須
            # (2026-10-06の障害: UserNS=keep-idと組み合わせるとs6-svscanが
            # .s6-svscan/lockを開けずに即死する)。USER 1000:1000が最初から
            # 焼き込まれていてroot化する瞬間が無いrootless専用タグに切り替える。
            Image = "codeberg.org/forgejo/forgejo:16-rootless";
            ContainerName = "forgejo";
            HostName = forgejoDomain;

            # rootfulだった頃はコンテナ内uid 1000がホストのuid 1000へ素通し
            # だったが、rootlessではpodmanのuser namespace越しになる。keep-idで
            # ホスト側(forgejoユーザー, uid 990)をコンテナ内uid 1000へ固定
            # マッピングする。
            UserNS = "keep-id:uid=1000,gid=1000";

            Environment = {
              # rootlessイメージのGITEA_CUSTOM/GITEA_APP_INI/GITEA_WORK_DIR/
              # HOMEは/var/lib/gitea基準の値がDockerfile内で${GITEA_CUSTOM}
              # 展開済みの固定文字列としてビルド時に焼き込まれている
              # (GITEA_APP_INI=/var/lib/gitea/custom/conf/app.ini相当)。
              # 実行時にGITEA_CUSTOMだけ上書きしても、既にビルド時に展開済みの
              # GITEA_APP_INIは連動して変わらない。entrypointはどのapp.iniを
              # -cで開くかをこれで決めるので、Volumeをどこにマウントしようと
              # 無関係にそちらを見てしまい、既存データを全く読まない新規インス
              # タンスが生成される (2026-10-07の実機投入で実際に踏んだ —
              # HTTP/SSHバナーは新規インスタンスでも普通に応答するので、通常の
              # 動作確認だけでは気づけない。起動ログのWorkPath:/ConfigFile:行
              # で実データを指しているか確認する必要がある)。4つとも明示的に
              # 実データ側 (/data、volumesで${dataDir}をマウントしている先) へ
              # 向ける。
              GITEA_CUSTOM = "/data/gitea";
              GITEA_APP_INI = "/data/gitea/conf/app.ini";
              GITEA_WORK_DIR = "/data/gitea";
              HOME = "/data/git";

              # USER_UID/USER_GIDは通常版イメージが内部でusermod/groupmodする
              # ためのもので、USER 1000:1000が焼き込まれているrootlessイメージ
              # には存在しない/無意味なので削除。
              FORGEJO__server__DOMAIN = forgejoDomain;
              FORGEJO__server__ROOT_URL = "https://${forgejoDomain}/";
              FORGEJO__server__PROTOCOL = "http";
              FORGEJO__server__HTTP_PORT = "3000";
              FORGEJO__server__SSH_DOMAIN = forgejoSshDomain;
              # 埋め込みSSHサーバーの既定鍵名はgitea.rsa等だが、実データの
              # ホスト鍵は旧来の実sshd時代の命名 (ssh_host_*_key) で
              # /data/ssh配下 (APP_DATA_PATHである/data/giteaの外) にある。
              # 指定しないと埋め込みサーバーは既定の場所に新規鍵を生成して
              # しまい (実際に2回, 再起動ごとに毎回違う鍵で発生した)、
              # git-ssh.melocy.ccのホスト鍵がデプロイごとに変わり続ける。
              # 鍵ファイル自体は標準PEM形式なのでファイル名が違っても読める
              # はず — 絶対パスで実ファイルを直接指定する。
              FORGEJO__server__SSH_SERVER_HOST_KEYS = "/data/ssh/ssh_host_rsa_key,/data/ssh/ssh_host_ecdsa_key,/data/ssh/ssh_host_ed25519_key";
              # 実データのapp.iniは通常版イメージの頃に作られたままなので
              # START_SSH_SERVER/BUILTIN_SSH_SERVER_USERキー自体が存在しない
              # (rootlessイメージ専用の設定で、通常版の頃は実sshd+
              # AuthorizedKeysCommand方式だったためこのキーが要らなかった)。
              # 無いと埋め込みSSHサーバーが一切起動しない (ドライランで実証:
              # SSH_PORT/SSH_LISTEN_PORTは正しく2222になっていてもHTTPの3000
              # 以外どのポートもlistenしておらず、SSH接続は毎回kex前に
              # connection resetになっていた)。明示的に有効化する。
              FORGEJO__server__START_SSH_SERVER = "true";
              FORGEJO__server__BUILTIN_SSH_SERVER_USER = "git";
              # rootlessイメージの既定は2222 (<1024のbindにはCAP_NET_BIND_SERVICE
              # /rootが要るが、このイメージはuid 1000から一度もrootにならない)。
              # 実データのapp.iniには旧インストール時の値 (22) がそのまま永続
              # 化されているので、SSH_DOMAINと同じ仕組み (FORGEJO__*環境変数が
              # 毎回app.iniに書き込まれる) で2222に同期させる。
              FORGEJO__server__SSH_PORT = "2222";
              FORGEJO__server__SSH_LISTEN_PORT = "2222";
              FORGEJO__service__DISABLE_REGISTRATION = "true";
              FORGEJO__security__INSTALL_LOCK = "true";
              FORGEJO__session__COOKIE_SECURE = "true";
              FORGEJO__database__DB_TYPE = "sqlite3";

              FORGEJO__cron_0X2E_git_gc_repos__ENABLED = "true";
              FORGEJO__cron_0X2E_git_gc_repos__RUN_AT_START = "false";
              FORGEJO__cron_0X2E_git_gc_repos__SCHEDULE = "0 23 * * 6";
              FORGEJO__cron_0X2E_git_gc_repos__TIMEOUT = "25m";
            };
            # plainasiaにcloudflaredと同居させたので、LAN越しのバインドは
            # 不要になった (旧necrofantasia時代はcloudflaredが別ホストだった
            # ためLAN固定IPにバインドしていた)。loopback限定にすることで
            # 直接到達できるのはこのホスト上のcloudflaredだけ、という元の
            # アクセス範囲 (necrofantasia側ファイアウォールでplainasiaの
            # 固定IPだけに絞っていたのと同義) を保っている。
            PublishPort = [
              "127.0.0.1:${toString forgejoHttpPort}:3000"
              # 公開側(左辺、cloudflared.nixのgit-ssh.melocy.cc ingress先)は
              # そのまま、コンテナ内側(右辺)だけ22→2222に直す。
              "127.0.0.1:${toString forgejoSshPort}:2222"
            ];
            # マウント先はrootful時代と同じ/dataのまま変えない (上の
            # GITEA_CUSTOM等の環境変数でこの/data/gitea・/data/gitを指して
            # いるので、ディレクトリの再構成は不要)。
            Volume = [
              "${dataDir}:/data"
              "/etc/localtime:/etc/localtime:ro"
            ];
          };
        };
      };
    };
}
