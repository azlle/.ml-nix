# hosts/necrofantasia/default.nix
{ delib, inputs, ... }:
delib.host {
  name = "necrofantasia";

  useHomeManagerModule = true;
  homeManagerUser = "eeshta";
  homeManagerSystem = "x86_64-linux";
  wsl = false;
  stateVersion = "24.11";

  nixos.imports = [ ./hardware-configuration.nix ];

  home = _: {
    _module.args = { inherit inputs; };
  };
}
