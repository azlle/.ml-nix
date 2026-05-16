# networks.nix
{ config, lib, pkgs, ... }: with lib;
{
  options = {
    haukanRuri.enable = mkEnableOption "Enable Hotspot: ml_haukanruri";
  };

  config = {
    networking = mkMerge [
      # 共通設定
      {
        networkmanager.enable = false;
        useDHCP = false;
        hostName = "necrofantasia";
        nameservers = [ "8.8.8.8" ];
        extraHosts = "127.0.0.1 suki-kira.com";
        firewall = {
          enable = true;
          allowPing = true;
          checkReversePath = "loose";
          allowedTCPPorts = [ 22 28989 47984 47989 47990 48010 ];
          allowedUDPPortRanges = [
            { from = 47998; to = 48000; }
            { from = 8000; to = 8010; }
          ];
          trustedInterfaces = [ "virbr0" ];
        };
      }

      # 通常モード（無線接続）
      (mkIf (!config.haukanRuri.enable) {
        wireless = {
          enable = true;
          networks."mel_wpa3" = {
            authProtocols = [ "SAE" ];
            pskRaw = "***REMOVED***";
          };
        };
        interfaces.wlp4s0.ipv4.addresses = [{
          address = "192.168.11.78";
          prefixLength = 24;
        }];
        defaultGateway = {
          address = "192.168.11.1";
          interface = "wlp4s0";
        };
      })

      # ホットスポットモード（有線→無線配信）
      (mkIf config.haukanRuri.enable {
        wireless.enable = false;

        # 有線インターフェース（インターネット側）
        interfaces.enp3s0 = {
          useDHCP = false;
          ipv4.addresses = [{
            address = "192.168.11.78";
            prefixLength = 24;
          }];
        };

        # 無線インターフェース（ホットスポット側）
        interfaces.wlp4s0 = {
          useDHCP = false;
          ipv4.addresses = [{
            address = "192.168.14.1";
            prefixLength = 24;
          }];
        };

        defaultGateway = {
          address = "192.168.11.1";
          interface = "enp3s0";
        };

        # NAT設定
        nat = {
          enable = true;
          externalInterface = "enp3s0";
          internalInterfaces = [ "wlp4s0" ];
        };

        # ファイアウォールでホットスポット通信を許可
        firewall.trustedInterfaces = [ "virbr0" "wlp4s0" ];
      })
    ];

    # ホットスポットサービス
    services.hostapd = mkIf config.haukanRuri.enable {
      enable = true;
      radios.wlp4s0 = {
        band = "2g";
        channel = 11;
        countryCode = "JP";
        networks.wlp4s0 = {
          ssid = "ml_haukanruri";
          authentication = {
            mode = "wpa2-sha256";
            wpaPassword = "***REMOVED***";
            # wpaPasswordFile = "/home/eeshta/.dotfiles/credentials/hkrr_pswd";
          };
        };
      };
    };

    services.dnsmasq = mkIf config.haukanRuri.enable {
      enable = true;
      settings = {
        interface = "wlp4s0";
        bind-interfaces = true;
        dhcp-range = [ "192.168.14.10,192.168.14.30,24h" ];
        dhcp-option = [ "3,192.168.14.1" "6,192.168.14.1" ];
        server = [ "8.8.8.8" "8.8.4.4" ];
        address = [ "/suki-kira.com/0.0.0.0" ];

        dhcp-host = [
          "bc:10:7b:81:b3:f6,192.168.14.10,galaxy"
          "58:73:d8:2a:38:be,192.168.14.11,ipad"
          "00:0c:4a:1b:cd:fb,192.168.14.12,boox"
          "d4:3a:2c:6e:b4:e4,192.168.14.13,watch"
        ];
      };
    };

    boot.kernel.sysctl = mkIf config.haukanRuri.enable {
      "net.ipv4.ip_forward" = 1;
    };
  };
}
