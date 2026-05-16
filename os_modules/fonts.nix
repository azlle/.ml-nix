# os_modules/fonts.nix
{ pkgs, ... }:

{
  fonts = {
    packages = with pkgs; [
      noto-fonts-cjk-serif
      noto-fonts-cjk-sans
      noto-fonts-color-emoji

      # for Emacs:
      moralerspace-hw
      nerd-fonts.symbols-only
    ];

    fontDir.enable = true;
    # fontconfigはhm_modules/fonts.nixの方に定義
  };
}
