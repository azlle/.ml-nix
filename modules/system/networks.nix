# networks.nix
{ config, lib, pkgs, hostType ? "necrofantasia", ... }: with lib; {

  networking = mkMerge [
    {
      networkmanager.enable = false;
      useDHCP = false;
      nameservers = [ "8.8.8.8" ];
      extraHosts = "127.0.0.1 suki-kira.com";

      firewall.enable = false;

      nftables = {
        enable = true;
        ruleset = ''
          table inet filter {
            chain input {
              type filter hook input priority 0; policy drop;

              iif lo accept

              ct state established,related accept

              tcp dport { 22, 47984, 47989, 47990, 48010 } accept
              udp dport 47998-48000 accept
              udp dport 8000-8010 accept

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
