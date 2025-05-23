# cfg.nix
{ ... }:

{
  home.file = {
    "hyprland.conf" = {
      target = ".config/hypr/hyprland.conf";
      source = ./hyprland.conf;
    };
    "hyprpaper.conf" = {
      target = ".config/hypr/hyprpaper.conf";
      source = ./hyprpaper.conf;
    };
  };
}
