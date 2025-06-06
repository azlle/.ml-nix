# fish.nix
{ pkgs, config, ... }:

{
  environment.systemPackages = with pkgs; [
    keychain
  ];
    
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      set fish_greeting
      if command -v keychain > /dev/null
        eval (keychain --eval --quiet nix-git_ed25519)
      end
    '';

    shellAbbrs = {
      la = "ls -ahl --group-directories-first";

      #nix
      nrsfn = "sudo nixos-rebuild switch --flake ~/.dotfiles#necrofantasia";
      npwh = "nix profile wipe-history";
      nsgc = "nix store gc";
      nedg = "sudo nix-env --delete-generations +3 --profile /nix/var/nix/profiles/system";

      #git
      gst = "git status";
      gcm = "git commit -m";
      gl = "git log --graph --date=iso --pretty='format:%C(yellow)%h %C(cyan)%ad %C(green)%an%Creset%x09%s %C(red)%d%Creset'";
    };
  };
}
