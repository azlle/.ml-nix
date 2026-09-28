# hosts/plainasia/parts/boot.nix
{ config, pkgs, ... }:

{
  boot = {
    # CachyOS には BORE + LTS の組み合わせが存在しない (BORE は latest カーネル、
    # LTS は EEVDF + Cachy Sauce)。ZFS モジュールも zfs-cachyos-lts 系しか LTS に
    # 対応しない。NAS 用途には BORE (対話・ゲーミング向け) より EEVDF が適合する。
    # x86_64-v3 は 13世代 i7 (検証機) / Ryzen 5 5600G (本番機) 双方が対応する。
    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-lts-lto-x86_64-v3;

    supportedFilesystems = [ "zfs" ];
    zfs = {
      package = config.boot.kernelPackages.zfs_cachyos;
      # necrofantasia の boot.nix から流用した際の取り残し。necrofantasia は root が
      # ZFS ではないので false でも無害だったが、plainasia は root 自体が rpool。
      # インストール直後の初回起動時、プールがクリーンに export されていない状態
      # (通常の手順で普通に起きる) だと -f 無しでは import を拒否され、
      # "Failed to start Import ZFS pool" で emergency mode に落ちる。
      forceImportRoot = true;

      # 旧 TrueNAS の data_pool を tank としてリネームimport済み (IronWolf
      # 8TB ミラー)。forceImportAll は forceImportRoot が有効な時しか使えない
      # 制約があるが、上で true にしてあるので問題ない。rpool と同じ理由
      # (無人リブート優先) で tank も強制import対象にする。
      extraPools = [ "tank" ];
      forceImportAll = true;
    };

    # ネイティブ暗号化なしを選んだため、Secure Boot (lanzaboote) の enroll 手順に
    # 見合う利益が薄い。necrofantasia とは別方針。
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;

      # 上限が無いと世代ごとの kernel+initrd が無限に ESP に溜まる。実測で
      # bzImage 11M + initrd 44M = 1世代あたり55M (カーネル更新を伴う最悪ケース
      # 想定)。20世代だと switch 中のピークで 21 * 55M ≈ 1155M となり、2G の
      # ESP なら十分収まる (1G だと超過する)。nh の --keep よりだいぶ多めの
      # バッファを持たせてある。
      systemd-boot.configurationLimit = 20;
    };

    tmp.useTmpfs = true;
  };

  services.zfs = {
    autoScrub = {
      enable = true;
      # 旧TrueNASの実設定 (storage_scrub) を踏襲: 毎月14日 02:30。
      # (NixOSのデフォルトは "monthly" = 毎月1日 00:00)
      interval = "*-*-14 02:30:00";
    };
    trim.enable = true; # NVMe
  };

  # 旧TrueNASの実設定 (services_services / tasks_cronjob) を踏襲。
  # smartdサービス自体はTrueNAS側で有効化されていなかったが、
  # 汎用Cron Jobsとして毎週日曜 02:00 に SHORT、毎月28日 02:30 に LONG の
  # S.M.A.R.T. セルフテストを全ディスクに対して実行していた
  # (`midclt call disk.smart_test SHORT/LONG '["*"]'`)。
  # smartdの -s スケジュール構文は分単位を持たないため、時刻は時間単位に丸まる。
  services.smartd = {
    enable = true;
    defaults.monitored = "-a -o on -S on -s (S/../../7/02|L/../28/./02)";
  };

  # 旧TrueNASの実設定 (storage_task) を踏襲: data_pool/main と
  # data_pool/nextcloud (→ tank/main, tank/nextcloud) に対して、毎日00:00・
  # 再帰的・"daily-%Y-%m-%d_%H-%M" 命名・1ヶ月保持のスナップショットを取得。
  #
  # services.zfs.autoSnapshot は frequent/hourly/daily/weekly/monthly の
  # 5段階が無条件で有効になり「毎日だけ」を綺麗に無効化できない (件数を0に
  # しても、スナップショット作成→即削除という無駄な動作自体は残る) ため、
  # 独自の systemd timer で実際の挙動 (毎日1回・命名規則・保持数) を再現する。
  systemd.services.zfs-daily-snapshot = {
    description = "Daily recursive ZFS snapshots for tank/main and tank/nextcloud";
    after = [ "zfs-import.target" ];
    path = [ config.boot.zfs.package ];
    serviceConfig.Type = "oneshot";
    script = ''
      set -euo pipefail
      stamp=$(date +%Y-%m-%d_%H-%M)
      for ds in tank/main tank/nextcloud; do
        zfs snapshot -r "$ds@daily-$stamp"
        # 1ヶ月 (30日) より古い daily-* スナップショットを削除。
        zfs list -H -o name -t snapshot -r "$ds" \
          | grep -E "@daily-[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2}$" \
          | while read -r snap; do
              snapDate="''${snap#*@daily-}"
              snapDate="''${snapDate%_*}"
              ageDays=$(( ($(date +%s) - $(date -d "$snapDate" +%s)) / 86400 ))
              if [ "$ageDays" -gt 30 ]; then
                zfs destroy "$snap"
              fi
            done
      done
    '';
  };

  systemd.timers.zfs-daily-snapshot = {
    description = "Run zfs-daily-snapshot every day at 00:00";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 00:00:00";
      Persistent = true;
    };
  };
}
