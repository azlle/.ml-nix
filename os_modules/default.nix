# default.nix
{ stateVersion, ... }:

{
  imports = [
    ./audios.nix
    ./boot.nix
    ./fonts.nix
    ./locale.nix
    ./manager.nix
    ./mounts.nix
    ./networks.nix
    ./nh.nix
    ./nix.nix
    ./powers.nix
    ./ssh.nix
    ./sops.nix
    ./steam.nix
    ./users.nix
    ./videodrivers.nix
    ./virt.nix
  ];

  haukanRuri.enable = true;
  system.stateVersion = stateVersion;
}
