# modules/desktop/fonts.nix
{ delib, pkgs, ... }:
let
  fontPackages = with pkgs; [
    noto-fonts-cjk-serif
    noto-fonts-cjk-sans
    noto-fonts-color-emoji

    # for Emacs:
    moralerspace-hw
    nerd-fonts.symbols-only
  ];
in
delib.module {
  name = "desktop.fonts";

  options = delib.singleCascadeEnableOption;

  # 端末やエディタの描画はクライアント側で行われるので、SSH で入るだけの
  # サーバーにフォントは要らない。
  # サーバー側で描画が必要になる用途 (Nextcloud のサムネイル生成など) が出たら、
  # その依存はそのモジュール自身に宣言させること。ここを共通に戻さない。
  nixos.ifEnabled = {
    fonts = {
      packages = fontPackages;
      fontDir.enable = true;
      # fontconfig は下の home.ifEnabled 側に定義
    };
  };

  home.ifEnabled = {
    home.packages = fontPackages;

    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Noto Serif CJK JP" ];
        sansSerif = [ "Noto Sans CJK JP" ];
        monospace = [
          "Moralerspace Neon HW"
          "Symbols Nerd Font Mono"
          "Noto Color Emoji"
        ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
