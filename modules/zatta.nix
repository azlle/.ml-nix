# modules/zatta.nix
{ delib, ... }:
delib.module {
  name = "zatta";

  home.always = {
    imports = [
      (
        { pkgs, ... }:
        {
          home.packages = with pkgs; [
            age
            bat
            btop
            claude-code
            curl
            ffmpeg
            gh
            htop
            just
            libarchive
            openssh
            rsync
            sops
            ssh-to-age
            unar
            vrc-get
            xz
            zellij
            zstd
          ];
        }
      )
    ];
  };
}
