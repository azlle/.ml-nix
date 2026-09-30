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

  # cloudflared/nextcloud は plainasia 側の担当。Forgejo だけこちらで動かす。
  myconfig.containers.cloudflared.enable = false;
  myconfig.containers.nextcloud.enable = false;

  nixos.imports = [
    ./parts/hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.asus-zephyrus-ga503
    ./parts/boot.nix
    ./parts/videodrivers.nix
    ./parts/powers.nix
    ./parts/networking.nix
    ./parts/mounts.nix
    ./parts/syncthing.nix
  ];

  home = _: {
    _module.args = { inherit inputs; };
  };
}
