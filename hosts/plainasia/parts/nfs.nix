# hosts/plainasia/parts/nfs.nix

# no_root_squash が必要: forgejo-backup (necrofantasia, modules/containers/
# forgejo.nix) は root で走り、tank/main 上の keine (uid=1000) 所有ディレクトリ
# に書き込む。root_squash だとこの書き込みが弾かれる。
# necrofantasiaのIPのみに限定し、NFSv4専用運用のためportmapper(111)は開けない。

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
