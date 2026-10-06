# hosts/necrofantasia/parts/mounts.nix
# plainasia (hosts/plainasia/parts/nfs.nix) が tank/main を necrofantasia の
# IPにのみエクスポートしているNFSマウント。旧TrueNAS時代のCIFSマウントを
# 引き継ぐパス (/mnt/yamaxanadu)。
{ lan, ... }: {
  fileSystems."/mnt/yamaxanadu" = {
    device = "${lan.plainasia}:/tank/main";
    fsType = "nfs";
    options = [
      "nfsvers=4.2"
      "noauto"
      "nofail"
      "x-systemd.automount"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5"
      "x-systemd.mount-timeout=5"
    ];
  };
}
