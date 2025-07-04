# users.nix
{ config, lib, pkgs, inputs, ... }:

{
  users.users.eeshta = {
    isNormalUser = true;
    hashedPassword = "***REMOVED***";
    description = "eeshta";
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHh60Pl9Y6ns/1cNY6kZC4AF/M1yXwbWL3OibsRSdp6X NixOS" ];
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      krusader
      protonup-qt
      vesktop
      obsidian
      zoom-us
      imv

      # 主に東方向け
      #wineWowPackages.stagingFull
      wineWowPackages.waylandFull
      winetricks

      # Minecraftのヤツ
      (prismlauncher.override {
        jdks = [
          temurin-jre-bin-8
          temurin-jre-bin-17
          temurin-jre-bin
        ];
      })

      # 作業系など
      unityhub
      vrc-get
      gimp3
      inputs.blender-bin.packages.x86_64-linux.blender_4_1
    ];
  };

  programs = {
    thunar.enable = true;
    xfconf.enable = true;
    thunderbird.enable = true;
  };
}
