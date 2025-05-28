# videodrives.nix
{ config, lib, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;

    prime = {
      offload.enable = false;
      sync.enable = true;

      # nvidiaBusId = "PCI:1:0:0";
      # amdgpuBusId = "PCI:6:0:0";
    };

    open = true;
    nvidiaSettings = true;
  };

  boot.kernelParams = [
    "nvidia-drm.modeset=1"
  ];
}
