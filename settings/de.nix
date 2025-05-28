# de.nix
{ config, lib, pkgs, ... }:

{
  services.xserver = {
    enable = true;

    displayManager.lightdm = {
      enable = true;
      background = /home/eeshta/Pictures/eeshta_wallpaper.png;
    };

    windowManager.qtile = {
      enable = true;
      extraPackages = python3Packages: with python3Packages; [
        qtile-extras
      ];
    };
  };

  programs.xwayland.enable = false;
  boot.plymouth.enable = true;

  services.libinput.enable = true;
  services.libinput.touchpad = {
    tapping = true;
    naturalScrolling = true;
  };
}
