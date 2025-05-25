# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./settings
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";

  # Enable the X11 windowing system.
  services.xserver.enable = true;
    # windowManager.gnome.enable = true;

  services.gnome.gnome-keyring.enable = true;
  programs.hyprland = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    kitty
    hyprpaper
    wofi
  ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "gb";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "uk";

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
