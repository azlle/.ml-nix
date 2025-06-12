# sway.nix
{ pkgs, ... }:

{
  wayland.windowManager.sway = {
    enable = true;
    package = pkgs.swayfx;

    checkConfig = false;
    config = rec {
      defaultWorkspace = "workspace number 1";
      modifier = "Mod4";
      terminal = "ghostty";
      menu = "rofi -show drun -theme ~/.local/share/rofi/themes/rounded-yellow-dark.rasi";
      startup = [
        {command = "vesktop --start-minimized";}
        {command = "waybar";}
        {
          command = "swaybg -i ~/Pictures/eeshta_wallpaper.png -m fill";
          always = true;
        }
      ];
      gaps = {
        inner = 24;
        #outer = 20;
      };
      window = {
        titlebar = false;
        border = 3;
      };
      bars = [];
    };
    extraConfig = ''
      corner_radius 20
    '';
  };

  home.packages = with pkgs; [
    swaylock
    swayidle
    swaybg
    waybar
    wl-clipboard
  ];
}
