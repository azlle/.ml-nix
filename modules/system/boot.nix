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

    # 先にnix shell nixpkgs#sbctlなどしてsudo sbctl create-keysしておく
    # BIOSでSBを有効化し、Reset to Setup Modeする
    # sudo sbctl enroll-keys --microsoftして、bootctlでSBが有効なのを確認する
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
  };

  environment.systemPackages = with pkgs; [ sbctl ];
}
