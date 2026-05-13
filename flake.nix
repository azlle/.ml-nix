{
  description = "A simple NixOS flake";

  inputs = {
    #nix flake init -t templates#fullでFlakeの全構文が見れます
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    emacs-overlay.url = "github:nix-community/emacs-overlay";

    catppuccin.url = "github:catppuccin/nix";

    blender-bin.url = "github:edolstra/nix-warez?dir=blender";

    niri.url = "github:sodiboo/niri-flake";

    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    bunny-yazi = {
      url = "github:stelcodes/bunny.yazi";
      flake = false;
    };

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    millennium.url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ml-secrets = {
      url = "git+ssh://git@ssh.upd.dev/Azlle/.nix_ml-secrets.git?shallow=1";
      flake = false;
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixos-hardware,
    home-manager,
    lanzaboote,
    emacs-overlay,
    catppuccin,
    blender-bin,
    niri,
    aagl,
    bunny-yazi,
    nix-cachyos-kernel,
    millennium,
    sops-nix,
    ml-secrets,
    zen-browser,
    ...
  }@inputs:

    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          emacs-overlay.overlays.default
          niri.overlays.niri
          nix-cachyos-kernel.overlays.pinned
          millennium.overlays.default
        ];
      };

      createNixosConfiguration =
        {
          username,
          hostname,
          homeDirectory ? "/home/${username}",
          stateVersion ? "24.11",
          extraHomeModules ? [],
          extraModules ? [],
        }:
        nixpkgs.lib.nixosSystem {
          inherit system pkgs;
          specialArgs = { inherit inputs username hostname homeDirectory stateVersion; };
          modules = [
            ./os_modules
            lanzaboote.nixosModules.lanzaboote
            catppuccin.nixosModules.catppuccin
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                extraSpecialArgs = { inherit inputs username hostname homeDirectory stateVersion; };
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${username}.imports =
                  [ ./hm_modules/${username}.nix catppuccin.homeModules.catppuccin ]
                  ++ extraHomeModules;
              };
            }
            sops-nix.nixosModules.sops
          ] ++ extraModules;
        };

      createHome =
        {
          username,
          hostname,
          homeDirectory ? "/home/${username}",
          stateVersion ? "24.11",
          extraHomeModules ? [],
        }:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit inputs username homeDirectory hostname stateVersion; };
          modules = [
            ./hm_modules/${username}.nix
            catppuccin.homeModules.catppuccin
            {
              home = { inherit username homeDirectory stateVersion; };
              programs.home-manager.enable = true;
            }
          ] ++ extraHomeModules;
        };
    in {

    nixosConfigurations = {
      necrofantasia = createNixosConfiguration {
        username = "eeshta";
        hostname = "necrofantasia";
        extraHomeModules = [
          ./hm_modules/nixos
          zen-browser.homeModules.twilight
        ];
        extraModules = [
          ./machines/ga503_hardware.nix

          nixos-hardware.nixosModules.asus-zephyrus-ga503
          niri.nixosModules.niri
          { imports = [ aagl.nixosModules.default ];
            programs.sleepy-launcher.enable = true; }
        ];
      };

    homeConfigurations."sumizomenosakura" = createHome {
      username = "miyu";
      hostname = "sumizomenosakura";
      extraHomeModules = [];
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"   # emacs-overlay et al.
      "https://attic.xuyh0120.win/lantian" # nix-cachyos-kernel (Hydra CI)
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
    ];
  };
}
