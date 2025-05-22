{ pkgs, config, ... }:

{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      set fish_greeting
    '';

    shellAbbrs = {
      la = "ls -ahl --group-directories-first";

      #nix
      nrsfn = "sudo nixos-rebuild switch --flake ~/.dotfiles#necrofantasia";
      npwh = "nix profile wipe-history";
      nsgc = "nix store gc";

      #git
      gst = "git status";
      gcm = "git commit -m";
      gl = "git log --graph --date=iso --pretty='format:%C(yellow)%h %C(cyan)%ad %C(green)%an%Creset%x09%s %C(red)%d%Creset'";
    };
  };
}
