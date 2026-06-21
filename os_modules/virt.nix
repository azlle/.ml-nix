# virt.nix
{ pkgs, ... }:

{
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
    };

    spiceUSBRedirection.enable = true;

    docker = {
      enable = true;
      autoPrune.enable = false;
    };

    oci-containers = {
      backend = "docker";
      containers = {
        phpmyadmin = {
          image = "phpmyadmin";
          ports = [ "8080:80" ];
          environment = {
            PMA_HOST = "172.17.0.1";
            PMA_PORT = "3306";
            BLOWFISH_SECRET = "***REMOVED***";
          };
        };
      };
    };
  };

  programs.virt-manager.enable = true;

  users.users.eeshta.extraGroups = [
    "libvirtd"
    "docker"
  ];
}
