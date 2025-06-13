# mako.nix
{ ... }:

{
  services.mako = {
    enable = true;
    settings = {
      width = 400;
      height = 120;
      margin = "30,60";
      anchor = "top-right";
      padding = "24";

      backgroundColor = "#1f1f1f72";
      borderColor = "#dcb898";
      borderSize = 2;
      borderRadius = 20;
      progressColor = "#dcb898";
      
      font = "Noto Sans CJK JP 10";
      
      iconPath = "";
      maxIconSize = 64;
      
      maxVisible = 5;
      sort = "-time";
      
      defaultTimeout = 5000;
      ignoreTimeout = false;
      
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
