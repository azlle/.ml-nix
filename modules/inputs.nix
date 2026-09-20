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
    imports = lib.optional useHomeManagerModule (
      { moduleSystem, ... }:
      {
        home-manager.extraSpecialArgs = { inherit useHomeManagerModule moduleSystem; };
      }
    );

    nixpkgs.config.allowUnfree = true;
    nixpkgs.overlays = [
      inputs.niri.overlays.niri
      (import ../pkgs/niri-libdisplay-info-overlay.nix)
      inputs.nix-cachyos-kernel.overlays.pinned
      inputs.millennium.overlays.default
      (final: _prev: { git-vrc = final.callPackage ../pkgs/git-vrc.nix { }; })
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
            (import ../pkgs/niri-libdisplay-info-overlay.nix)
            inputs.nix-cachyos-kernel.overlays.pinned
            inputs.millennium.overlays.default
            (final: _prev: { git-vrc = final.callPackage ../pkgs/git-vrc.nix { }; })
          ];
        }
      )
    ];

    programs.home-manager.enable = true;
  };
}
