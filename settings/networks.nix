#networks.nix
{ config, lib, pkgs, ... }:

{
  networking.networkmanager.enable = false;
  networking.wireless = {
    enable = true;
    networks."Buffalo-A-DF70".pskRaw = "***REMOVED***";
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
    firewall = {
      enable = true;
      # allowedTCPPorts = [ ... ];
      # allowedUDPPorts = [ ... ];
    };
  };
}
