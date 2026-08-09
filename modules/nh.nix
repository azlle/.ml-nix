# modules/nh.nix
{ delib, ... }:
delib.module {
  name = "nh";

  nixos.always = {
    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 7d --keep 3";
      };
    };
  };

  home.always = {
    imports = [
      (
        { config, ... }:
        {
          programs.nh = {
            enable = true;
            flake = "${config.home.homeDirectory}/.ml-nix";
          };
        }
      )
    ];
  };
}
