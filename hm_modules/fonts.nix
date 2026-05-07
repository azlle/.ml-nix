# hm_modules/fonts.nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    noto-fonts-cjk-serif
    noto-fonts-cjk-sans
    noto-fonts-color-emoji

    # for Emacs:
    moralerspace-hw
    nerd-fonts.symbols-only
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif     = [ "Noto Serif CJK JP" ];
      sansSerif = [ "Noto Sans CJK JP" ];
      monospace = [ "Moralerspace Neon HW" "Symbols Nerd Font Mono" "Noto Color Emoji" ];
      emoji     = [ "Noto Color Emoji" ];
    };
  };
}
