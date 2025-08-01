# git.nix
{ pkgs, config, ... }:

{
  programs.git = {
    enable = true;
    config = {
      user.name = "Azlle";
      user.email = "moxmo2@pm.me";

      core.editor = "nvim";
      core.autocrlf = "input";

      merge.ff = "false";
      pull.ff = "only";
    };
  };
}
