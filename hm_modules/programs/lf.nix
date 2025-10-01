# lf.nix
{ pkgs, ... }:

{
  programs.lf = {
    enable = true;
    settings = {
      icons = true;
    };
  };
}
