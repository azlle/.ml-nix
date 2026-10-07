# modules/containers/forgejo.nix
{
  delib,
  config,
  inputs,
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
      systemd.services."user@${toString forgejoUser.uid}" = {
        overrideStrategy = "asDropin";
        unitConfig.RequiresMountsFor = [ dataDir ];
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
              # USER_UID/USER_GIDは通常版イメージが内部でusermod/groupmodする
              # ためのもので、USER 1000:1000が焼き込まれているrootlessイメージ
              # には存在しない/無意味なので削除。
              FORGEJO__server__DOMAIN = forgejoDomain;
              FORGEJO__server__ROOT_URL = "https://${forgejoDomain}/";
              FORGEJO__server__PROTOCOL = "http";
              FORGEJO__server__HTTP_PORT = "3000";
              FORGEJO__server__SSH_DOMAIN = forgejoSshDomain;
              # rootlessイメージの既定は2222 (<1024のbindにはCAP_NET_BIND_SERVICE
              # /rootが要るが、このイメージはuid 1000から一度もrootにならない)。
              # 既存のapp.iniには旧インストール時の値 (22) がそのまま永続化
              # されていて、対応する環境変数が無いキーは上書きされない
              # (SSH_DOMAIN等、対応する環境変数があるキーは毎回書き込まれる
              # ことをドライランで実証済み)。明示的に指定して毎回同期させる。
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
            # ドライランで実証済み: app.iniに既に焼き込まれているWORK_PATH/
            # APP_DATA_PATH等が/data/gitea基準なので、マウント先を
            # /var/lib/gitea (rootlessイメージの既定) に変えると「/dataが
            # 存在しない」エラーで即死する。対応する環境変数が無いこれらの
            # キーは書き換わらないので、マウント先はrootful時代と同じ/data
            # のまま変えない (ディレクトリの再構成も不要)。
            Volume = [
              "${dataDir}:/data"
              "/etc/localtime:/etc/localtime:ro"
            ];
          };
        };
      };
    };
}
