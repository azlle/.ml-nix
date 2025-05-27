# cfg.nix
{ ... }:

{
  xdg.configFile = {
    "qtile/config.py".source = ./qtile_config.py;
    "qtile/autostart.sh".source = ./qtile_autostart.sh;
    "picom/picom.conf".source = ./picom.conf;
    "polybar/config.ini".source = ./polybar_config.ini;
  };
}
