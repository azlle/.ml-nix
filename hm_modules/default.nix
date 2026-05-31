# default.nix
{ ... }:

{
  imports = [
    ./.config
    ./emacs.nix
    ./eza.nix
    ./fonts.nix
    ./gallery-dl.nix
    ./git.nix
    ./mpv.nix
    ./nvim.nix
    ./yazi.nix
    ./yt-dlp.nix
    ./zatta.nix
    ./zoxide.nix
    ./zsh.nix
  ];
}
