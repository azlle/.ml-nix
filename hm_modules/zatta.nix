# zatta.nix
{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    unar libarchive xz zstd
    gh rsync openssh zellij
    htop curl bat ffmpeg
  ];
}
