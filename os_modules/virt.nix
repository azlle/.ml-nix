# virt.nix
{ pkgs, ... }:

{
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
    };

    # USBデバイスをVMに転送
    spiceUSBRedirection.enable = true;

    docker = {
      enable = true;
      autoPrune.enable = false;
    };
  };

  programs.virt-manager.enable = true;

  users.users.eeshta.extraGroups = [
    "libvirtd"
    "docker"
  ];
}
