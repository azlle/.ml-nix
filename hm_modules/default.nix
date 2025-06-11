# default.nix
{ ... }:

{
  imports = [
    ./.config
    ./programs
    ./sway.nix
  ];
}
