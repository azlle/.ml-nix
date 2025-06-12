# default.nix
{ ... }:

{
  imports = [
    ./.config
    ./programs
    ./hyprland.nix
  ];
}
