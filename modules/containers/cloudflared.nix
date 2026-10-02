# modules/containers/cloudflared.nix
{ delib, config, ... }:
delib.module {
  name = "containers.cloudflared";

  options = delib.singleCascadeEnableOption;

  nixos.ifEnabled = {
    services.cloudflared = {
      enable = true;
      tunnels."8a2ddac7-52f5-4cda-93fe-fd25b2fea880" = {
        credentialsFile = config.sops.secrets."cloudflared/melocy-edge".path;
        default = "http_status:404";
        # デフォルトのauto (QUIC優先) だと、家庭用ルーター/ISPがUDPの
        # パスMTU/フラグメンテーションを正しく扱えない場合に著しい速度低下を
        # 招くことがある (実測でdrive.melocy.cc経由の転送がLAN直結の87分の1
        # だった)。TCPベースのhttp2に固定してこれを回避できるか検証する。
        protocol = "http2";
        ingress = {
          # cloudflared 自体は plainasia (Nextcloud と同居) で動く。
          # git系は necrofantasia 上の Forgejo に LAN 越しで繋ぐ。
          "drive.melocy.cc" = "http://localhost:22300";
          "git.melocy.cc" = "http://192.168.11.78:3080";
          "git-ssh.melocy.cc" = "ssh://192.168.11.78:2222";
        };
      };
    };
  };
}
