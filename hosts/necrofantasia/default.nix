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

  # cloudflared/nextcloud/forgejo は全部plainasia側の担当。このホストは
  # ノートPCで常時起動ではないので、コンテナ類はどれも持たない。
  myconfig.containers.cloudflared.enable = false;
  myconfig.containers.nextcloud.enable = false;
  myconfig.containers.forgejo.enable = false;

  nixos.imports = [
    ./parts/hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.asus-zephyrus-ga503
    ./parts/boot.nix
    ./parts/videodrivers.nix
    ./parts/powers.nix
    ./parts/networking.nix
    ./parts/syncthing.nix
  ];

  home = _: {
    _module.args = { inherit inputs; };
  };
}
