# modules/locale.nix
{ delib, ... }:
delib.module {
  name = "locale";

  # ロケール/タイムゾーン/コンソールキーマップはサーバーでも要る:
  # ログのタイムスタンプ、cron のスケジュール解釈 (Forgejo バックアップの 23:30 は
  # JST 前提)、緊急時に物理コンソールへキーボードを挿したときの配列。
  # IME (fcitx5) だけは GUI がないと意味を成さないので modules/desktop/inputmethod.nix へ。
  nixos.always = {
    time.timeZone = "Asia/Tokyo";

    console.keyMap = "jp106";

    i18n = {
      defaultLocale = "ja_JP.UTF-8";
      extraLocaleSettings = {
        LC_ADDRESS = "ja_JP.UTF-8";
        LC_IDENTIFICATION = "ja_JP.UTF-8";
        LC_MEASUREMENT = "ja_JP.UTF-8";
        LC_MONETARY = "ja_JP.UTF-8";
        LC_NAME = "ja_JP.UTF-8";
        LC_NUMERIC = "ja_JP.UTF-8";
        LC_PAPER = "ja_JP.UTF-8";
        LC_TELEPHONE = "ja_JP.UTF-8";
        LC_TIME = "en_GB.UTF-8";
      };
    };
  };
}
