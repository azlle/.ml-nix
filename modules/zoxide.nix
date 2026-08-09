# modules/zoxide.nix
{ delib, ... }:
delib.module {
  name = "zoxide";

  home.always = {
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;

      options = [
        "--cmd cd"
        "--hook prompt"
      ];
    };
  };
}
