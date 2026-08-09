# modules/host-args.nix
{ delib, ... }:
delib.module {
  name = "host-args";

  myconfig.always =
    { myconfig, ... }:
    {
      args.shared = {
        username = myconfig.host.homeManagerUser;
        hostname = myconfig.host.name;
        inherit (myconfig.host) wsl stateVersion;
      };
    };
}
