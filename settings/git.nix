# git.nix
{ pkgs, config, ... }:

{
  programs.git = {
    enable = true;
    config = {
      user.name = "Azlle";
      user.email = "moxmo2@pm.me";

      core.editor = "nano";
      core.autocrlf = "input";
    };
  };
}
