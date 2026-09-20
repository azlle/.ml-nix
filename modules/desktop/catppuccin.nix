# modules/desktop/catppuccin.nix
{ delib, inputs, ... }:
delib.module {
  name = "desktop.catppuccin";

  options = delib.singleCascadeEnableOption;

  # Importing a flake module only registers its options; it has no effect
  # until `catppuccin.enable` is actually set, so it's safe to keep this
  # import unconditional and only gate the values below.
  nixos.always.imports = [ inputs.catppuccin.nixosModules.catppuccin ];
  nixos.ifEnabled = {
    catppuccin.enable = true;
    catppuccin.autoEnable = false;
  };

  home.always.imports = [ inputs.catppuccin.homeModules.catppuccin ];
  home.ifEnabled = {
    catppuccin.enable = true;
    catppuccin.autoEnable = false;
  };
}
