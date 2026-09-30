# hosts/plainasia/default.nix
{ delib, inputs, ... }:

delib.host {
  name = "plainasia";

  useHomeManagerModule = true;
  homeManagerUser = "keine";
  homeManagerSystem = "x86_64-linux";
  wsl = false;
  stateVersion = "25.05";
  type = "server";

  myconfig.containers.enable = true;
  # Forgejo は necrofantasia 側の担当。cloudflared/nextcloud だけこちらで動かす。
  myconfig.containers.forgejo.enable = false;

  nixos.imports = [
    ./parts/hardware-configuration.nix
    ./parts/disko.nix
    ./parts/boot.nix
    ./parts/networking.nix
    ./parts/smb.nix
    ./parts/nfs.nix
  ];

  home = _: {
    _module.args = { inherit inputs; };
  };
}
