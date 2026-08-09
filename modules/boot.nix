# modules/boot.nix
{ delib, inputs, ... }:
delib.module {
  name = "boot";

  nixos.always = {
    imports = [
      inputs.lanzaboote.nixosModules.lanzaboote
      (
        {
          config,
          lib,
          pkgs,
          ...
        }:
        {
          boot = {
            kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-x86_64-v3;

            loader = {
              systemd-boot.enable = lib.mkForce false;
              efi = {
                canTouchEfiVariables = true;
                efiSysMountPoint = "/boot";
              };
            };

            # nix shell nixpkgs#sbctl -> sudo sbctl create-keys -> rebuild -> reboot
            # BIOS: Secure Boot Enable -> Reset to Setup Mode -> Save & Exit
            # sudo sbctl enroll-keys --microsoft -> reboot -> bootctl status
            lanzaboote = {
              enable = true;
              pkiBundle = "/var/lib/sbctl";
            };

            supportedFilesystems = [ "zfs" ];

            zfs = {
              package = config.boot.kernelPackages.zfs_cachyos;
              forceImportRoot = false;
            };

            kernelParams = [
              "amd_pstate=active" # AMD P-State EPP driver (Zen3+)
              "nvidia-drm.modeset=1" # NVIDIA KMS (required for Wayland)
              "preempt=full" # full preemption (no-op on CachyOS BORE)
              "threadirqs" # threaded IRQs (reduces audio latency)
            ];
          };

          networking.hostId = "a53b4ec5";
          environment.systemPackages = with pkgs; [ sbctl ];
        }
      )
    ];
  };
}
