# de.nix
{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    cifs-utils
  ];

  fileSystems."/mnt/balthazar" = {
    device = "//192.168.1.59/data";
    fsType = "cifs";
    options = [
      "credentials=/etc/nixos/smb.balthazar"
      "uid=1000"
      "gid=100"
      "iocharset=utf8"
      "vers=3.0"
      "noauto"
      "x-systemd.automount"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5"
      "x-systemd.mount-timeout=5"
    ];
  };
}
