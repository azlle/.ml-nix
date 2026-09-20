# modules/desktop/desktop-dotfiles.nix
{ delib, ... }:
delib.module {
  name = "desktop.desktop-dotfiles";

  options = delib.singleCascadeEnableOption;

  # home.ifEnabled can't carry its own `imports` (denix flattens it into plain
  # config), but we need home-manager's own `config` (mkOutOfStoreSymlink) here,
  # which only resolves correctly inside a real nested module. So stay on
  # `always` + a real `imports` entry, and gate the effect with `cfg.enable`
  # (captured from the outer lambda) via a plain `lib.mkIf` instead.
  home.always =
    { cfg, ... }:
    {
      imports = [
        (
          { config, lib, ... }:
          {
            config = lib.mkIf cfg.enable {
              xdg.configFile = {
                "niri/config.kdl".source =
                  config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.ml-nix/hm_modules/.config/niri_config.kdl";
                "niri/zephyrus.xkb".source =
                  config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.ml-nix/hm_modules/.config/niri_zephyrus.xkb";
                "niriswitcher/config.toml".source =
                  config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.ml-nix/hm_modules/.config/niris_config.toml";
                "rofi/config.rasi".source =
                  config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.ml-nix/hm_modules/.config/rofi_config.rasi";
              };
            };
          }
        )
      ];
    };
}
