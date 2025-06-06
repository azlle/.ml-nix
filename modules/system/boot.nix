# de.nix
{ config, lib, pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_zen;

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 5;
  };

  boot.loader.efi.canTouchEfiVariables = true;
}
