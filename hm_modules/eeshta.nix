# eeshta.nix
{
  pkgs,
  lib,
  username,
  hostname,
  homeDirectory,
  stateVersion,
  ...
}:

{
  imports = [
    ./.config
    ./emacs.nix
    ./eza.nix
    ./fonts.nix
    ./gallery-dl.nix
    ./git.nix
    ./mpv.nix
    ./yazi.nix
    ./yt-dlp.nix
    ./zatta.nix
    ./zoxide.nix
    ./zsh.nix
  ];

  programs.home-manager.enable = true;

  home = {
    inherit username homeDirectory stateVersion;
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
      source = ../artworks/nix-wallpaper-simple-dark-gray_mellomixed.png;
    };
    "eeshta_icon.png" = {
      target = "Pictures/eeshta_icon.png";
      source = ../artworks/IMG_4900_foricon.png;
    };
  };
}
