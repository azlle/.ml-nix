# default.nix
{ ... }:

{
  imports = [
    ./foot.nix
    ./hypridle.nix
    ./mako.nix
    ./nixcord.nix
    ./obs.nix
    ./zen-browser.nix
  ];
}
