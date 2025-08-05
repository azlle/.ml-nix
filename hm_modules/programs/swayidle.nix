# swayidle.nix
{ pkgs, ... }:

{
  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 600;
        command = "${pkgs.wlopm}/bin/wlopm --off '*'";
        resumecommand = "${pkgs.wlopm}/bin/wlopm --on '*'";
      }
    ];
  };

  home.packages = with pkgs; [
    wlopm
  ];
}

