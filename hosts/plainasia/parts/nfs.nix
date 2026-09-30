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
# tank/main の下には creations/documents/misc/music/pictures/videos が
# 独立したZFSデータセット (=別マウント) として存在し、それぞれ明示的に
# exportしている。crossmntオプション (配下の未exportマウントを親と同じ
# オプションで暗黙exportする機能) も試したが、ZFSのネストしたデータセットを
# 暗黙exportすると子のルートディレクトリがroot:root 0755相当の間違った
# 属性で見えてしまう既知の未解決バグ (openzfs/zfs#8376) があり、結局
# パーミッションで弾かれた。各データセットを明示exportする方法が標準的な
# 回避策。crossmntは今の対象(全データセットを既に明示export済み)に対して
# 何の効果も持たず、将来の新規データセットに対しても同じバグに当たるだけで
# 「保険」にならないため、外してある。tank/main配下に新しいデータセットを
# 増やす際は、ここにexport行を1つ足すこと。
_: {
  services.nfs.server = {
    enable = true;
    exports = ''
      /tank/main 192.168.11.78(rw,sync,no_subtree_check,no_root_squash)
      /tank/main/creations 192.168.11.78(rw,sync,no_subtree_check,no_root_squash)
      /tank/main/documents 192.168.11.78(rw,sync,no_subtree_check,no_root_squash)
      /tank/main/misc 192.168.11.78(rw,sync,no_subtree_check,no_root_squash)
      /tank/main/music 192.168.11.78(rw,sync,no_subtree_check,no_root_squash)
      /tank/main/pictures 192.168.11.78(rw,sync,no_subtree_check,no_root_squash)
      /tank/main/videos 192.168.11.78(rw,sync,no_subtree_check,no_root_squash)
    '';
  };

  networking.firewall.extraInputRules = ''
    ip saddr 192.168.11.78 tcp dport 2049 accept
  '';
}
