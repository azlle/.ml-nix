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
      forceImportRoot = false;
    };

    # ネイティブ暗号化なしを選んだため、Secure Boot (lanzaboote) の enroll 手順に
    # 見合う利益が薄い。necrofantasia とは別方針。
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    tmp.useTmpfs = true;
  };

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true; # NVMe
  };
}
