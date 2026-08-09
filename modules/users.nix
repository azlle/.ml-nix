# modules/users.nix
{ delib, inputs, ... }:
delib.module {
  name = "users";

  nixos.always = {
    imports = [
      inputs.aagl.nixosModules.default
      (
        {
          config,
          inputs,
          pkgs,
          ...
        }:
        {
          nixpkgs.overlays = [
            (_final: prev: {
              steam-run = prev.steam-run-free;
            })
          ];

          users.users.eeshta = {
            isNormalUser = true;
            hashedPasswordFile = config.sops.secrets."users/password/eeshta".path;
            description = "eeshta";
            shell = pkgs.zsh;
            ignoreShellProgramCheck = true;
            openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILSkZhHC1jkM6y4CO7tES6lLIADXbtoMUsyNJX66WreR deb2nix"
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB//5g0hW9QRnuPsg3PiFxxY47/HIak79nOF0CaGRiNS xia2nix"
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ1cTfNrr9TVn8ptmbB4pOuN2uJQ3Tu9XkMn69NYsoFq gal2nix"
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJu6dRiFbEBV0R47xyDc6KEIXWqET3dQnQeBrisSrJCy pmos2nix"
            ];
            extraGroups = [ "wheel" ];
            packages = with pkgs; [
              protonup-rs

              wineWow64Packages.waylandFull
              winetricks

              (prismlauncher.override {
                jdks = [
                  temurin-jre-bin-8
                  temurin-jre-bin-17
                  temurin-jre-bin
                ];
              })

              # unityhub
              # vrc-get
              # gimp3
              inputs.blender-bin.packages.x86_64-linux.blender_4_1

              steamcmd
            ];
          };

          programs = {
            honkers-railway-launcher.enable = true;

            thunar.enable = true;
            xfconf.enable = true;

            firefox.enable = true;
            thunderbird.enable = true;
          };
        }
      )
    ];
  };
}
