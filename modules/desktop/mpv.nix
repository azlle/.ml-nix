# modules/desktop/mpv.nix
{ delib, pkgs, ... }:
delib.module {
  name = "desktop.mpv";

  options = delib.singleCascadeEnableOption;

  home.ifEnabled = {
    programs.mpv = {
      enable = true;

      scripts = with pkgs.mpvScripts; [
        uosc
        thumbfast
      ];

      config = {
        vo = "gpu";
        gpu-context = "wayland";
        hwdec = "auto";

        keep-open = true;
        save-position-on-quit = true;
      };
    };
  };
}
