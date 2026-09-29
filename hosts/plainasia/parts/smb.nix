# hosts/plainasia/parts/smb.nix
# 旧TrueNASの sharing_cifs_share を踏襲: tank/main (旧 data_pool/main) への
# 読み書き共有 "main" と読み取り専用共有 "main_ro"。SMBアクセス権を持つ
# ユーザーは旧環境では "shiki" (uid=1000) のみだったが、こちらでは同じ
# uid=1000 の "keine" で再現する (ACL/所有権はuid経由でそのまま継続する)。
#
# nixpkgsのsambaビルドには zfsacl VFSモジュールが含まれていない
# (Solaris/FreeBSD専用でLinuxには元々存在しないAPIに依存するため)。
# tank/main の acltype を nfsv4 から posix (POSIX ACL) に変更済みなので、
# Linux標準の acl_xattr VFSモジュールでACLがSMB経由でも正しく強制される。
{ config, ... }:
{
  sops.secrets."smb/keine" = { };

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "netbios name" = "plainasia";
        workgroup = "WORKGROUP";
        "server string" = "plainasia";
        security = "user";
        "vfs objects" = "acl_xattr";
        "map acl inherit" = "yes";
      };
      main = {
        path = "/tank/main";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "keine";
      };
      main_ro = {
        path = "/tank/main";
        browseable = "yes";
        "read only" = "yes";
        "guest ok" = "no";
        "valid users" = "keine";
      };
    };
  };

  # SMBは独自のパスワードDB (tdbsam) を持ち、Linuxログインパスワードとは
  # 別管理。switch/boot毎に冪等に同じパスワードを設定し直す (既存ユーザーへの
  # -a は単に更新として働く)。
  systemd.services.smb-set-password = {
    description = "Ensure keine's SMB password matches the sops secret";
    after = [ "samba-smbd.service" ];
    wants = [ "samba-smbd.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ config.services.samba.package ];
    serviceConfig.Type = "oneshot";
    script = ''
      set -euo pipefail
      password=$(cat ${config.sops.secrets."smb/keine".path})
      printf '%s\n%s\n' "$password" "$password" | smbpasswd -s -a -L keine
    '';
  };
}
