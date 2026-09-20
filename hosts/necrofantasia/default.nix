# hosts/necrofantasia/default.nix
{ delib, inputs, ... }:
delib.host {
  name = "necrofantasia";

  useHomeManagerModule = true;
  homeManagerUser = "eeshta";
  homeManagerSystem = "x86_64-linux";
  wsl = false;
  stateVersion = "24.11";
  type = "laptop";

  nixos.imports = [
    ./parts/hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.asus-zephyrus-ga503
    ./parts/boot.nix
    ./parts/videodrivers.nix
    ./parts/powers.nix
    ./parts/networking.nix
  ];

  home = _: {
    _module.args = { inherit inputs; };
  };
}
