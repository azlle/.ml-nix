# hosts/plainasia/parts/nfs.nix
# necrofantasia (Linux) が /mnt/yamaxanadu としてマウントする tank/main の
# NFS エクスポート。SMB (parts/smb.nix) はSMB専用クライアント向けに維持し、
# Linux-to-LinuxはNFSの方が自然なため (CIFS認証情報ファイルの管理が不要)。
#
# no_root_squash が必要: forgejo-backup (necrofantasia, modules/containers/
# forgejo.nix) は root で走り、tank/main 上の keine (uid=1000) 所有ディレクトリ
# に書き込む。root_squash だとこの書き込みが弾かれる。
# necrofantasiaのIPのみに限定し、NFSv4専用運用のためportmapper(111)は開けない。
#
# crossmnt が必要: tank/main の下には creations/documents/misc/music/
# pictures/videos が独立したZFSデータセット (=別マウント) として存在する。
# crossmnt無しだとNFSはマウント境界を跨がず、これらが空のディレクトリの
# ように見えて中身にアクセスできない。crossmntを付けると、明示的に
# exportしていない配下のマウントも親と同じオプションで暗黙にexportされる。
_: {
  services.nfs.server = {
    enable = true;
    exports = ''
      /tank/main 192.168.11.78(rw,sync,no_subtree_check,no_root_squash,crossmnt)
    '';
  };

  networking.firewall.extraInputRules = ''
    ip saddr 192.168.11.78 tcp dport 2049 accept
  '';
}
