# LAN固定IPの一元管理。
# plainasia⇄necrofantasia間のNFS export/mountや各ホスト自身のアドレス設定など、
# 同じIPが複数ファイルにハードコードされていたのをここへ集約する
# (アドレスを変える時に1箇所で済むようにする)。flake.nixのspecialArgsで
# `lan`として全モジュール (hosts/*/parts/ の素のNixOSモジュールを含む) に配る。
{
  plainasia = "192.168.11.92";
  necrofantasia = "192.168.11.78";
  gateway = "192.168.11.1";
}
