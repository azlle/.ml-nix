{ ... }:

{
  services.dunst = {
    enable = true;
    settings = {
      global = {
        width = 400;
        height = 120;
        offset = "(30, 60)";
        origin = "top-right";
        padding = 24;
        horizontal_padding = 24;

        transparency = 0;
        frame_width = 2;
        frame_color = "#dcb898";
        background = "#1f1f1f72";
        highlight = "#dcb898"; #progress bar
        corners = "all";
        corner_radius = 20;
        scale = 1;
        
        font = "Noto Sans CJK JP 10";
        min_icon_size = 64;
        max_icon_size = 64;
        strip_newlines = false;
        ignore_newline = false;
        shrink = true;
        show_indicators = false;
        ellipsize = "end";
      };
    };
  };
}
