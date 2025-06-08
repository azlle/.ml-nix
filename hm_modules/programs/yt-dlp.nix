# nvim.nix
{ config, pkgs, ... }:

{
  programs.yt-dlp = {
    enable = true;
    settings = {
    };
  };
}
