# vrc.nix
{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vrcx
    unityhub
    vrc-get
  ];
}
