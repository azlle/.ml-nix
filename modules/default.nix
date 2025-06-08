# default.nix
{ config, pkgs, ... }:

{
  imports = [
    ./system
    ./programs
  ];

  system.stateVersion = "24.11";
}
