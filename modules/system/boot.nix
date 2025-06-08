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

    # nix shell nixpkgs#sbctl -> sudo sbctl create-keys -> rebuild -> reboot
    # BIOS: Secure Boot Enable -> Reset to Setup Mode -> Save & Exit
    # sudo sbctl enroll-keys --microsoft -> reboot -> bootctl status 
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
  };

  environment.systemPackages = with pkgs; [ sbctl ];
}
