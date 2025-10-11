# audios.nix
{ config, lib, pkgs, ... }:

{
  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    #jack.enable = true;

    extraConfig.pipewire = {
      "99-custom" = {
        "context.properties" = {
          "default.clock.rate" = 44100;
          "default.clock.allowed-rates" = [ 22050 41000 44100 48000 ];
          "default.clock.quantum" = 1024;
          "default.clock.min-quantum" = 512;
          "default.clock.max-quantum" = 2048;
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    alsa-utils
  ];

  boot.kernelParams = [ "threadirqs" ];
}
