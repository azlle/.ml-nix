# nix.nix
{ pkgs, username, ... }:

{
  nix = {
    package = pkgs.nixVersions.stable;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      warn-dirty = false;
      http-connections = 50;
      trusted-users = [
        "root"
        "${username}"
      ];
    };

    gc = {
      automatic = false;
      persistent = true;
      dates = "Sun 02:00";
      options = "--delete-older-than 7d";
    };
  };
}
