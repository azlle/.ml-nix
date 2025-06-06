# networks.nix
{ config, lib, pkgs, ... }:

{
  networking.networkmanager.enable = false;
  networking.wireless = {
    enable = true;
    networks."Buffalo-A-DF70".pskRaw = "***REMOVED***";
  };
  networking.hostName = "necrofantasia";

  networking = {
    useDHCP = false;
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
    nameservers = [ "8.8.8.8" ];
  };

  networking = {
    firewall.enable = false;

    nftables = {
      enable = true;
      ruleset = ''
        table inet filter {
          chain input {
            type filter hook input priority 0; policy drop;

            iif lo accept

            ct state established,related accept

            tcp dport 22 accept

            ip protocol icmp accept
            ip6 nexthdr icmpv6 accept
          }

          chain forward{
            type filter hook forward priority 0; policy drop;
          }

          chain output {
            type filter hook output priority 0; policy accept;
          }
        }
      '';
    };
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
}
