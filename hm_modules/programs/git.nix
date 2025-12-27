# git.nix
{ pkgs, config, ... }:

{
  programs.git.enable = true;

  programs.git.settings = {
    user = {
      name = "Azlle";
      email = "moxmo2@pm.me";
    };
    core = {
      editor = "nvim";
      autocrlf = "input";
      filemode = "false";
      quotepath = "false";
    };
    merge.ff = "false";
    pull.ff = "only";
  };
}
