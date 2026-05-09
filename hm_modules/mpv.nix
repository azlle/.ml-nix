# mpv.nix
{ pkgs, ... }:

{
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
}
