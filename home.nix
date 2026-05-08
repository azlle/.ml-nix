# home.nix
{ config, pkgs, ... }:

{
  imports = [ ./hm_modules ];

  programs.home-manager.enable = true;

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "24.11";
    shell.enableShellIntegration = false;
  };

  nix = lib.mkIf (hostname == "sumizomenosakura") {
    package = pkgs.nixVersions.stable;
  };

  home.sessionPath = lib.mkIf (hostname == "sumizomenosakura") [
    "$HOME/.nix-profile/bin"
    "/nix/var/nix/profiles/default/bin"
  ];

  home = rec {
    username = "eeshta";
    homeDirectory = "/home/${username}";
    stateVersion = "25.05";
  };

  home.file = {
    "eeshta_wallpaper.png" = {
      target = "Pictures/eeshta_wallpaper.png";
      source = ./artworks/nix-wallpaper-simple-dark-gray_mellomixed.png;
    };
    "eeshta_icon.png" = {
      target = "Pictures/eeshta_icon.png";
      source = ./artworks/IMG_4900_foricon.png;
    };
  };
}
