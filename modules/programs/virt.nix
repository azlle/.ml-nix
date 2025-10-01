# virt.nix
{ pkgs, config, ... }:

{
  virtualisation = {
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
  };

  programs.virt-manager.enable = true;

  users.users.eeshta.extraGroups = [ "libvirtd" "kvm" ];

  users.users.eeshta.packages = [ pkgs.qemu_kvm ];

# 忘れずにsudo virsh net-start defaultと
  # sudo virsh net-autostart defaultを実行しておく
}
