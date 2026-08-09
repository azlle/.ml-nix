# modules/eza.nix
{ delib, ... }:
delib.module {
  name = "eza";

  home.always = {
    programs.eza = {
      enable = true;

      extraOptions = [
        "--group-directories-first"
        "--color=always"
        "--icons"
        "--git"
      ];
    };
  };
}
