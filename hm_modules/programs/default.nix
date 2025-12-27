# default.nix
{ ... }:

{
  imports = [
    ./foot.nix
    ./git.nix
    ./hypridle.nix
    ./mako.nix
    ./nvim.nix
    ./obs.nix
    ./yazi_n_opener.nix
    ./yt-dlp.nix
  ];
}
