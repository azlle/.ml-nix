#!/usr/bin/env nu
# scripts/disko-layout.nu
#
# `just partition` から呼ばれる。disko が生成する実際のシェルスクリプトは
# 数百行あり (内部関数・UUID処理等を含む) tty で確認プロンプトの前に流すと
# 肝心の情報が流れてしまうため、disko.nix 自身の宣言 (パーティション/データ
# セット構成) だけを nix eval で取り出し、簡潔な表にして見せる。
#
# 読み取り専用・非対話 (確認プロンプトや disko.nix の書き換え・実行は
# justfile 側の bash に残したまま)。nu の `input` はターミナル経由専用で
# パイプされた標準入力を読めない (非TTYだとI/Oエラーになる) ため、対話や
# 副作用を持つ処理はここに持ち込まない。
#
# nix_flakes/nix_substituters は justfile の同名変数と揃えること。

const NIX_FLAGS = [--extra-experimental-features "nix-command flakes"]

# hosts/<host>/parts/disko.nix の disko.devices を JSON 安全な形に整形して
# 取り出す Nix 式。config.disko.devices は内部実装用に関数値 (_pkgs 等) を
# 含んでおり、生の --json では "cannot convert a function to JSON" で
# 落ちるため、必要なフィールドだけを --apply で明示的に抽出する。
const SUMMARY_APPLY = "d:
{
  disks = map (k: {
    name = k;
    device = d.disk.${k}.device;
    partitions = map (pk: {
      name = pk;
      size = d.disk.${k}.content.partitions.${pk}.size;
      dest =
        let c = d.disk.${k}.content.partitions.${pk}.content; in
        if (c.type or \"\") == \"filesystem\" then c.mountpoint
        else if (c.type or \"\") == \"swap\" then \"swap\"
        else if (c.type or \"\") == \"zfs\" then \"zfs pool ${c.pool}\"
        else c.type or \"?\";
    }) (builtins.attrNames d.disk.${k}.content.partitions);
  }) (builtins.attrNames d.disk);
  zpools = map (k: {
    name = k;
    datasets = map (dk: {
      name = dk;
      mountpoint = let m = d.zpool.${k}.datasets.${dk}.mountpoint or null; in if m == null then \"(none)\" else m;
    }) (builtins.filter (dk: builtins.substring 0 2 dk != \"__\") (builtins.attrNames d.zpool.${k}.datasets));
  }) (builtins.attrNames d.zpool);
}"

def main [host: string] {
  let devices = (
    ^nix ...$NIX_FLAGS eval --json $".#nixosConfigurations.($host).config.disko.devices" --apply $SUMMARY_APPLY
    | from json
  )

  for disk in $devices.disks {
    print $"disk ($disk.name): ($disk.device)"
    print ($disk.partitions | select name size dest)
  }
  for pool in $devices.zpools {
    print $"zpool ($pool.name)"
    print ($pool.datasets | select name mountpoint)
  }
}
