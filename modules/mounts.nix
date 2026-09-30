# modules/mounts.nix
{ delib, ... }:
delib.module {
  name = "mounts";

  nixos.always = {
    imports = [
      (
        { pkgs, ... }:
        {
          environment.systemPackages = with pkgs; [
            btrfs-progs
            exfatprogs
            gptfdisk
          ];
        }
      )
    ];
  };
}
