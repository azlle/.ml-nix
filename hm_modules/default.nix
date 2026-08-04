# default.nix
{
  username,
  homeDirectory,
  stateVersion,
  ...
}:

{
  imports = [
    ./.config
    ./nixos
    ./nixvim
    ./catppuccin.nix
    ./emacs.nix
    ./eza.nix
    ./fonts.nix
    ./gallery-dl.nix
    ./git.nix
    ./mpv.nix
    ./nh.nix
    ./ssh.nix
    ./yazi.nix
    ./yt-dlp.nix
    ./zatta.nix
    ./zoxide.nix
    ./zsh.nix
  ];

  home = {
    inherit username homeDirectory stateVersion;
    shell.enableShellIntegration = false;
  };
}
