# hosts/sumizomenosakura/default.nix
{ delib, nixSettings, ... }:
delib.host {
  name = "sumizomenosakura";

  useHomeManagerModule = false;
  homeManagerUser = "eeshta";
  system = "x86_64-linux";
  wsl = true;
  stateVersion = "24.11";

  home = {
    nix = nixSettings { extraSettings = { }; };

    home.sessionPath = [
      "$HOME/.nix-profile/bin"
      "/nix/var/nix/profiles/default/bin"
    ];
  };
}
