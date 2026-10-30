# modules/zatta.nix
{ delib, ... }:
delib.module {
  name = "zatta";

  home.always = {
    imports = [
      (
        { lib, pkgs, ... }:
        let
          # CVE-2026-92392 (curl 8.12.0-8.22.0, fixed in 8.23.0): https://curl.se/docs/CVE-2026-92392.html
          # Only the user-facing curl is rebuilt; nothing else depends on it. Delete once nixpkgs ships >= 8.23.0.
          fixedVersion = "8.23.0";
          curl =
            if lib.versionOlder pkgs.curl.version fixedVersion then
              pkgs.curl.overrideAttrs (old: {
                version = fixedVersion;
                src = old.src.overrideAttrs {
                  outputHash = "sha256-ja3X0lNqMU+YKtBaZRtxP0Jr99Aswsds/7l5byIY5sU=";
                };
              })
            else
              pkgs.curl;
        in
        {
          home.packages = [ curl ] ++ (with pkgs; [
            age
            bat
            btop
            claude-code
            ffmpeg-headless
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
          ]);
        }
      )
    ];
  };
}
