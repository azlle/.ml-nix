# modules/fonts.nix
{ delib, ... }:
delib.module {
  name = "fonts";

  nixos.always = {
    imports = [
      (
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
            # fontconfigはmodules/fonts.nixのhome.always側に定義
          };
        }
      )
    ];
  };

  home.always = {
    imports = [
      (
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
        }
      )
    ];
  };
}
