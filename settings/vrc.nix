# vrc.nix
{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    unityhub
    vrc-get
  ];
}
