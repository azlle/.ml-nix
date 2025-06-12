# sway.nix
{ pkgs, ... }:

{
  programs.kitty.enable = true;
  wayland.windowManager.hyprland = {
    enable = true;
  };

  home.packages = with pkgs; [
    swaybg
    waybar
    wl-clipboard
    slurp
    grim
  ];
}
