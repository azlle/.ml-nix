# justfile — このリポジトリでよく使うコマンド集
#
# ビルドグラフは Nix が持っているので、ここは「長いコマンドに名前を付ける」だけの
# コマンドランナーとして使う (make のような依存解決・タイムスタンプ判定はしない)。
#
#   just            レシピ一覧
#   just <recipe>   実行

# NixOS として構成されるホスト (sumizomenosakura は WSL / home-manager のみ)
nixos_hosts := "necrofantasia plainasia"

# disko系レシピはインストール済みシステムだけでなく Live ISO 上でも動く前提。
# インストール済み側は modules/nix.nix で experimental-features が有効だが、
# Live ISO のデフォルト nix.conf は保証がないので明示的に付ける。
nix_flakes := "--extra-experimental-features \"nix-command flakes\""

# インストール済みシステムでは modules/nix.nix (nixSettings) がこれを常に設定するが、
# Live ISO 上の素の nix はまだこの flake の設定下で動いていないので知らない。
# 特に nix-cachyos-kernel (attic.xuyh0120.win/lantian) が無いと、cachyos の
# LTO付きカーネルをソースから毎回ビルドする羽目になり、時間・容量・メモリを大量に
# 消費する (LTO のリンク工程は特にメモリを食う)。partition/install ではこれを
# 明示する。
nix_substituters := "--option extra-substituters \"https://nix-community.cachix.org https://attic.xuyh0120.win/lantian https://wezterm.cachix.org\" --option extra-trusted-public-keys \"nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc= wezterm.cachix.org-1:kAbhjYUC9qvblTE+s7S+kl5XM1zVa4skO+E/1IDWdH0=\""

# 引数なしで叩いたらレシピ一覧を出す
default:
    @just --list

# ---------------------------------------------------------------- 検証

# 全ホストの eval を検証する
check:
    nix flake check

# NixOS ホストを全部ビルドする (変更のリグレッション確認用)
build-all:
    #!/usr/bin/env bash
    set -euo pipefail
    for h in {{nixos_hosts}}; do
      echo "==> $h"
      nix build --no-link ".#nixosConfigurations.$h.config.system.build.toplevel"
    done

# 指定ホストをビルドする
build host:
    nix build --no-link ".#nixosConfigurations.{{host}}.config.system.build.toplevel"

# 現在の変更で必要になるビルドを、適用せずに確認する
dry host:
    nixos-rebuild dry-build --flake ".#{{host}}"

# ---------------------------------------------------------------- 調査

# 指定ホストで desktop/containers の cascade がどう解決されたかを表示する
show-enabled host:
    #!/usr/bin/env bash
    set -euo pipefail
    for a in host.type host.isPC host.isServer \
             desktop.enable containers.enable \
             containers.forgejo.enable containers.cloudflared.enable; do
      printf '%-34s = ' "$a"
      # nix は "Using saved setting ..." を stderr に出すので、成功時は捨てて
      # 整形を保ち、失敗したときだけ中身を見せる。
      if out=$(nix eval ".#nixosConfigurations.{{host}}.config.myconfig.$a" 2>/tmp/.just-eval-err); then
        echo "$out"
      else
        echo "ERROR"; cat /tmp/.just-eval-err >&2
      fi
    done
    rm -f /tmp/.just-eval-err

# 任意の設定値を評価する (例: just eval plainasia fileSystems)
eval host attr:
    nix eval ".#nixosConfigurations.{{host}}.config.{{attr}}"

# 指定ホストがマウントするファイルシステム一覧
mounts host:
    nix eval --json ".#nixosConfigurations.{{host}}.config.fileSystems" \
      --apply 'fs: builtins.attrNames fs'

# ---------------------------------------------------------------- disko

# 破壊的操作を含むので partition の前に必ず読むこと。
# disko が生成するパーティショニングスクリプトを表示する
disko-script host:
    nix {{nix_flakes}} {{nix_substituters}} build ".#nixosConfigurations.{{host}}.config.system.build.diskoScript" \
      -o result-disko-{{host}}
    @echo "--- result-disko-{{host}} ---"
    @cat result-disko-{{host}}

# 対象ディスクを検討するための一覧 (by-id を使うこと)
disks:
    lsblk -o NAME,SIZE,MODEL,SERIAL
    @echo
    ls -l /dev/disk/by-id/

# device はデフォルト値を持たせていないので `just partition` だけでは何も
# 起きない。必ず /dev/disk/by-id/... の安定パスを指定すること
# (/dev/sdX は起動ごとに変わる)。事前に `just disko-script <host>` でスクリプトを
# 読むこと。
#
# diskoプロジェクト自身の一括バイナリ (disko#disko-install) は使わない。あれは
# パーティショニングより先にシステム全体をビルドするため、実ディスクがまだ無い段階で
# Live ISO の tmpfs 上にフルのクロージャを構築しようとして、RAM が潤沢でも (32GB でも)
# OOM Killer に落とされることがある
# (https://discourse.nixos.org/t/disko-install-oom-killed/57688)。
# 代わりにパーティショニング (このレシピ) とビルド (`just install`) を分離し、
# ビルド開始前に実ディスク側の swap 等が使える状態にしてから進む。
#
# 素の `disko --flake` は --arg/--argstr でのデバイス上書きが効かない (flake モード
# 未対応、実測で確認済み) ため、hosts/<host>/parts/disko.nix のプレースホルダーを
# 実デバイスパスへ直接書き換える。成功したらそのまま残す (`just install` と、以後の
# rebuild の両方がこれを必要とするため)。失敗した時だけプレースホルダーに戻す。
# !!! 危険 !!! 指定ディスクを全消去する
partition host device:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ ! -e "{{device}}" ]; then
      echo "エラー: {{device}} が存在しない。\`just disks\` で確認すること。" >&2
      exit 1
    fi
    case "{{device}}" in
      /dev/disk/by-id/*) ;;
      *) echo "警告: {{device}} は by-id パスではない。起動ごとに指す先が変わりうる。" >&2 ;;
    esac
    echo "!!! {{device}} 上の全データを破棄して {{host}} 用にパーティショニングします !!!"
    readlink -f "{{device}}" | xargs -r lsblk -o NAME,SIZE,MODEL,SERIAL
    read -rp "続行するには 'yes' と入力: " reply
    [ "$reply" = "yes" ] || { echo "中止した。"; exit 1; }

    echo "--- 事前フェッチ (自分の権限で、ビルドはしない) ---"
    nix {{nix_flakes}} flake archive

    diskoFile="hosts/{{host}}/parts/disko.nix"
    cp "$diskoFile" "$diskoFile.bak"
    trap 'mv -f "$diskoFile.bak" "$diskoFile"; echo "失敗したため $diskoFile をプレースホルダーに戻した" >&2' ERR
    sed -i "s|/dev/disk/by-id/REPLACE_AT_INSTALL_TIME|{{device}}|" "$diskoFile"

    sudo nix {{nix_flakes}} {{nix_substituters}} run github:nix-community/disko/latest -- \
      --mode destroy,format,mount --flake ".#{{host}}" --yes-wipe-all-disks

    trap - ERR
    rm -f "$diskoFile.bak"
    echo "パーティショニング成功。$diskoFile に実デバイスパスを残した。"
    echo "次に \`just install {{host}}\` を実行すること。"

# disko.nix には既に実デバイスパスが入っている前提 (プレースホルダーのままなら
# 先に partition が要る)。既に partition 済み (中身は壊さない) のディスクを、
# 別セッション (再起動後の Live USB など) から /mnt へ繋ぎ直すだけの非破壊的レシピ
mount host:
    #!/usr/bin/env bash
    set -euo pipefail
    diskoFile="hosts/{{host}}/parts/disko.nix"
    if grep -q REPLACE_AT_INSTALL_TIME "$diskoFile"; then
      echo "エラー: $diskoFile がまだプレースホルダーのまま。" >&2
      echo "先に \`just partition {{host}} <device>\` を実行すること。" >&2
      exit 1
    fi
    nix {{nix_flakes}} flake archive
    sudo nix {{nix_flakes}} {{nix_substituters}} run github:nix-community/disko/latest -- \
      --mode mount --flake ".#{{host}}"

# 事前に `just partition <host> <device>` が必要 (disko / nixos-install
# どちらもデフォルトのマウントポイントが /mnt で揃っているので、そのまま繋がる)。
# 標準の nixos-install でビルド・インストールを実行する
install host:
    #!/usr/bin/env bash
    set -euo pipefail
    diskoFile="hosts/{{host}}/parts/disko.nix"
    if grep -q REPLACE_AT_INSTALL_TIME "$diskoFile"; then
      echo "エラー: $diskoFile がまだプレースホルダーのまま。" >&2
      echo "先に \`just partition {{host}} <device>\` を実行すること。" >&2
      exit 1
    fi
    sudo nixos-install --flake ".#{{host}}" {{nix_substituters}}

# ---------------------------------------------------------------- 保守

# --no-cache が要る: statix/deadnix が構文木を書き換えると nixfmt が再整形すべき
# 状態になるが、キャッシュが効いていると2回目が丸ごとスキップされ、`just fmt` は
# 「0 changed」と言うのに `just check` の formatting が落ちる、という食い違いが出る。
# treefmt (nixfmt + statix + deadnix) をかける
fmt:
    nix fmt -- --no-cache

# flake input を全部更新する
update:
    nix flake update

# 特定の input だけ更新する (例: just update-input nixpkgs)
update-input input:
    nix flake update {{input}}
