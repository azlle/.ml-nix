# modules/containers/forgejo.nix
{
  delib,
  config,
  ...
}:
delib.module {
  name = "containers.forgejo";

  options = delib.singleCascadeEnableOption;

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

      # rootless化の第一段階: 専用システムユーザーだけ先行投入する。この時点
      # ではまだ下のoci-containersブロック(rootful)を使い続けるので無関係 —
      # 実際にこのユーザーのsystemd --userインスタンス配下でForgejoを動かす
      # のはrootlessイメージへの切り替えとデータ移行が済んでから (別PR)。
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
            forgejo = {
              image = "codeberg.org/forgejo/forgejo:16";
              hostname = forgejoDomain;
              environment = {
                USER_UID = "1000";
                USER_GID = "1000";
                FORGEJO__server__DOMAIN = forgejoDomain;
                FORGEJO__server__ROOT_URL = "https://${forgejoDomain}/";
                FORGEJO__server__PROTOCOL = "http";
                FORGEJO__server__HTTP_PORT = "3000";
                FORGEJO__server__SSH_DOMAIN = forgejoSshDomain;
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
              ports = [
                "127.0.0.1:${toString forgejoHttpPort}:3000"
                "127.0.0.1:${toString forgejoSshPort}:22"
              ];
              volumes = [
                "${dataDir}:/data"
                "/etc/localtime:/etc/localtime:ro"
              ];
            };
          };
        };
      };

      # tank/forgejoはZFSデータセット自身のマウントとして既に存在するディレクトリ
      # なので、tmpfiles.rulesで「無ければ作る」は使わない (nextcloud.nixと同じ
      # 理由: tankがimportされていない/マウント失敗時でも黙ってOS側に空ディレクトリ
      # が作られてしまい、気づかないまま間違った場所にデータを書き込みかねない)。
      # RequiresMountsForで実際にマウントされているまで起動をブロックする。
      systemd.services.podman-forgejo.unitConfig.RequiresMountsFor = [ dataDir ];
    };
}
