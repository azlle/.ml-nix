# zatta.nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    age
    bat
    btop
    claude-code
    curl
    ffmpeg
    gh
    htop
    libarchive
    openssh
    rsync
    sops
    ssh-to-age
    unar
    xz
    zellij
    zstd
  ];
}
