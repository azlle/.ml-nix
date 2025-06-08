# de.nix
{ config, lib, pkgs, ... }:

{
  services.xserver = {
    enable = true;

    displayManager.lightdm = {
      enable = true;
      background = ../../artworks/nix-wallpaper-simple-dark-gray_bottom_ngomixed.png;
    };

    windowManager.qtile = {
      enable = true;
      extraPackages = python3Packages: with python3Packages; [
        qtile-extras
      ];
    };

    xkb = {
      layout = "jp,gb";
      model = "jp106";
    };
  };

  services.picom = {
    enable = true;

    backend = "glx";
    vSync = true;
    fade = true;
    fadeSteps = [ (0.03) (0.03) ];

    shadow = true;
    shadowOffsets = [ (-7) (-7) ];
    shadowExclude = [ "class_g = 'Polybar'" "name = 'polybar'" ];
    wintypes = {
      menu = { shadow = false; };
    };

    settings = {
      shadow-radius = 7;
      corner-radius = 20;
      rounded-corners-exclude = [ "class_g = 'Polybar'" "name = 'polybar'" ];
    };
  };
  
  programs.xwayland.enable = false;
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
    rofi
    feh
    polybar
    dunst
    xclip
    gnome-themes-extra
    adwaita-icon-theme
  ];
}
