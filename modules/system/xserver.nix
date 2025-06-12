# de.nix
{ config, lib, pkgs, ... }:

{
  services.xserver.enable = true;
  programs.xwayland.enable = true;
  services.xserver.displayManager.lightdm.enable = false;

  # Sway settings can be found here: ~/.dotfiles/hm_modules/sway.nix
  security.polkit.enable = true;

  services.picom = {
    enable = false;

    backend = "glx";
    vSync = true;
    fade = true;
    fadeSteps = [ (0.03) (0.03) ];

    shadow = true;
    shadowOffsets = [ (-7) (-7) ];
    shadowExclude = [
      "class_g = 'Polybar'" "name = 'polybar'"
      "class_g = 'Dunst'"
    ];
    wintypes = {
      menu = { shadow = false; };
    };

    settings = {
      shadow-radius = 7;
      corner-radius = 20;
      rounded-corners-exclude = [ 
        "class_g = 'Polybar'" "name = 'polybar'"
        "class_g = 'Dunst'"
      ];
      blur = {
        method = "dual_kawase";
        strength = 1;
      };
      blur-background = [
        "class_g = 'Dunst'"
      ];
      blur-background-exclude = [
        "class_g != 'Dunst'"
      ];
    };
  };
  
  boot.plymouth.enable = true;

  services.libinput.enable = true;
  services.libinput.touchpad = {
    tapping = true;
    naturalScrolling = true;
  };

  programs.dconf.enable = true;

  environment.variables = {
    GTK_THEME = "Adwaita:dark";
  };

  environment.systemPackages = with pkgs; [
    wlroots_0_17
    rofi
    gnome-themes-extra
    adwaita-icon-theme
  ];
}
