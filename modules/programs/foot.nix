# foot.nix
{ pkgs, config, ... }:

{
  programs.foot = {
    enable = true;
    theme = "catppuccin-mocha";
    enableFishIntegration = true;

    settings = {
      main = {
        font = "HackGen Console NF:size=14";
        pad = "20x20";
      };
      colors = {
        alpha = 0.8;
      };
    };
  };
}
