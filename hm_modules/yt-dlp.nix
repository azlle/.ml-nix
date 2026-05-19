# yt-dlp.nix
{ pkgs, username, ... }:

let
  yt-dlp-ejs = pkgs.python3Packages.yt-dlp-ejs.overrideAttrs (finalAttrs: {
    version = "0.8.0";
    src = pkgs.fetchFromGitHub {
      owner = "yt-dlp";
      repo = "ejs";
      rev = finalAttrs.version;
      # hash = lib.fakeHash;
      hash = "sha256-+tOA9sPk0BGJHFQCoAC8y5Bz3UcjgIPDQ8WDPkRlW5k=";
    };
  });

  yt-dlp = pkgs.yt-dlp.overrideAttrs (
    finalAttrs: oldAttrs: {
      version = "2026.03.17";
      src = pkgs.fetchFromGitHub {
        owner = "yt-dlp";
        repo = "yt-dlp";
        rev = finalAttrs.version;
        # hash = lib.fakeHash;
        hash = "sha256-A4LUCuKCjpVAOJ8jNoYaC3mRCiKH0/wtcsle0YfZyTA=";
      };
      propagatedBuildInputs = map (
        dep: if dep.pname or "" == "yt-dlp-ejs" then yt-dlp-ejs else dep
      ) oldAttrs.propagatedBuildInputs;
    }
  );

  cookiesFromBrowser =
    if username == "eeshta" then
      "firefox"
    else if username == "miyu" then
      "firefox:/mnt/c/Users/Eeshta/AppData/Roaming/Mozilla/Firefox/Profiles/907uf8a4.default-nightly"
    else
      "firefox";
in

{
  home.packages = [ yt-dlp ];

  xdg.configFile."yt-dlp/config".text = ''
    -o "$HOME/ydl_dest/%(extractor_key)s/%(uploader_id)s/%(timestamp>%Y-%m-%d_%H-%M)s_%(title)s_%(id)s.%(ext)s"
    --cookies-from-browser firefox:/mnt/c/Users/Eeshta/AppData/Roaming/Mozilla/Firefox/Profiles/907uf8a4.default-nightly
    --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:150.0) Gecko/20100101 Firefox/150.0"
    --embed-thumbnail
    --embed-metadata
    --sleep-requests 5
    --sleep-interval 5
    --max-sleep-interval 10
  '';
}
