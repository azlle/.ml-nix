# hosts/plainasia/parts/networking.nix
_:

{
  networking.hostId = "dc0cfb0e";

  networking.useNetworkd = true;
  systemd.network.networks."10-lan" = {
    matchConfig.Name = "en*";
    address = [ "192.168.11.92/24" ];
    routes = [ { Gateway = "192.168.11.1"; } ];
    linkConfig.RequiredForOnline = "routable";
  };
}
