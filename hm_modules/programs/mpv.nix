# mpv.nix
{ pkgs, ... }:

{
  programs.mpv = {
    enable = true;

    package = (
      pkgs.mpv-unwrapped.wrapper {
        scripts = with pkgs.mpvScripts; [
          uosc
          thumbfast
        ];

        mpv = pkgs.mpv-unwrapped.override {
          waylandSupport = true;
        };
      }
    );

    config = {
      vo = "dmabuf-wayland";
      gpu-context = "wayland";
      hwdec = "auto";

      keep-open = true;
      save-position-on-quit = true;
    };
  };
}
