# modules/desktop/audios.nix
{ delib, pkgs, ... }:
delib.module {
  name = "desktop.audios";

  options = delib.singleCascadeEnableOption;

  nixos.ifEnabled = {
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # jack.enable = true;
    };

    environment.systemPackages = [
      pkgs.alsa-utils
    ];

    boot.kernelParams = [ "threadirqs" ];
  };
}
