# modules/networks.nix
{ delib, ... }:
delib.module {
  name = "networks";

  nixos.always = {
    imports = [
      (
        {
          config,
          hostname,
          ...
        }:
        {
          services.tailscale.enable = true;
          networking = {
            networkmanager.enable = false;
            nftables.enable = true;
            useDHCP = false;
            hostName = hostname;
            nameservers = [ "8.8.8.8" ];
            extraHosts = "127.0.0.1 suki-kira.com";
            firewall = {
              enable = true;
              allowPing = true;
              checkReversePath = "loose";
              allowedTCPPorts = [
                config.services.tailscale.port
              ];
              allowedUDPPorts = [
                config.services.tailscale.port
                2230 # L4D2 dedicated server (hostport in mello_servers/l4d2_mrrte/run.sh)
              ];
              allowedUDPPortRanges = [ ];
              trustedInterfaces = [
                "docker0"
                "virbr0"
                config.services.tailscale.interfaceName
              ];
            };
          };
        }
      )
    ];
  };
}
