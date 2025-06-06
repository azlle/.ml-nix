# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./modules
    ];

  # Bootloader and Kernel.
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";

  environment.systemPackages = with pkgs; [
  ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "jp";
    variant = "";
    model = "jp106";
    options = "";
  };

  # Configure console keymap
  console.keyMap = "jp106";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  programs = {
    firefox = {
      enable = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.11";

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
}
