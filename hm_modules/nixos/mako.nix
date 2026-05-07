# mako.nix
{ ... }:

{
  services.mako = {
    enable = true;
    settings = {
      width = 420;
      height = 120;
      margin = "24";
      anchor = "top-right";
      padding = "24";

      background-color = "#1f1f1f72";
      border-color = "#dcb898";
      border-size = 3;
      border-radius = 20;
      progress-color = "#dcb898";
      
      font = "Noto Sans CJK JP 10";
      
      icon-path = "";
      max-icon-size = 64;
      
      max-visible = 5;
      sort = "-time";
      
      default-timeout = 5000;
      ignore-timeout = false;
      
      layer = "overlay";
    };

    extraConfig = ''
      text-alignment=left
      actions=1
      group-by=app-name
    '';
  };
}
