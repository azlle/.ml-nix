# default.nix
{ ... }:

{
  imports = [
    # ./dunst.nix
    ./mako.nix
    ./ghostty.nix
    ./nvim.nix
    ./yazi.nix
    ./yt-dlp.nix
  ];
}
