# nvim.nix
{ config, pkgs, ... }:

{
  programs.yazi = {
    enable = true;
    settings = {
      mgr = {
        show_hidden = true;
        mouse_events = [];
      };
    };
  };
}
