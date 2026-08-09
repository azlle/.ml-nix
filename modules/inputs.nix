# modules/inputs.nix
# Flake-input plumbing that doesn't belong to any single feature module.
{
  delib,
  inputs,
  useHomeManagerModule,
  lib,
  ...
}:
delib.module {
  name = "inputs";

  nixos.always = {
    imports = [
      # only one NixOS host exists.
      inputs.nixos-hardware.nixosModules.asus-zephyrus-ga503
    ]
    # lib.mkIf can't hide `home-manager.*` when the option doesn't exist.
    ++ lib.optional useHomeManagerModule (
      { moduleSystem, ... }:
      {
        home-manager.extraSpecialArgs = { inherit useHomeManagerModule moduleSystem; };
      }
    );

    nixpkgs.config.allowUnfree = true;
    nixpkgs.overlays = [
      inputs.niri.overlays.niri
      inputs.nix-cachyos-kernel.overlays.pinned
      inputs.millennium.overlays.default
    ];
  }
  // lib.optionalAttrs useHomeManagerModule {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };

  home.always = {
    imports = [
      # useGlobalPkgs forbids per-user nixpkgs.* on top of it.
      (
        {
          useHomeManagerModule,
          moduleSystem,
          lib,
          ...
        }:
        lib.mkIf (!(useHomeManagerModule && moduleSystem == "nixos")) {
          nixpkgs.config.allowUnfree = true;
          nixpkgs.overlays = [
            inputs.niri.overlays.niri
            inputs.nix-cachyos-kernel.overlays.pinned
            inputs.millennium.overlays.default
          ];
        }
      )
    ];

    programs.home-manager.enable = true;
  };
}
