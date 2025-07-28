# nvim.nix
{ ... }:

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
}
