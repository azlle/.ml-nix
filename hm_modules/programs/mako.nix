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
      # 透明度の代替（makoではalpha値で指定）
      # background-color=#1f1f1f72 は既に上記で設定済み
      
      # テキストの省略設定（dunstのellipsizeに相当）
      text-alignment=left
      
      # アクション設定
      actions=1
      
      # グループ化設定
      group-by=app-name
    '';
  };
}
