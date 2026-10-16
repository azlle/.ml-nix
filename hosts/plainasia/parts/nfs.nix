# hosts/plainasia/parts/nfs.nix

# necrofantasia (hosts/necrofantasia/parts/mounts.nix) からtank/mainへ
# 読み書きするための一般的なLANアクセス用。necrofantasiaのIPのみに限定し、
# NFSv4専用運用のためportmapper(111)は開けない。

{ lan, ... }: {
  services.nfs.server = {
    enable = true;

    # When mounting nested ZFS datasets over NFS, each dataset must be exported separately.
    # See: https://github.com/openzfs/zfs/issues/8376
    exports = ''
      /tank/main           ${lan.necrofantasia}(rw,sync,no_subtree_check)
      /tank/main/creations ${lan.necrofantasia}(rw,sync,no_subtree_check)
      /tank/main/documents ${lan.necrofantasia}(rw,sync,no_subtree_check)
      /tank/main/misc      ${lan.necrofantasia}(rw,sync,no_subtree_check)
      /tank/main/music     ${lan.necrofantasia}(rw,sync,no_subtree_check)
      /tank/main/pictures  ${lan.necrofantasia}(rw,sync,no_subtree_check)
      /tank/main/videos    ${lan.necrofantasia}(rw,sync,no_subtree_check)
    '';
  };

  networking.firewall.extraInputRules = ''
    ip saddr ${lan.necrofantasia} tcp dport 2049 accept
  '';
}
