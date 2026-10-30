# hosts/plainasia/parts/boot.nix
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib) mkForce;
  inherit (lib.kernel) no yes;

  # latest, not LTS: CachyOS's LTS lagged on the CVE-2026-99999 fix.
  # Scheduler/preempt/tick stay at defaults (EEVDF, full, 1000Hz), not the `server` preset:
  # its PREEMPT_NONE has too high a worst-case latency next to game servers.
  cachyKernel = pkgs.cachyosKernels.linux-cachyos-latest-lto-x86_64-v3.override {
    # THP "always" causes khugepaged latency spikes with ZFS ARC + Postgres + PHP; use madvise.
    hugepage = "madvise";

    # Default to BBRv3: throughput on high-latency paths (Cloudflare Tunnel), shorter queues than CUBIC.
    # Not the README's `bbr3 = true`: it builds BBRv1 in, which makes the v3 module fail to load
    # (same BPF kfuncs), so the Kconfig is set directly.
    structuredExtraConfig = {
      TCP_CONG_BBR = mkForce no;
      TCP_CONG_BBR3 = mkForce yes;
      DEFAULT_BBR = mkForce no;
      DEFAULT_BBR3 = mkForce yes;
    };
  };
  cachyHelpers = pkgs.callPackage "${inputs.nix-cachyos-kernel}/helpers.nix" { };
in
{
  boot = {
    # Some out-of-tree modules hardcode gcc; the clang (LTO) kernel needs cc (LLVMOverride).
    # ZFS uses callPackage because `.override { kernel }` keeps the stock KBUILD_OUTPUT ("Permission denied").
    # See: https://github.com/xddxdd/nix-cachyos-kernel/issues/67#issuecomment-4305704829
    kernelPackages = cachyHelpers.kernelModuleLLVMOverride (
      (pkgs.linuxKernel.packagesFor cachyKernel).extend (
        final: _prev: {
          zfs_cachyos = final.callPackage "${inputs.nix-cachyos-kernel}/zfs-cachyos" {
            inherit (inputs.nix-cachyos-kernel) inputs;
            variant = cachyKernel.zfsVariant;
          };
        }
      )
    );

    kernelParams = [
      "amd_pstate=active" # AMD P-State EPP driver (Zen3+)
    ];

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
      # 8TB ミラー + L2ARCキャッシュ用M.2)。forceImportAll は forceImportRoot が
      # 有効な時しか使えない制約があるが、上で true にしてあるので問題ない。
      # rpool と同じ理由 (無人リブート優先) で tank も強制import対象にする。
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

  services = {
    zfs = {
      autoScrub = {
        enable = true;
        # 旧TrueNASの実設定 (storage_scrub) を踏襲しつつ、LONG SMARTテストと
        # 同じ2時台に揃える (14日と28日は絶対に重ならないので衝突しない)。
        interval = "*-*-14 02:00:00";
      };
      trim.enable = true; # NVMe
    };

    # 旧TrueNASの実設定 (services_services / tasks_cronjob) を踏襲。
    # smartdサービス自体はTrueNAS側で有効化されていなかったが、
    # 汎用Cron Jobsとして毎週日曜 02:00 に SHORT、毎月28日 02:30 に LONG の
    # S.M.A.R.T. セルフテストを全ディスクに対して実行していた
    # (`midclt call disk.smart_test SHORT/LONG '["*"]'`)。
    # smartdの -s スケジュール構文は分単位を持たないため、元の30分ずらしが
    # 潰れて両方2時になり、28日が日曜と重なる月に衝突しうる。SHORTを1時に
    # ずらして完全に分離する (LONG/Scrubは14日・28日で日自体が重ならない)。
    smartd = {
      enable = true;
      defaults.monitored = "-a -o on -S on -s (S/../../7/01|L/../28/./02)";
    };

    sanoid = {
      enable = true;
      datasets =
        let
          # 旧TrueNASの実設定 (storage_task) を踏襲: data_pool/main と
          # data_pool/nextcloud (→ tank/main, tank/nextcloud) に対して、毎日00:00・
          # 再帰的・1ヶ月保持のスナップショットを取得。sanoidは経過時間ベースの
          # プルーニング・粒度ごとの独立制御・鮮度監視まで持つ成熟したツールなので、
          # 自作systemd timerより素直にこちらへ寄せる (スナップショットの命名規則
          # だけは sanoid 独自の autosnap_<timestamp>_daily 形式になり、TrueNAS の
          # daily-%Y-%m-%d_%H-%M とは一致しなくなる)。tank/forgejoはnecrofantasia
          # からForgejoを移してきた際に新設 (modules/containers/forgejo.nix)。
          # 旧TrueNAS由来ではないので保持期間は他の2つに合わせただけ。
          common = {
            recursive = true;
            daily = 30;
            hourly = 0;
            weekly = 0;
            monthly = 0;
            yearly = 0;
            autosnap = true;
            autoprune = true;
            # sanoidのNixOSモジュールは systemd.services.sanoid.environment.TZ を
            # "UTC" に固定している (DST切り替え時の欠落/重複を防ぐための上流の
            # 意図的な設計)。そのため daily_hour/daily_min はUTC基準で解釈される。
            # JST 00:00 (旧TrueNASの実行時刻) = UTC 15:00 (前日)。
            daily_hour = 15;
            daily_min = 0;
          };
        in
        {
          "tank/main" = common;
          "tank/nextcloud" = common;
          "tank/forgejo" = common;
        };
    };
  };

  # smartmontools自体はsmartdの依存として既にクロージャに入っているが、
  # environment.systemPackagesに入れないとsmartctlが対話シェルのPATHに出てこない。
  environment.systemPackages = [ pkgs.smartmontools ];
}
