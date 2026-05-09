# os_modules/nh.nix
{ homeDirectory, ... }:

{
  programs.nh = {
    enable = true;
    flake = "${homeDirectory}/.nix_ml";
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d --keep 3";
    };
  };
}
