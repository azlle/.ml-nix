# eeshta.nix
{
  nixSettings,
  ...
}:

{
  imports = [
    ../../hm_modules
  ];

  nix = nixSettings {
    extraSettings = {};
  };

  home.sessionPath = [
    "$HOME/.nix-profile/bin"
    "/nix/var/nix/profiles/default/bin"
  ];
}
