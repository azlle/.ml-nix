# mounts.nix
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    cifs-utils
    btrfs-progs
  ];

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
}
