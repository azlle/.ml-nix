# mpv.nix
{ ... }:

{
  programs.mpv = {
    enable = true;
    config = {
      vo = "dmabuf-wayland";
      gpu-context = "wayland";
      hwdec = "auto";

      keep-open = true;
      save-position-on-quit = true;
    };
  };
}
