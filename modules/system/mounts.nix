# de.nix
{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    cifs-utils
    btrfs-progs
  ];

  fileSystems."/mnt/balthazar" = {
    device = "//192.168.11.9/data";
    fsType = "cifs";
    options = [
      "credentials=/etc/nixos/smb.balthazar"
      "uid=1000"
      "gid=100"
      "iocharset=utf8"
      "vers=3.0"
      "noauto"
      "nofail"
      "x-systemd.automount"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5"
      "x-systemd.mount-timeout=5"
    ];
  };

  fileSystems."/mnt/yamaxanadu" = {
    device = "//192.168.11.11/main";
    fsType = "cifs";
    options = [
      "credentials=/etc/nixos/smb.yamaxanadu"
      "uid=1000"
      "gid=100"
      "iocharset=utf8"
      "vers=3.1.1"
      "noauto"
      "nofail"
      "x-systemd.automount"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5"
      "x-systemd.mount-timeout=5"
    ];
  };

  fileSystems."/mnt/melchior" = {
    device = "/dev/disk/by-uuid/154ee557-cfa5-44a3-82e8-75edbcc83f8b";
    fsType = "btrfs";
    options = [
      "defaults"
      "noatime"
      "compress=zstd:3"
      "ssd"
      "discard=async"
      "space_cache=v2"
      "noauto"
      "nofail"
      "x-systemd.automount"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5"
      "x-systemd.mount-timeout=5"
    ];
  };

  fileSystems."/mnt/saigyouji" = {
    device = "/dev/disk/by-uuid/969cfad8-3e8e-4f26-9591-3104eb2e71d8";
    fsType = "btrfs";
    options = [
      "defaults"
      "noatime"
      "compress=zstd:3"
      "autodefrag"
      "space_cache=v2"
      "noauto"
      "nofail"
      "x-systemd.automount"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5"
      "x-systemd.mount-timeout=5"
    ];
  };
}
