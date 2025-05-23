# ghostty.nix
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    waybar
    htop
    brightnessctl
    pavucontrol
  ];

  home.file = {
    "config" = {
      target = ".config/waybar/config";
      source = ./config;
    };
    "style.css" = {
      target = ".config/waybar/style.css";
      source = ./style.css;
    };
  };
}
