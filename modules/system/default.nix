# default.nix
{
  imports = [
    ./audios.nix
    ./boot.nix
    ./fonts.nix
    ./locale.nix
    ./manager.nix
    ./mounts.nix
    ./networks.nix
    ./nix.nix
    ./powers.nix
    ./ssh.nix
    ./users.nix
    ./videodrivers.nix
  ];

  haukanRuri.enable = false;
}
