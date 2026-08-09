# modules/sops.nix
{
  delib,
  inputs,
  lib,
  ...
}:
let
  ageKeyFile = "/var/lib/sops-nix/sops_mm";
  defaultSopsFile = "${inputs.ml-secrets}/secret.yaml";
in
delib.module {
  name = "sops";

  nixos.always = {
    imports = [
      inputs.sops-nix.nixosModules.sops
      (
        { username, ... }:
        let
          homeDirectory = "/home/${username}";
        in
        {
          sops = {
            age.keyFile = ageKeyFile;
            inherit defaultSopsFile;
            secrets = {
              "smb/yamaxanadu" = { };

              "users/password/eeshta" = {
                neededForUsers = true;
              };

              "wireless/password" = {
                path = "/run/secrets/wireless.conf";
                owner = "wpa_supplicant";
              };

              "wireless/hkrr_password" = { };

              "cloudflared/git-tunnel" = {
                path = "/run/secrets/cloudflared-git-tunnel-credentials.json";
              };

              "eeshta_icon" = {
                format = "binary";
                sopsFile = "${inputs.ml-secrets}/artworks/IMG_4900_foricon.png.enc";
                path = "${homeDirectory}/Pictures/eeshta_icon.png";
                owner = username;
                mode = "0444";
              };

              "eeshta_wallpaper" = {
                format = "binary";
                sopsFile = "${inputs.ml-secrets}/artworks/nix-wallpaper-simple-dark-gray_mellomixed.png.enc";
                path = "${homeDirectory}/Pictures/eeshta_wallpaper.png";
                owner = username;
                mode = "0444";
              };

              "pnnk_wallpaper" = {
                format = "binary";
                sopsFile = "${inputs.ml-secrets}/artworks/260224-rebapymmkb-HB8Wtt_a0AE4YWk.jpg.enc";
                path = "${homeDirectory}/Pictures/pnnk_wallpaper.png";
                owner = username;
                mode = "0444";
              };
            };
          };

          environment.sessionVariables = {
            SOPS_AGE_KEY_FILE = ageKeyFile;
          };
        }
      )
    ];
  };

  home.always = {
    imports = [
      inputs.sops-nix.homeManagerModules.sops
      (
        { config, username, ... }:
        lib.mkIf (username == "eeshta") {
          sops = {
            age.keyFile = ageKeyFile;
            inherit defaultSopsFile;
            secrets = {
              "forgejo/cf-access-service-token" = { };
              "gallery-dl".path = "${config.home.homeDirectory}/.gallery-dl.conf";
            };
          };
        }
      )
    ];
  };
}
