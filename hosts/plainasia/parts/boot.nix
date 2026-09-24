# hosts/plainasia/parts/boot.nix
{ config, pkgs, ... }:
{
  boot = {
    # CachyOS には BORE + LTS の組み合わせが存在しない (BORE は latest カーネル、
    # LTS は EEVDF + Cachy Sauce)。ZFS モジュールも zfs-cachyos-lts 系しか LTS に
    # 対応しない。NAS 用途には BORE (対話・ゲーミング向け) より EEVDF が適合する。
    # x86_64-v3 は 13世代 i7 (検証機) / Ryzen 7 5700G (本番機) 双方が対応する。
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
    autoScrub.enable = true;
    trim.enable = true; # NVMe
  };
}
