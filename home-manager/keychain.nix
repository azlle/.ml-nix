# keychain.nix
{
  programs.keychain = {
    enable = true;
    agents = [ "ssh" ];
    keys = [ "nix-git_ed25519" ];
    inheritType = "any";
    extraFlags = [ "--quiet" ];
  };
}
