# default.nix
{
  imports = [
    ./audios.nix
    ./fonts.nix
    ./i18n.nix
    ./networks.nix
    ./powers.nix
    ./ssh.nix
    ./users.nix
  ];
}
