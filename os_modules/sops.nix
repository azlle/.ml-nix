# sops.nix
{ inputs, ... }:

let
  ageKeyFile = "/var/lib/sops-nix/sops_mm";
in

{
  sops = {
    age.keyFile = ageKeyFile;
    defaultSopsFile = "${inputs.ml-secrets}/secret.yaml";
    secrets = {
      "users/password/eeshta" = {
        neededForUsers = true;
      };
      "wireless/password" = {
        path = "/run/secrets/wireless.conf";
        owner = "wpa_supplicant";
      };
    };
  };

  environment.sessionVariables = {
    SOPS_AGE_KEY_FILE = ageKeyFile;
  };
}
