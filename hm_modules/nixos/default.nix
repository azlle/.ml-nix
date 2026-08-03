# default.nix
{ ... }:

{
  imports = [
    ./foot.nix
    ./git-forgejo-access.nix
    ./hypridle.nix
    ./mako.nix
    ./nixcord.nix
    ./obs.nix
    ./wezterm.nix
    ./zen-browser.nix
  ];
}
