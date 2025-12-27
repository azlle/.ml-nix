# foot.nix
{ pkgs, config, ... }:

{
  programs.foot = {
    enable = true;

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

  catppuccin.foot.enable = true;
  catppuccin.foot.flavor = "mocha";
}
