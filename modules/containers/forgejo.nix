# modules/containers/forgejo.nix
{ delib, pkgs, ... }:
delib.module {
  name = "containers.forgejo";

  options = delib.singleCascadeEnableOption;

  nixos.ifEnabled =
    let
      forgejoDomain = "git.melocy.cc";
      forgejoSshDomain = "git-ssh.melocy.cc";
      forgejoHttpPort = 3080;
      forgejoSshPort = 2222;
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
                "/var/lib/forgejo:/data"
                "/etc/localtime:/etc/localtime:ro"
              ];
            };
          };
        };
      };

      systemd.tmpfiles.rules = [
        "d /var/lib/forgejo 0755 root root -"
      ];

      systemd.services.forgejo-backup = {
        # necrofantasia時代はこのホスト自身がtank/mainを持っていなかったので、
        # NFS越しに/mnt/yamaxanaduへコピーしていた。plainasiaはtank/main自身を
        # 抱えているホストなので、ローカルパスへ直接コピーするだけで済む
        # (オフサイト性は元々ZFS側の冗長性に委ねていて、このコピー自体はただの
        # 「コンテナの外に出しておく」程度の意味だったため、ローカル化しても
        # 目的は変わらない)。
        description = "Forgejo backup";
        after = [
          "podman-forgejo.service"
        ];
        serviceConfig.RequiresMountsFor = [ "/tank/main/misc" ];
        path = [ pkgs.podman ];
        script = ''
          set -euo pipefail
          dest=/tank/main/misc/gitlab_backup/
          stamp=$(date +%Y%m%d-%H%M%S)

          mkdir -p /var/lib/forgejo/backups /var/lib/forgejo/tmp
          chown 1000:1000 /var/lib/forgejo/backups /var/lib/forgejo/tmp
          podman exec --user 1000 forgejo forgejo dump \
            --config /data/gitea/conf/app.ini \
            --file "/data/backups/$stamp-forgejo-dump.tar.gz" \
            --type tar.gz \
            --tempdir /data/tmp

          cp "/var/lib/forgejo/backups/$stamp-forgejo-dump.tar.gz" "$dest"

          find /var/lib/forgejo/backups -name '*-forgejo-dump.tar.gz' -mtime +7 -delete
          find "$dest" -name '*-forgejo-dump.tar.gz' -mtime +30 -delete
        '';
        serviceConfig.Type = "oneshot";
      };

      systemd.timers.forgejo-backup = {
        description = "Daily Forgejo backup";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "23:30";
          Persistent = true;
        };
      };
    };
}
