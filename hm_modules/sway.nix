# sway.nix
{ ... }:

{
  wayland.windowManager.sway = {
    enable = true;
    config = rec {
      modifier = "Mod4";
      terminal = "ghostty";
      startup = [
        {command = "vesktop --start-minimized";}
      ];
    };
  };
}
