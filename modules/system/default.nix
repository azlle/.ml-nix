# default.nix
{
  imports = [
    ./audios.nix
    ./boot.nix
    ./fonts.nix
    ./locale.nix
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
