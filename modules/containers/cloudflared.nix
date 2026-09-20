# modules/containers/cloudflared.nix
{ delib, config, ... }:
delib.module {
  name = "containers.cloudflared";

  options = delib.singleCascadeEnableOption;

  nixos.ifEnabled = {
    services.cloudflared = {
      enable = true;
      tunnels."8a2ddac7-52f5-4cda-93fe-fd25b2fea880" = {
        credentialsFile = config.sops.secrets."cloudflared/melocy-edge".path;
        default = "http_status:404";
        ingress = {
          "drive.melocy.cc" = "http://192.168.11.96:22300";
          "git.melocy.cc" = "http://localhost:3080";
          "git-ssh.melocy.cc" = "ssh://localhost:2222";
        };
      };
    };
  };
}
