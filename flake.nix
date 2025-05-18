{
  description = "A simple NixOS flake";

  inputs = {
    #nix flake init -t templates#fullでFlakeの全構文が見れます
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, nixos-hardware, ... }@inputs: {
    nixosConfigurations.necrofantasia = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
	nixos-hardware.nixosModules.asus-zephyrus-ga503
      ];
    };
  };
}
