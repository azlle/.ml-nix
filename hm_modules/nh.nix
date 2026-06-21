# hm_modules/nh.nix
{ homeDirectory, ... }:

{
  programs.nh = {
    enable = true;
    flake = "${homeDirectory}/.nix_ml";
  };
}
