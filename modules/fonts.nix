# fonts.nix
{ config, lib, pkgs, ... }:

{
  fonts = {
    packages = with pkgs; [
      noto-fonts-cjk-serif
      noto-fonts-cjk-sans
      noto-fonts-emoji
      hackgen-nf-font
      nerd-fonts.iosevka
    ];
    fontDir.enable = true;
    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif CJK JP" ];
        sansSerif = [ "Noto Sans CJK JP" ];
        monospace = [ "Iosevka Nerd Font" "HackGen Console NF" "Noto Color Emoji" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
