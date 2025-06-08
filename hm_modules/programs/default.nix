# default.nix
{ ... }:

{
  imports = [
    ./ghostty.nix
    ./nvim.nix
    ./yazi.nix
  ];
}
