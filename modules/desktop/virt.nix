# modules/desktop/virt.nix
{ delib, pkgs, ... }:
delib.module {
  name = "desktop.virt";

  options = delib.singleCascadeEnableOption;

  nixos.ifEnabled = {
    virtualisation = {
      libvirtd = {
        enable = true;
        qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
      };

      spiceUSBRedirection.enable = true;
    };

    programs.virt-manager.enable = true;

    users.users.eeshta.extraGroups = [
      "libvirtd"
    ];
  };
}
