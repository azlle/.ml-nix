# hosts/necrofantasia/parts/syncthing.nix
# ~/Documents/org-docs をスマホのGrove (https://github.com/rrajath/grove) と
# 同期する。GroveはSyncthing前提の設計 (同じフォルダをSyncthingで共有すれば
# 認識される、.sync-conflict-* の解決UIも内蔵) なので、こちらはただの
# Syncthingフォルダ共有として宣言するだけでよい。
#
# スマホ側でもnecrofantasiaのDevice ID (journalctl -u syncthing の
# "Calculated our device ID" 行で確認可能) を登録し、共有フォルダの
# リクエストを承認する必要がある (Syncthingは双方向ペアリングのため)。
_: {
  services.syncthing = {
    enable = true;
    user = "eeshta";
    group = "users";
    dataDir = "/home/eeshta";
    guiAddress = "127.0.0.1:8384";
    openDefaultPorts = true;

    settings = {
      folders = {
        "org-docs" = {
          path = "/home/eeshta/Documents/org-docs";
          devices = [ "phone" ];
          ignores.lines = [ ".git" ];
        };
      };

      devices = {
        "phone" = {
          id = "7YKCWPD-QOQFLRP-BAQEJL3-OW3E3BI-N65UZ6Y-AYHZ2FJ-OZ3GLXE-A7FTXQ7";
        };
      };
    };
  };
}
