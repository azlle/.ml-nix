# sops.nix
{
  inputs,
  username,
  homeDirectory,
  ...
}:

let
  ageKeyFile = "/var/lib/sops-nix/sops_mm";
in

{
  sops = {
    age.keyFile = ageKeyFile;
    defaultSopsFile = "${inputs.ml-secrets}/secret.yaml";
    secrets = {
      "gallery-dl" = {
        path = "/etc/gallery-dl.conf";
        owner = username;
      };

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

      "forgejo/cf-access-service-token" = {
        owner = username;
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
