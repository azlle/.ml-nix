# de.nix
{ config, lib, pkgs, ... }:

{
  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    loader = {
      systemd-boot.enable = lib.mkForce false;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    };

    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl"; # 先にnix shell nixpkgs#sbctlなどしてsudo sbctl create-keysしておく
    };
  };

  environment.systemPackages = with pkgs; [ sbctl ];
}
