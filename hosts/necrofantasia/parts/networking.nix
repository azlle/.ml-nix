# hosts/necrofantasia/parts/networking.nix
{
  config,
  lan,
  ...
}:
{
  # wpa_supplicant ユーザーを所有者に取るため、無線を持つこのホストでしか
  # 宣言できない (共通の modules/sops.nix には置けない)。
  sops.secrets."wireless/password" = {
    path = "/run/secrets/wireless.conf";
    owner = "wpa_supplicant";
  };

  networking = {
    wireless = {
      enable = true;
      secretsFile = config.sops.secrets."wireless/password".path;
      networks."mrr_primary" = {
        authProtocols = [
          "SAE"
          "WPA-PSK"
        ];
        pskRaw = "ext:mrr_primary";
      };
    };

    interfaces.wlp4s0.ipv4.addresses = [
      {
        address = lan.necrofantasia;
        prefixLength = 24;
      }
    ];

    defaultGateway = {
      address = lan.gateway;
      interface = "wlp4s0";
    };
  };
}
