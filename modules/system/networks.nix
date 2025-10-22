# networks.nix
{ config, lib, pkgs, ... }: with lib;
{
  options = {
    miyana.hotspot.enable = mkEnableOption "Enable Hotspot: ml_haukanruri";
  };

  config = {
    networking = mkMerge [
      {
        networkmanager.enable = false;
        useDHCP = false;
        nameservers = [ "8.8.8.8" ];
        extraHosts = "127.0.0.1 suki-kira.com";
        
        firewall = {
          enable = true;

          allowPing = true;
          checkReversePath = "loose";

          allowedTCPPorts = [ 22 47984 47989 47990 48010 ];
          
          allowedUDPPortRanges = [
            { from = 47998; to = 48000; }
            { from = 8000; to = 8010; }
          ];
          
          # virbr0 for QEMU, VIRT
          trustedInterfaces = [ "virbr0" ];
        };

        hostName = "necrofantasia";
      }

      (mkIf (!config.miyana.hotspot.enable) {
        wireless = {
          enable = true;
          networks."Buffalo-A-DF70".pskRaw = "***REMOVED***";
        };

        interfaces.wlp4s0 = {
          ipv4.addresses = [{
            address = "192.168.1.178";
            prefixLength = 24;
          }];
        };

        defaultGateway = {
          address = "192.168.1.1";
          interface = "wlp4s0";
        };
      })

      (mkIf config.miyana.hotspot.enable {
        wireless.enable = false;
        interfaces.enp3s0 = {
          ipv4.addresses = [{
            address = "192.168.1.178";
            prefixLength = 24;
          }];
        };

        interfaces.wlp4s0 = {
          ipv4.addresses = [{
            address = "192.168.14.1";
            prefixLength = 24;
          }];
        };

        nat = {
          enable = true;
          externalInterface = "enp3s0";
          internalInterfaces = [ "wlp4s0" ];
        };

        defaultGateway = {
          address = "192.168.1.1";
          interface = "enp3s0";
        };
      })
    ];

    services.hostapd = mkIf config.miyana.hotspot.enable {
      enable = true;
      radios.wlp4s0 = {
        band = "5g";
        channel = 36;
        countryCode = "JP";
        networks.wlp4s0 = {
          ssid = "ml_haukanruri";
          authentication = {
            mode = "wpa2-sha256";
            wpaPasswordFile = "/home/eeshta/.dotfiles/credentials/hkrr_pswd";
          };
        };
      };
    };

    services.dnsmasq = mkIf config.miyana.hotspot.enable {
      enable = true;
      settings = {
        interface = "wlp4s0";
        bind-interfaces = true;
        dhcp-range = ["192.168.14.10,192.168.14.30,24h"];
        dhcp-option = ["3,192.168.14.1" "6,192.168.14.1"];
        server = ["8.8.8.8" "8.8.4.4"];
        address = [
          "/suki-kira.com/0.0.0.0"
        ];
      };
    };

    boot.kernel.sysctl = mkIf config.miyana.hotspot.enable {
      "net.ipv4.ip_forward" = 1;
    };
  };
}
# Configure network proxy if necessary
# networking.proxy.default = "http://user:password@proxy:port/";
# networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
