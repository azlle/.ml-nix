# modules/desktop/hypridle.nix
{ delib, ... }:
delib.module {
  name = "desktop.hypridle";

  options = delib.singleCascadeEnableOption;

  home.ifEnabled = {
    services.hypridle = {
      enable = true;
      settings = {
        listener = [
          {
            timeout = 600;
            on-timeout = "niri msg action power-off-monitors";
            on-resume = "niri msg action power-on-monitors";
          }
        ];
      };
    };
  };
}
