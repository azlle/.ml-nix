# default.nix
{
  imports = [
    ./audios.nix
    ./boot.nix
    ./fonts.nix
    ./i18n.nix
    ./mounts.nix
    ./networks.nix
    ./nix.nix
    ./powers.nix
    ./ssh.nix
    ./users.nix
    ./videodrivers.nix
    ./xserver.nix
  ];
}
