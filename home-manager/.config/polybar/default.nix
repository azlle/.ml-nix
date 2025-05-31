# polybar.nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nerd-fonts.iosevka
    fantasque-sans-mono
  ];

  xdg.configFile = {
    # adi1090x/polybar-themes/shades/
    "polybar/shades" = {
      source = ./shades_simple;
      # source = ./shades_bitmap;
      recursive = true;
    };
  };

  home.file = {
    # ".local/share/rofi/themes/rounded-yellow-dark.rasi".source = ./rounded-yellow-dark.rasi;
    # ".local/share/rofi/themes/rounded-template.rasi".source = ./rounded-template.rasi;
  };
}
