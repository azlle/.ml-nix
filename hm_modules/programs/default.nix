# default.nix
{ ... }:

{
  imports = [
    ./ghostty.nix
    ./nvim.nix
    ./yazi.nix
    ./yt-dlp.nix
  ];
}
