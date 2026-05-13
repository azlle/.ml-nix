# zatta.nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    unar libarchive xz zstd
    gh rsync openssh zellij
    htop curl bat ffmpeg
    age ssh-to-age sops
    treefmt statix deadnix nixfmt
  ];
}
