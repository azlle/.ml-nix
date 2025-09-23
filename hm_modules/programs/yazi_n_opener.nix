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
        nvim = [{ run = "nvim \"$@\""; block = true; }];
        mpv = [{ run = "mpv \"$@\""; block = true; }];
        imv = [{ run = "imv \"$@\""; block = true; }];
      };
      open.rules = [
        { mime = "text/*"; use = "nvim"; }
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

  programs = {
    imv.enable = true;
    mpv = {
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
    
    zathura.enable = true;
    
    fd.enable = true;

    fzf = {
      enable = true;
      enableFishIntegration = true;
      defaultCommand = "plocate ''";
    };

    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
