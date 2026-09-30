# hosts/necrofantasia/parts/syncthing.nix
# ~/Documents/org-docs をスマホのGrove (https://github.com/rrajath/grove) と
# 同期する。GroveはSyncthing前提の設計 (同じフォルダをSyncthingで共有すれば
# 認識される、.sync-conflict-* の解決UIも内蔵) なので、こちらはただの
# Syncthingフォルダ共有として宣言するだけでよい。
#
# スマホ側のDevice IDが判明したら devices に追加し、folders.org-docs.devices
# にもそのデバイス名を加えること (Syncthingは双方向ペアリングなので、
# スマホ側でもnecrofantasiaのDevice IDを登録・共有フォルダを承認する必要がある)。
_:
{
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
          devices = [ ];
        };
      };

      devices = { };
    };
  };
}
