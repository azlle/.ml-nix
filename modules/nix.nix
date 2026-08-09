# modules/nix.nix
{ delib, nixSettings, ... }:
delib.module {
  name = "nix";

  nixos.always = {
    nix = nixSettings {
      extraSettings = {
        auto-optimise-store = true;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        trusted-users = [
          "root"
          "eeshta"
        ];
      };
    };
  };
}
