# justfile — このリポジトリでよく使うコマンド集
#
# ビルドグラフは Nix が持っているので、ここは「長いコマンドに名前を付ける」だけの
# コマンドランナーとして使う (make のような依存解決・タイムスタンプ判定はしない)。
#
#   just            レシピ一覧
#   just <recipe>   実行

# NixOS として構成されるホスト (sumizomenosakura は WSL / home-manager のみ)
nixos_hosts := "necrofantasia plainasia"

# Live環境ではnix-commandとflakes、そしてsubstitutersの設定がめんどくさいのでこのようにしておく
nix_flakes := "--extra-experimental-features \"nix-command flakes\""
nix_substituters := "--option extra-substituters \"https://nix-community.cachix.org https://attic.xuyh0120.win/lantian https://wezterm.cachix.org\" --option extra-trusted-public-keys \"nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc= wezterm.cachix.org-1:kAbhjYUC9qvblTE+s7S+kl5XM1zVa4skO+E/1IDWdH0=\""

# 引数なしで叩いたらレシピ一覧を出す
default:
    @just --list

# ==================== Verification ====================

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

# ==================== Inspection ====================

# 指定ホストで desktop/containers の cascade がどう解決されたかを表示する
show-enabled host:
    #!/usr/bin/env bash
    set -euo pipefail
    errfile=$(mktemp)
    trap 'rm -f "$errfile"' EXIT
    for a in host.type host.isPC host.isServer \
             desktop.enable containers.enable \
             containers.forgejo.enable containers.cloudflared.enable; do
      printf '%-34s = ' "$a"
      # nix は "Using saved setting ..." を stderr に出すので、成功時は捨てて
      # 整形を保ち、失敗したときだけ中身を見せる。
      if out=$(nix eval ".#nixosConfigurations.{{host}}.config.myconfig.$a" 2>"$errfile"); then
        echo "$out"
      else
        echo "ERROR"; cat "$errfile" >&2
      fi
    done

# 任意の設定値を評価する (例: just eval plainasia fileSystems)
eval host attr:
    nix eval ".#nixosConfigurations.{{host}}.config.{{attr}}"

# 指定ホストがマウントするファイルシステム一覧
list-mounts host:
    nix eval --json ".#nixosConfigurations.{{host}}.config.fileSystems" \
      --apply 'fs: builtins.attrNames fs'

# ==================== disko ====================

# disko.nix が実デバイスパスになっているか確認する
_check-disko-ready host:
    #!/usr/bin/env bash
    set -euo pipefail
    diskoFile="hosts/{{host}}/parts/disko.nix"
    if grep -q REPLACE_AT_INSTALL_TIME "$diskoFile"; then
      echo "エラー: $diskoFile がまだプレースホルダーのまま。" >&2
      echo "先に \`just partition {{host}} <device>\` を実行すること。" >&2
      exit 1
    fi

# sudoはSSH_AUTH_SOCKを継承せず、git+sshを使用するml-secretsのfetchが不可能となるために、これを用意する
# これによりinputsだけ取得、ビルド時に再利用できる
_prefetch:
    @echo "--- 事前フェッチ (自分の権限で、ビルドはしない) ---"
    nix {{nix_flakes}} flake archive

# 対象ディスクを検討するための一覧 (by-id を使うこと)
disks:
    lsblk -o NAME,SIZE,MODEL,SERIAL
    @echo
    ls -l /dev/disk/by-id/

# device は /dev/disk/by-id/ 配下の名前だけ渡せばいい (`just disks` で確認できる
# 短い名前の方)。プレフィックスは固定してあるので毎回フルパスを打つ必要はない
# (フルパスを渡しても動く)。/dev/sdX のような不安定パスは前提にしていない
# (起動ごとに指す先が変わりうるため)。
#
# OOM Killerへの対策として、partitionとinstallは分割して実行する。
# 素の `disko --flake` は --arg/--argstr でのデバイス上書きが効かない (flake モード
# 未対応、実測で確認済み) ため、確認プロンプトの前に hosts/<host>/parts/disko.nix の
# プレースホルダーを実デバイスパスへ直接書き換え、その状態で評価した構成を見せる
# (実際にどのデバイス・レイアウトになるかをそのまま確認できる)。'yes' で進めたら
# そのまま残す (`just install` と、以後の rebuild の両方がこれを必要とするため)。
# 'yes' 以外・失敗のどちらでもプレースホルダーに戻す。
partition host device: _prefetch
    #!/usr/bin/env bash
    set -euo pipefail
    case "{{device}}" in
      /dev/disk/by-id/*) device="{{device}}" ;;
      *) device="/dev/disk/by-id/{{device}}" ;;
    esac
    if [ ! -e "$device" ]; then
      echo "エラー: $device が存在しない。\`just disks\` で確認すること。" >&2
      exit 1
    fi

    diskoFile="hosts/{{host}}/parts/disko.nix"
    cp "$diskoFile" "$diskoFile.bak"
    trap 'mv -f "$diskoFile.bak" "$diskoFile" 2>/dev/null; echo "$diskoFile をプレースホルダーに戻した" >&2' EXIT
    sed -i "s|/dev/disk/by-id/REPLACE_AT_INSTALL_TIME|$device|" "$diskoFile"

    echo "--- {{host}} の disko レイアウト ($device) ---"
    nix {{nix_flakes}} run nixpkgs#nushell -- scripts/disko-layout.nu {{host}}
    echo
    echo "!!! $device 上の全データを破棄して {{host}} 用にパーティショニングします !!!"
    readlink -f "$device" | xargs -r lsblk -o NAME,SIZE,MODEL,SERIAL
    read -rp "続行するには 'yes' と入力: " reply
    [ "$reply" = "yes" ] || { echo "中止した。"; exit 1; }

    sudo nix {{nix_flakes}} {{nix_substituters}} run github:nix-community/disko/latest -- \
      --mode destroy,format,mount --flake ".#{{host}}" --yes-wipe-all-disks

    trap - EXIT
    rm -f "$diskoFile.bak"
    echo "パーティショニング成功。$diskoFile に実デバイスパスを残した。"
    echo "次に \`just install {{host}}\` を実行すること。"

# age鍵が無いと setupSecrets が黙って失敗する (installation finished! と出るのに気づけない)
# eeshta はまだ存在しないので UID/GID は数値 (1000:100) で指定する
# nixos-install でビルド・インストールし、Live ISO 上の .ml-nix と ~/.ssh を
# /mnt/home/eeshta へコピーする (再起動後の再 clone / 鍵再生成を省く)
install host: (_check-disko-ready host) _prefetch
    #!/usr/bin/env bash
    set -euo pipefail
    ageKeyFile="/mnt/var/lib/sops-nix/age-{{host}}"
    if [ ! -s "$ageKeyFile" ]; then
      echo "エラー: $ageKeyFile が無い (またはサイズ0)。secrets が復号できないまま進む。" >&2
      echo "age-keygen で {{host}} 用の鍵を作り、そこへ置いてから再実行すること。" >&2
      exit 1
    fi
    sudo nixos-install --flake ".#{{host}}" {{nix_substituters}}

    sudo mkdir -p /mnt/home/eeshta

    echo "--- $(pwd) を /mnt/home/eeshta/.ml-nix へコピー ---"
    sudo cp -r "$(pwd)" /mnt/home/eeshta/.ml-nix
    # result-disko-* は Live ISO の /nix/store を指す symlink で再起動後に解決できないので除外
    sudo find /mnt/home/eeshta/.ml-nix -maxdepth 1 -name 'result*' -type l -delete

    if [ -d "$HOME/.ssh" ]; then
      echo "--- $HOME/.ssh を /mnt/home/eeshta/.ssh へコピー ---"
      sudo mkdir -p /mnt/home/eeshta/.ssh
      sudo cp -r "$HOME/.ssh/." /mnt/home/eeshta/.ssh/
      sudo chmod 700 /mnt/home/eeshta/.ssh
      sudo find /mnt/home/eeshta/.ssh -maxdepth 1 -type f ! -name "*.pub" -exec chmod 600 {} +
    else
      echo "警告: $HOME/.ssh が無いのでSSH鍵はコピーしなかった。" >&2
    fi

    sudo chown -R 1000:100 /mnt/home/eeshta
    echo "完了。/mnt/home/eeshta に .ml-nix と .ssh をコピーした。"

# ==================== Maintenance ====================

fmt:
    nix fmt -- --no-cache

update input="":
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -z "{{input}}" ]; then
      nix flake update
    else
      nix flake update "{{input}}"
    fi
