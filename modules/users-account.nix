# modules/users-account.nix
{ delib, ... }:
delib.module {
  name = "users-account";

  nixos.always = {
    users.mutableUsers = false;
    imports = [
      (
        { config, pkgs, ... }:
        {
          users.users.eeshta = {
            isNormalUser = true;
            hashedPasswordFile = config.sops.secrets."users/password/eeshta".path;
            description = "eeshta";
            shell = pkgs.zsh;
            ignoreShellProgramCheck = true;
            openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGyuJWopJaUAanlMrmjGYoSxGPy3mPxiA+BxWHtiJY2h fantasia-to-asia"
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILSkZhHC1jkM6y4CO7tES6lLIADXbtoMUsyNJX66WreR deb2nix"
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ1cTfNrr9TVn8ptmbB4pOuN2uJQ3Tu9XkMn69NYsoFq gal2nix"
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJu6dRiFbEBV0R47xyDc6KEIXWqET3dQnQeBrisSrJCy pmos2nix"
            ];
            extraGroups = [ "wheel" ];
          };
        }
      )
    ];
  };
}
