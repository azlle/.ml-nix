# modules/user.nix
{ delib, ... }:
delib.module {
  name = "user";

  nixos.always = {
    imports = [
      (
        { stateVersion, ... }:
        {
          system.stateVersion = stateVersion;
        }
      )
    ];
  };

  home.always = {
    imports = [
      (
        { username, stateVersion, ... }:
        {
          home = {
            inherit username stateVersion;
            homeDirectory = "/home/${username}";
            shell.enableShellIntegration = false;
          };
        }
      )
    ];
  };
}
