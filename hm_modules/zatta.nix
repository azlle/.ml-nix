# zatta.nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    unar libarchive xz zstd
    gh rsync openssh zellij
    htop curl bat ffmpeg
    treefmt statix deadnix nixfmt
  ];
}
