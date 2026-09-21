# hosts/plainasia/parts/disko.nix
#
# root on ZFS のディスクレイアウト。
#
# `device` は検証用ミニPCと本番機で異なるため、ここの値はプレースホルダー。
# インストール時に disko-install の `--disk main <device>` で上書きする:
#
#   sudo nix run 'github:nix-community/disko/latest#disko-install' -- \
#     --flake <repo>#plainasia --disk main /dev/disk/by-id/<実際のID>
#
# データセットの3層構成は https://grahamc.com/blog/nixos-on-zfs/ に準拠:
#   local/  = 再構築可能。スナップショット・バックアップ対象外
#   system/ = OS状態
#   user/   = ユーザーデータ
# /nix をバックアップ対象の「従兄弟」の位置に置くことで、system/user を再帰
# スナップショットしても /nix を巻き込まない。
{ inputs, ... }:
{
  imports = [ inputs.disko.nixosModules.disko ];

  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/disk/by-id/REPLACE_AT_INSTALL_TIME";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            # 1G だと systemd-boot のインストール中に実機で容量不足になった
            # (カーネル+initrd+複数のboot entryで想定より嵩んだ)。余裕を見て2Gに。
            size = "2G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };

          # ZFS は swapfile 非対応。zvol swap はメモリ逼迫時にデッドロックする
          # 既知の問題があるため、プールの外に通常パーティションとして確保する。
          swap = {
            size = "16G";
            content = {
              type = "swap";
              discardPolicy = "both";
            };
          };

          zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "rpool";
            };
          };
        };
      };
    };

    zpool.rpool = {
      type = "zpool";
      options.cachefile = "none";

      rootFsOptions = {
        compression = "zstd";

        # journald のログを一般ユーザーが読むために必須。個別指定ではなく
        # プール既定にして全データセットへ継承させる。
        acltype = "posixacl";
        xattr = "sa";

        relatime = "on";
        mountpoint = "none";

        # 既定は取らない。残したいデータセットだけ opt-in する。
        "com.sun:auto-snapshot" = "false";
      };

      datasets = {
        # --- local: 再構築可能。バックアップ不要 ---
        "local" = {
          type = "zfs_fs";
          options = {
            mountpoint = "none";
            canmount = "off";
          };
        };
        "local/nix" = {
          type = "zfs_fs";
          mountpoint = "/nix";
          options = {
            mountpoint = "legacy";
            atime = "off";
          };
        };
        # コンテナのイメージレイヤー置き場。永続データは tank 側に置くため
        # ここはスナップショット不要。
        "local/containers" = {
          type = "zfs_fs";
          mountpoint = "/var/lib/containers";
          options = {
            mountpoint = "legacy";
            atime = "off";
          };
        };

        # --- system: OS状態 ---
        "system" = {
          type = "zfs_fs";
          options = {
            mountpoint = "none";
            canmount = "off";
          };
        };
        "system/root" = {
          type = "zfs_fs";
          mountpoint = "/";
          options = {
            mountpoint = "legacy";
            "com.sun:auto-snapshot" = "true";
          };
        };
        "system/var" = {
          type = "zfs_fs";
          mountpoint = "/var";
          options = {
            mountpoint = "legacy";
            "com.sun:auto-snapshot" = "true";
          };
        };

        # --- user: ユーザーデータ ---
        "user" = {
          type = "zfs_fs";
          options = {
            mountpoint = "none";
            canmount = "off";
          };
        };
        "user/home" = {
          type = "zfs_fs";
          mountpoint = "/home";
          options = {
            mountpoint = "legacy";
            "com.sun:auto-snapshot" = "true";
          };
        };

        # ZFS は使用率80%超で性能が劣化し、満杯になると CoW の性質上
        # 削除操作すら失敗しうる。その緩衝材として確保しておく。
        "reserved" = {
          type = "zfs_fs";
          options = {
            mountpoint = "none";
            canmount = "off";
            refreservation = "20G";
          };
        };
      };
    };
  };
}
