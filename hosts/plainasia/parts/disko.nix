# hosts/plainasia/parts/disko.nix
# Reference: https://grahamc.com/blog/nixos-on-zfs/
{ inputs, ... }:
let
  mainDevice = "/dev/disk/by-id/REPLACE_AT_INSTALL_TIME";
in
{
  imports = [ inputs.disko.nixosModules.disko ];

  disko.devices = {
    disk.main = {
      type = "disk";
      device = mainDevice;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            # Kept generous (see boot.nix's configurationLimit for the capacity math)
            size = "2G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };

          # zvol swap is excluded from rpool: known deadlock risk under memory pressure
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

        # Pool default so all datasets inherit it; needed for all users to read journald logs.
        acltype = "posixacl";
        xattr = "sa";

        relatime = "on";
        mountpoint = "none";

        # Opt-in only: datasets that need snapshots enable it individually.
        "com.sun:auto-snapshot" = "false";
      };

      datasets = {
        # Reproducible from the Nix store; doesn't need snapshots.
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

        # Container image layers. Persistent data lives on tank, so no snapshots needed here.
        "local/containers" = {
          type = "zfs_fs";
          mountpoint = "/var/lib/containers";
          options = {
            mountpoint = "legacy";
            atime = "off";
          };
        };

        # OS state.
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

        # User data.
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

        # Reserved buffer: ZFS performance degrades as the pool fills up.
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
