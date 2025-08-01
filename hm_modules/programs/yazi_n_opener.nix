# yazi_n_opener.nix
{ pkgs, ... }:

{
  programs.yazi = {
    enable = true;
    settings = {
      mgr = {
        show_hidden = true;
        mouse_events = [];
      };
      opener = {
        mpv = [{ run = "mpv \"$@\""; block = true; }];
        imv = [{ run = "imv \"$@\""; block = true; }];
      };
      open.rules = [
        { mime = "video/*"; use = "mpv"; }
        { mime = "image/*"; use = "imv"; }
      ];
    };
  };

  catppuccin.yazi = {
    enable = true;
    flavor = "mocha";
    accent = "yellow";
  };

  # Image Viewer
  programs.imv.enable = true;
  
  # Video Player
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

  # PDF Viewer
  programs.zathura.enable = true;
}
