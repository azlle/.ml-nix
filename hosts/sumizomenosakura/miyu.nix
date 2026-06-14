# eeshta.nix
{
  pkgs,
  ...
}:

{
  imports = [
    ../../hm_modules
  ];

  nix = {
    package = pkgs.nixVersions.stable;
  };

  home.sessionPath = [
    "$HOME/.nix-profile/bin"
    "/nix/var/nix/profiles/default/bin"
  ];
}
