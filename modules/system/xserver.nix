# de.nix
{ config, lib, pkgs, ... }:

{
  programs.hyprland.enable = true;
  services.hypridle.enable = true;
  programs.hyprland.withUWSM = true;
  services.xserver.enable = true;
  programs.xwayland.enable = true;
  services.xserver.displayManager.lightdm.enable = false;

  boot.plymouth.enable = true;

  services.libinput.enable = true;
  services.libinput.touchpad = {
    tapping = true;
    naturalScrolling = true;
  };

  programs.dconf.enable = true;

  environment.variables = {
    GTK_THEME = "Adwaita:dark";
  };

  environment.systemPackages = with pkgs; [
    rofi
    waybar
    swww
    slurp
    grim
    wl-clipboard
    gnome-themes-extra
    adwaita-icon-theme
  ];
}
