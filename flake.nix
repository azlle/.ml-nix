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
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix";

    blender-bin.url = "github:edolstra/nix-warez?dir=blender";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-hardware,
      home-manager,
      lanzaboote,
      catppuccin,
      blender-bin,
      ...
    }@inputs: {

    nixosConfigurations = {
      necrofantasia = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
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
}
