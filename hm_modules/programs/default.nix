# default.nix
{ ... }:

{
  imports = [
    ./dunst.nix
    ./ghostty.nix
    ./nvim.nix
    ./yazi.nix
    ./yt-dlp.nix
  ];
}
