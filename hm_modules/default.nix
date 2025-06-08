# default.nix
{ ... }:

{
  imports = [
    ./.config
    ./programs
  ];
}
