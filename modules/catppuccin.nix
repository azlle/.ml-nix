# modules/catppuccin.nix
{ delib, inputs, ... }:
delib.module {
  name = "catppuccin";

  nixos.always = {
    imports = [ inputs.catppuccin.nixosModules.catppuccin ];
    catppuccin.enable = true;
    catppuccin.autoEnable = false;
  };

  home.always = {
    imports = [ inputs.catppuccin.homeModules.catppuccin ];
    catppuccin.enable = true;
    catppuccin.autoEnable = false;
  };
}
