# de.nix
{ config, lib, pkgs, ... }:

{
  programs.niri.enable = true;
  programs.niri.package = pkgs.niri-unstable;

  programs.waybar.enable = true;

  services = {
    hypridle.enable = true;
    displayManager.ly.enable = true;
  };

  niri-flake.cache.enable = true;

  programs.dconf.enable = true;

  environment.variables = {
    GTK_THEME = "Adwaita:dark";
  };

  environment.systemPackages = with pkgs; [
    xwayland-satellite
    niriswitcher
    rofi-wayland
    swww
    wl-clipboard
    cliphist
    xdg-utils
    gnome-themes-extra
    adwaita-icon-theme
  ];
}
