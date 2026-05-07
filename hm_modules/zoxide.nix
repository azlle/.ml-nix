# zoxide.nix
{ pkgs, ... }:

{
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;

    options = [
      "--cmd cd"
      "--hook prompt"
    ];
  };
}
