# modules/desktop/obs.nix
{ delib, pkgs, ... }:
delib.module {
  name = "desktop.obs";

  options = delib.singleCascadeEnableOption;

  home.ifEnabled = {
    programs.obs-studio = {
      enable = true;

      # optional Nvidia hardware acceleration
      package = pkgs.obs-studio.override {
        cudaSupport = true;
      };

      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
        obs-vaapi # optional AMD hardware acceleration
        obs-gstreamer
        obs-vkcapture
      ];
    };
  };
}
