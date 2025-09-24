# default.nix
{ ... }:

{
  imports = [
    ./mako.nix
    ./nnn.nix
    ./nvim.nix
    ./hypridle.nix
    ./yazi_n_opener.nix
    ./yt-dlp.nix
  ];
}
