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

      function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
      end
    '';

    shellAbbrs = {
      la = "ls -ahl --group-directories-first";
      rmtrash = "rm -rf ~/.local/share/Trash/files/*";
      nano = "nvim";

      #nix
      nrsfn = "sudo nixos-rebuild switch --flake ~/.dotfiles#necrofantasia";
      nrsfc = "sudo nixos-rebuild switch --flake ~/.dotfiles#cosmicmind";
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
