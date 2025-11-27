{ pkgs, ... }:

{
  programs.zsh.enable = true;
  programs.oh-my-posh.enable = true;
  programs.oh-my-posh.enableZshIntegration = true;
}
