# hosts/plainasia/default.nix
{ delib, inputs, ... }:

delib.host {
  name = "plainasia";

  useHomeManagerModule = true;
  homeManagerUser = "eeshta";
  homeManagerSystem = "x86_64-linux";
  wsl = false;
  stateVersion = "25.05";
  type = "server";

  # ForgejoとTrueNASを移行する目処が立ったのならtrueに
  myconfig.containers.enable = false;

  nixos.imports = [
    ./parts/hardware-configuration.nix
    ./parts/disko.nix
    ./parts/boot.nix
    ./parts/networking.nix
  ];

  home = _: {
    _module.args = { inherit inputs; };
  };
}
