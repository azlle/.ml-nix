# ghostty.nix
{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;

    settings = {
      theme = "catppuccin-mocha";
      font-size = 14;
      font-family = "HackGen Console NF";

      window-decoration = "none";
      background-opacity = "0.8";

      window-width = 120;
      window-height = 33;
      window-padding-x = 20;
      window-padding-y = 20;
    };
  };
}
