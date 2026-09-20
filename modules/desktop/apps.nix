# modules/desktop/apps.nix
{
  delib,
  inputs,
  pkgs,
  ...
}:
delib.module {
  name = "desktop.apps";

  options = delib.singleCascadeEnableOption;

  # aagl only registers its options here; it has no effect until enabled below.
  nixos.always.imports = [ inputs.aagl.nixosModules.default ];

  nixos.ifEnabled = {
    nixpkgs.overlays = [
      (_final: prev: {
        steam-run = prev.steam-run-free;
      })
    ];

    users.users.eeshta.packages = [
      pkgs.protonup-rs

      pkgs.wineWow64Packages.waylandFull
      pkgs.winetricks

      (pkgs.prismlauncher.override {
        jdks = with pkgs; [
          temurin-jre-bin-8
          temurin-jre-bin-17
          temurin-jre-bin
        ];
      })

      # unityhub
      # vrc-get
      # gimp3
      inputs.blender-bin.packages.x86_64-linux.blender_4_1

      pkgs.steamcmd
    ];

    programs = {
      honkers-railway-launcher.enable = true;

      thunar.enable = true;
      xfconf.enable = true;

      firefox.enable = true;
      thunderbird.enable = true;
    };

    hardware.bluetooth.enable = true;
  };
}
