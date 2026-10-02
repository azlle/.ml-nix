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

  # Nextcloudの動画再生がCloudflare Tunnel起因かどうか切り分けるため、LAN内
  # からの直接アクセスを一時的に許可 (modules/containers/nextcloud.nixの
  # 192.168.11.92:22300バインドに対応)。診断が終わったら削除してよい。
  networking.firewall.extraInputRules = ''
    ip saddr 192.168.11.0/24 tcp dport 22300 accept
  '';
}
