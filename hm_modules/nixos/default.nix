# default.nix
{ ... }:

{
  imports = [
    ./foot.nix
    ./hypridle.nix
    ./mako.nix
    ./obs.nix
  ];
}
