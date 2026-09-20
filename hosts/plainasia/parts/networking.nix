# hosts/plainasia/parts/networking.nix
_: {
  # necrofantasia (a53b4ec5) と重複しない新規生成値。ZFSプールの排他ロックに使われるため
  # 使い回し厳禁。
  networking.hostId = "dc0cfb0e";

  # 検証用ミニPCと本番機でインターフェース名が異なるため、名前を直書きせず
  # systemd-networkd のワイルドカードで有線 NIC を拾う。どちらのマシンでも
  # 同じ設定のまま動く (有線ポートは1つの想定)。
  networking.useNetworkd = true;

  systemd.network.networks."10-lan" = {
    matchConfig.Name = "en*";
    address = [ "192.168.11.92/24" ];
    routes = [ { Gateway = "192.168.11.1"; } ];
    linkConfig.RequiredForOnline = "routable";
  };
}
