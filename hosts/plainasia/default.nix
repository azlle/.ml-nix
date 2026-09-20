# hosts/plainasia/default.nix
{ delib, inputs, ... }:
delib.host {
  name = "plainasia";

  useHomeManagerModule = true;
  homeManagerUser = "eeshta";
  homeManagerSystem = "x86_64-linux";
  wsl = false;
  stateVersion = "25.05"; # インストールに使うISOのリリースに合わせて固定(以後変更しないこと)
  type = "server";

  # Forgejo / cloudflared はまだ necrofantasia で動いている。同じコンテナと
  # 同一トンネルUUIDが2台で立ち上がるのを防ぐため、移行を実施するまで明示的に切る。
  # 引っ越し時はここを true にして necrofantasia 側を false にする。
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
