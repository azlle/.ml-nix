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
    };
  };

  catppuccin.yazi = {
    enable = true;
    flavor = "mocha";
  };
}
