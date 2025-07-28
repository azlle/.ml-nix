# default.nix
{ ... }:

{
  imports = [
    ./ghostty.nix
    ./mako.nix
    ./mpv.nix
    ./nvim.nix
    ./yazi.nix
    ./yt-dlp.nix
  ];
}
