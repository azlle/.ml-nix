# cfg.nix
{ ... }:

{
  xdg.configFile = {
    "qtile/config.py".source = ./qtile_config.py;
    "qtile/autostart.sh".source = ./qtile_autostart.sh;
    "qtile/volume.sh".source = ./qtile_volume.sh;
    "polybar/config.ini".source = ./polybar_config.ini;
  };
  home.file = {
    ".local/share/rofi/themes/rounded-yellow-dark.rasi".source = ./rounded-yellow-dark.rasi;
    ".local/share/rofi/themes/rounded-template.rasi".source = ./rounded-template.rasi;
  };
}
