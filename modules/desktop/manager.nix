# modules/desktop/manager.nix
{
  delib,
  pkgs,
  ...
}:
delib.module {
  name = "desktop.manager";

  options = delib.singleCascadeEnableOption;

  nixos.ifEnabled = {
    programs = {
      niri.enable = true;
      dconf.enable = true;
    };

    # programs.niri enables polkit but starts no authentication agent
    systemd.user.services.polkit-kde-agent = {
      description = "PolicyKit Authentication Agent";
      wantedBy = [ "niri.service" ];
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

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
  };
}
