# modules/manager.nix
{ delib, inputs, ... }:
delib.module {
  name = "manager";

  nixos.always = {
    imports = [
      inputs.niri.nixosModules.niri
      (
        { pkgs, ... }:
        {
          programs = {
            niri = {
              enable = true;
              package = pkgs.niri-unstable;
            };
            dconf.enable = true;
          };

          niri-flake.cache.enable = true;

          services = {
            displayManager.ly.enable = false;
            greetd = {
              enable = true;
              settings = {
                default_session = {
                  command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri-session";
                  user = "greeter";
                };
              };
            };
          };

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
            awww
            wl-clipboard
            brightnessctl
            cliphist
            xdg-utils
            gnome-themes-extra
            adwaita-icon-theme
          ];
        }
      )
    ];
  };
}
