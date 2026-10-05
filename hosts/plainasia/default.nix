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
  # Forgejo も necrofantasia (ノートPC、常時起動ではない) からこちらに移した。
  # cloudflared/nextcloud/forgejo が全部同居する。

  nixos.imports = [
    ./parts/hardware-configuration.nix
    ./parts/disko.nix
    ./parts/boot.nix
    ./parts/networking.nix
    ./parts/smb.nix
    ./parts/nfs.nix
    ./parts/alerts.nix
  ];

  home = _: {
    _module.args = { inherit inputs; };
  };
}
