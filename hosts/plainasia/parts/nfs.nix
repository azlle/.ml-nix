# hosts/plainasia/parts/nfs.nix

# necrofantasia (hosts/necrofantasia/parts/mounts.nix) からtank/mainへ
# 読み書きするための一般的なLANアクセス用。necrofantasiaのIPのみに限定し、
# NFSv4専用運用のためportmapper(111)は開けない。
#
# no_root_squash: necrofantasia側でrootとして動くプロセスが、tank/main上の
# keine (uid=1000) 所有ディレクトリに書き込めるようにするため。root_squash
# だとこの書き込みが弾かれる。

_: {
  services.nfs.server = {
    enable = true;

    # When mounting nested ZFS datasets over NFS, each dataset must be exported separately.
    # See: https://github.com/openzfs/zfs/issues/8376
    exports = ''
      /tank/main           192.168.11.78(rw,sync,no_subtree_check,no_root_squash)
      /tank/main/creations 192.168.11.78(rw,sync,no_subtree_check,no_root_squash)
      /tank/main/documents 192.168.11.78(rw,sync,no_subtree_check,no_root_squash)
      /tank/main/misc      192.168.11.78(rw,sync,no_subtree_check,no_root_squash)
      /tank/main/music     192.168.11.78(rw,sync,no_subtree_check,no_root_squash)
      /tank/main/pictures  192.168.11.78(rw,sync,no_subtree_check,no_root_squash)
      /tank/main/videos    192.168.11.78(rw,sync,no_subtree_check,no_root_squash)
    '';
  };

  networking.firewall.extraInputRules = ''
    ip saddr 192.168.11.78 tcp dport 2049 accept
  '';
}
