# networks.nix
{ config, lib, pkgs, hostType ? "necrofantasia", ... }: with lib; {

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

        allowedTCPPorts = [
          22
          47984
          47989
          47990
          48010
        ];

        allowedUDPPortRanges = [
          { from = 47998; to = 48000; }
          { from = 8000; to = 8010; }
        ];

        # virbr0 for QEMU, VIRT
        trustedInterfaces = [ "virbr0" ];
      };

      nftables.enable = false;
    }

    (mkIf (hostType == "necrofantasia") {
      hostName = "necrofantasia";
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

    (mkIf (hostType == "cosmicmind") {
      hostName = "cosmicmind";
      
      interfaces.ens33 = {
        ipv4.addresses = [{
          address = "192.168.1.76";
          prefixLength = 24;
        }];
      };
      defaultGateway = {
        address = "192.168.1.1";
        interface = "ens33";
      };
    })
  ];
}

# Configure network proxy if necessary
# networking.proxy.default = "http://user:password@proxy:port/";
# networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
