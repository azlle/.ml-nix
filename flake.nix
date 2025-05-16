{
  description = "A simple NixOS flake";

  inputs = {
    #nix flake init -t templates#fullでFlakeの全構文が見れます
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.necrofantasia = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
      ];
    };
  };
}
