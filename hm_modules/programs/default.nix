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
    ./yazi.nix
    ./yt-dlp.nix
  ];
}
