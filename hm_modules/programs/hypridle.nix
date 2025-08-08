# hypridle.nix
{ pkgs, ... }:

{
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
}

