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
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-hardware,
      home-manager,
      lanzaboote,
      ...
    }@inputs: {

    nixosConfigurations = {
      necrofantasia = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { hostType = "necrofantasia"; };
        modules = [
          ./modules
          ./machines/ga503_hardware.nix

          nixos-hardware.nixosModules.asus-zephyrus-ga503

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.eeshta = ./home.nix;
          }

          lanzaboote.nixosModules.lanzaboote
        ];
      };

      cosmicmind = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { hostType = "cosmicmind"; };
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
        ];
      };
    };
  };
}
