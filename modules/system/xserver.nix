# de.nix
{ config, lib, pkgs, ... }:

{
  programs.niri.enable = true;
  programs.niri.package = pkgs.niri-unstable;
  niri-flake.cache.enable = true;

  services = {
    displayManager.ly.enable = false;
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri";
          user = "greeter";
        };
      };
    };
  };

  programs.dconf.enable = true;

  environment.variables = {
    GTK_THEME = "Adwaita:dark";
  };

  environment.systemPackages = with pkgs; [
    tuigreet
    waybar
    eww
    xwayland-satellite
    glib # niriswitcherにgdbusが必要
    niriswitcher
    rofi
    swww
    wl-clipboard
    brightnessctl
    cliphist
    xdg-utils
    gnome-themes-extra
    adwaita-icon-theme
  ];
}
