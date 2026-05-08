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
      url = "github:nix-community/lanzaboote/v0.4.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
    };

    millennium = {
      url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";
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
      commonSpecialArgs  = { inherit inputs; };
      commonHmModules  = [
        ./home.nix
        catppuccin.homeModules.catppuccin
      ];

      mkHost = { hostname, extraModules ? [], users }:
        nixpkgs.lib.nixosSystem {
          inherit system pkgs;
          specialArgs = commonSpecialArgs // { inherit hostname; };
          modules = [
            ./os_modules
            lanzaboote.nixosModules.lanzaboote
            catppuccin.nixosModules.catppuccin
            home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = commonSpecialArgs // { inherit hostname; };
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users = nixpkgs.lib.mapAttrs (username: userCfg: {
                imports = commonHmModules ++ (userCfg.hmModules or []);
                _module.args.username = username;
              }) users;
            }
          ] ++ extraModules;
        };

      mkHome = { hostname, username, hmModules ? [] }:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = commonSpecialArgs // { inherit hostname username; };
          modules = commonHmModules ++ hmModules;
        };
    in {

    nixosConfigurations = {
      necrofantasia = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
          overlays = [ niri.overlays.niri ];
        };
        specialArgs = {
          hostType = "necrofantasia";
          inherit inputs;
        };
        modules = [
          ./modules
          ./machines/ga503_hardware.nix

          nixos-hardware.nixosModules.asus-zephyrus-ga503

          home-manager.nixosModules.home-manager

          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.eeshta = {
              imports = [
                ./home.nix
                catppuccin.homeModules.catppuccin
              ];
            };
          }

          lanzaboote.nixosModules.lanzaboote

          catppuccin.nixosModules.catppuccin

          niri.nixosModules.niri

          {
            imports = [ aagl.nixosModules.default ];
            programs.sleepy-launcher.enable = true;
          }
        ];
      };

      cosmicmind = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          hostType = "cosmicmind";
          inherit inputs;
        };
        modules = [
          ./modules
          ./machines/intelvm_hardware.nix

          # nixos-hardware.nixosModules.asus-zephyrus-ga503

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.eeshta = ./home.nix;
          }

          lanzaboote.nixosModules.lanzaboote

          catppuccin.nixosModules.catppuccin
        ];
      };
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
