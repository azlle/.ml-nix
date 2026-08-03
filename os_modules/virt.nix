# virt.nix
{ config, pkgs, ... }:

let
  forgejoDomain = "git.melocy.cc";
  forgejoSshDomain = "git-ssh.melocy.cc";
  forgejoHttpPort = 3080;
  forgejoSshPort = 2222;
in

{
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
    };

    spiceUSBRedirection.enable = true;

    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
      autoPrune.enable = true;
    };

    oci-containers = {
      backend = "podman";
      containers = {
        phpmyadmin = {
          image = "phpmyadmin";
          ports = [ "8080:80" ];
          environment = {
            PMA_HOST = "172.17.0.1";
            PMA_PORT = "3306";
            BLOWFISH_SECRET = "***REMOVED***";
          };
        };

        # Self-hosted Forgejo, reachable only through a Cloudflare Tunnel
        # (no inbound firewall ports). Cloudflare Access in front of the
        # tunnel enforces auth via the Auth0 OIDC identity provider
        # (configured in the Cloudflare Zero Trust dashboard, not here).
        # Replaces the earlier GitLab CE setup, which was too heavy for a
        # personal laptop (multi-GB baseline vs. Forgejo's ~200MB).
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
          };
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

  # Bind-mount source for the forgejo container; podman does not create
  # missing host directories for volume mounts on its own.
  systemd.tmpfiles.rules = [
    "d /var/lib/forgejo 0755 root root -"
  ];

  # Daily Forgejo backup, rsynced off-host to the NAS since /var/lib/forgejo
  # living on a single laptop disk is a single point of failure.
  systemd.services.forgejo-backup = {
    description = "Forgejo backup and offsite copy";
    after = [
      "podman-forgejo.service"
      "network-online.target"
    ];
    wants = [ "network-online.target" ];
    serviceConfig.RequiresMountsFor = [ "/mnt/yamaxanadu" ];
    path = [ pkgs.podman ];
    script = ''
      set -euo pipefail
      dest=/mnt/yamaxanadu/misc/gitlab_backup/
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
      OnCalendar = "00:00";
      Persistent = true;
    };
  };

  # Outbound-only connection to Cloudflare's edge, so no firewall changes
  # are needed for Forgejo. DNS CNAMEs for forgejoDomain/forgejoSshDomain
  # point at <tunnel-id>.cfargotunnel.com via `cloudflared tunnel route dns`.
  services.cloudflared = {
    enable = true;
    tunnels."8a2ddac7-52f5-4cda-93fe-fd25b2fea880" = {
      credentialsFile = config.sops.secrets."cloudflared/git-tunnel".path;
      default = "http_status:404";
      ingress = {
        "${forgejoDomain}" = "http://localhost:${toString forgejoHttpPort}";
        "${forgejoSshDomain}" = "ssh://localhost:${toString forgejoSshPort}";
      };
    };
  };

  programs.virt-manager.enable = true;

  users.users.eeshta.extraGroups = [
    "libvirtd"
  ];
}
