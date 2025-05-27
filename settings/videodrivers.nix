# videodrives.nix
{ config, lib, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    prime.offload.enable = false;
    prime.sync.enable = true;
    open = false;
    nvidiaSettings = true;
  };
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
  ];
}
