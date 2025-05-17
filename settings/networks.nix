#networks.nix
{ config, lib, pkgs, ... }:

{
  networking.networkmanager.enable = false;
  networking.hostName = "necrofantasia";

  networking = {
    useDHCP = false;
    interfaces.ens33 = {
      ipv4.addresses = [{
        address = "192.168.1.189";
        prefixLength = 24;
      }];
    };
    defaultGateway = {
      address = "192.168.1.1";
      interface = "ens33";
    };
    nameservers = [ "8.8.8.8" ];
  };

  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [ ... ];
      allowedUDPPorts = [ ... ];
    };
  };
}
