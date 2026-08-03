# nix.nix
{ nixSettings, username, ... }:

{
  nix = nixSettings {
    extraSettings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        "${username}"
      ];
    };
  };
}
