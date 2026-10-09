# hosts/plainasia/parts/networking.nix
{
  lan,
  lib,
  config,
  ...
}:

{
  networking.hostId = "dc0cfb0e";

  networking.useNetworkd = true;
  systemd.network.networks."10-lan" = {
    matchConfig.Name = "en*";
    address = [ "${lan.plainasia}/24" ];
    routes = [ { Gateway = lan.gateway; } ];
    linkConfig.RequiredForOnline = "routable";
  };

  # modules/networks.nixのtrustedInterfacesはtailscaleインターフェースを
  # 無条件acceptするが、plainasiaはMinecraft(2665/tcp, mello_servers配下の
  # run.shで個別に建てている身内向けサーバー)をtailscale経由でだけ開けたい
  # ので、他ホストと違い全ポート素通しにはしない。trustedInterfacesから
  # tailscaleを外し(mkForceで丸ごと置き換え、lo/docker0/virbr0/podman*は
  # そのまま残す)、tailscale経由で必要な分だけ個別にacceptする:
  # 22はSSH管理用、2665はMinecraft用。
  #
  # loを明示的に残す理由: rootlessなForgejo(containers/forgejo.nix)の
  # PublishPortはrootlessport経由でホストの127.0.0.1に直接bindするだけで、
  # rootfulなpodmanコンテナ(Nextcloud等)のようにpodman*ブリッジへのDNATを
  # 経由しない。modules/networks.nixの基底リストにはloが元々無く、rootful
  # 側はtrustedInterfacesのpodman*宛DNAT後にそこで救われていただけなので、
  # 他ホストと同じ全部mkForceする書き方のままloだけ忘れると、ループバック
  # 宛ての新規接続がinput-allowの個別 port listにも無くdefault dropに落ちる
  # (2026-10-09に実際に踏んだ: git.melocy.cc/git-ssh.melocy.ccがBad Gateway
  # 化し、127.0.0.1:3080/2222への接続がconnection refusedではなくタイムアウト
  # していた=SYNがnftablesでdropされていた証拠)。
  networking.firewall.trustedInterfaces = lib.mkForce [
    "lo"
    "docker0"
    "virbr0"
    "podman*"
  ];

  networking.firewall.extraInputRules = ''
    iifname ${config.services.tailscale.interfaceName} tcp dport { 22, 2665 } accept
  '';
}
