# justfile — このリポジトリでよく使うコマンド集
#
# ビルドグラフは Nix が持っているので、ここは「長いコマンドに名前を付ける」だけの
# コマンドランナーとして使う (make のような依存解決・タイムスタンプ判定はしない)。
#
#   just            レシピ一覧
#   just <recipe>   実行

# NixOS として構成されるホスト (sumizomenosakura は WSL / home-manager のみ)
nixos_hosts := "necrofantasia plainasia"

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

# 破壊的操作を含むので disko-install の前に必ず読むこと。
# disko が生成するパーティショニングスクリプトを表示する
disko-script host:
    nix build ".#nixosConfigurations.{{host}}.config.system.build.diskoScript" \
      -o result-disko-{{host}}
    @echo "--- result-disko-{{host}} ---"
    @cat result-disko-{{host}}

# 対象ディスクを検討するための一覧 (by-id を使うこと)
disks:
    lsblk -o NAME,SIZE,MODEL,SERIAL
    @echo
    ls -l /dev/disk/by-id/

# device はデフォルト値を持たせていないので `just disko-install` だけでは何も起きない。
# 必ず /dev/disk/by-id/... の安定パスを指定すること (/dev/sdX は起動ごとに変わる)。
# 事前に `just disko-script <host>` でスクリプトを読むこと。
# !!! 危険 !!! 指定ディスクを全消去して NixOS をインストールする
disko-install host device:
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
    echo "!!! {{device}} 上の全データを破棄して {{host}} をインストールします !!!"
    readlink -f "{{device}}" | xargs -r lsblk -o NAME,SIZE,MODEL,SERIAL
    read -rp "続行するには 'yes' と入力: " reply
    [ "$reply" = "yes" ] || { echo "中止した。"; exit 1; }
    sudo nix run 'github:nix-community/disko/latest#disko-install' -- \
      --flake ".#{{host}}" --disk main "{{device}}"

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
