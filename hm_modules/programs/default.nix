# default.nix
{ ... }:

{
  imports = [
    ./lf.nix
    ./mako.nix
    ./nvim.nix
    ./hypridle.nix
    ./yazi_n_opener.nix
    ./yt-dlp.nix
  ];
}
