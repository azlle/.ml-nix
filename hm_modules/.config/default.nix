# cfg.nix
{ config, ... }:

{
  xdg.configFile = {
    "niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/hm_modules/.config/niri_config.kdl";
    "niri/zephyrus.xkb".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/hm_modules/.config/niri_zephyrus.xkb";
    "niriswitcher/config.toml".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/hm_modules/.config/niris_config.toml";
    "rofi/config.rasi".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/hm_modules/.config/rofi_config.rasi";
  };
}
