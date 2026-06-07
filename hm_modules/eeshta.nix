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
    ./nixvim
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
}
