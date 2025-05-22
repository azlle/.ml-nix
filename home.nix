# home.nix
{ config, pkgs, ... }:

{
  imports = [
    ./home-manager/ghostty.nix
  ];

  home = rec {
    username = "eeshta";
    homeDirectory = "/home/${username}";
    stateVersion = "25.05";
  };
}
