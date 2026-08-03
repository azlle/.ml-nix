# ssh.nix
{ pkgs, ... }:

{
  home.packages = [ pkgs.cloudflared ];

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*" = {
        ForwardAgent = false;
        AddKeysToAgent = "no";
        Compression = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        ControlMaster = "no";
      };

      "git-ssh.melocy.cc" = {
        User = "git";
        ProxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h";
      };
    };
  };
}
