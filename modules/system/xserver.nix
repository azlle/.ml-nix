# de.nix
{ config, lib, pkgs, ... }:

{
  programs = {
    hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };
  };

  services = {
    hypridle.enable = true;
  };

  # XWaylandを明示的にインポートしなくていいらしいのでそうする

  boot.plymouth.enable = false;

  programs.dconf.enable = true;

  environment.variables = {
    GTK_THEME = "Adwaita:dark";
  };

  environment.systemPackages = with pkgs; [
    rofi-wayland
    waybar
    swww
    grimblast
    wl-clipboard
    cliphist
    xdg-utils
    gnome-themes-extra
    adwaita-icon-theme
  ];
}
