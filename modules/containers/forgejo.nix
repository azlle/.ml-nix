# modules/containers/forgejo.nix
{ delib, ... }:
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
    in
    {
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
