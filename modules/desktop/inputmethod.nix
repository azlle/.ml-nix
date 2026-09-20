# modules/desktop/inputmethod.nix
{ delib, pkgs, ... }:
delib.module {
  name = "desktop.inputmethod";

  options = delib.singleCascadeEnableOption;

  # IME は GUI があって初めて意味を成すので desktop 側。
  # ロケール本体 (timeZone / defaultLocale / keyMap) は共通の modules/locale.nix。
  nixos.ifEnabled = {
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
      ];
      fcitx5.waylandFrontend = true;
    };
  };
}
