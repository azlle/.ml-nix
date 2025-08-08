# default.nix
{ ... }:

{
  imports = [
    ./ghostty.nix
    ./mako.nix
    ./nvim.nix
    ./hypridle.nix
    ./yazi_n_opener.nix
    ./yt-dlp.nix
  ];
}
