# modules/foot.nix
{ delib, ... }:
delib.module {
  name = "foot";

  home.always = {
    programs.foot = {
      enable = true;

      settings = {
        main = {
          font = "Moralerspace Neon HW:size=14";
          pad = "20x20";
        };
        colors = {
          alpha = 0.8;
        };
      };
    };

    catppuccin.foot.enable = true;
    catppuccin.foot.flavor = "mocha";
  };
}
