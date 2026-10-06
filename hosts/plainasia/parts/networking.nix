# hosts/plainasia/parts/networking.nix
{ lan, ... }:

{
  networking.hostId = "dc0cfb0e";

  networking.useNetworkd = true;
  systemd.network.networks."10-lan" = {
    matchConfig.Name = "en*";
    address = [ "${lan.plainasia}/24" ];
    routes = [ { Gateway = lan.gateway; } ];
    linkConfig.RequiredForOnline = "routable";
  };
}
