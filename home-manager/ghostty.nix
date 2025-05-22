# ghostty.nix
{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;

    settings = {
      font-size = 12;
      font-family = "HackGen Console NF";

      theme = "Monokai Soda";
      background-opacity = "0.8";
      window-width = 120;
      window-height = 33;
    };
  };
}
