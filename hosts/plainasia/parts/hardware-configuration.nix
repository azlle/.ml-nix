# hosts/plainasia/parts/hardware-configuration.nix
#
# 検証用ミニPCで Live USB から `nixos-generate-config` した結果を元に、実機の
# ハードウェア検出部分だけを反映している。
#
# 元の生成結果には Live USB 自身の一時ファイルシステム (tmpfs root, /iso,
# squashfs overlay) や swapDevices=[]、DHCP設定が含まれていたが、これらは
# 実際にインストールする側のシステムとは無関係 (むしろ disko.nix / networking.nix
# の内容と衝突する) なので取り込んでいない。
#
# `boot.supportedFilesystems`/`boot.zfs.*` は parts/boot.nix 側で設定済みなので
# ここには置かない。
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ]; # Intel CPU (13世代 i7) を確認
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
