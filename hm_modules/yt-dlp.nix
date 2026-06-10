# yt-dlp.nix
{ pkgs, username, ... }:

let
  yt-dlp-ejs = pkgs.python3Packages.yt-dlp-ejs.overrideAttrs (finalAttrs: {
    version = "0.8.0";
    src = pkgs.fetchFromGitHub {
      owner = "yt-dlp";
      repo = "ejs";
      rev = finalAttrs.version;
      hash = "sha256-+tOA9sPk0BGJHFQCoAC8y5Bz3UcjgIPDQ8WDPkRlW5k=";
    };
  });

  yt-dlp = pkgs.yt-dlp.overrideAttrs (
    finalAttrs: oldAttrs: {
      version = "2026.06.09";
      src = pkgs.fetchFromGitHub {
        owner = "yt-dlp";
        repo = "yt-dlp";
        rev = finalAttrs.version;
        hash = "sha256-ykqTDPzKKIWRGSQmw2esCRKyYqDZKXRYDeba888tkDU=";
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
  programs.yt-dlp = {
    enable = true;
    package = yt-dlp;

    settings = {
      output = "$HOME/ydl_dest/%(extractor_key)s/%(uploader_id)s/%(timestamp>%Y-%m-%d_%H-%M)s_%(title)s_%(id)s.%(ext)s";
      cookies-from-browser = cookiesFromBrowser;
      embed-thumbnail = true;
      embed-metadata = true;
      sleep-requests = "5";
      sleep-interval = "5";
      max-sleep-interval = "10";
    };
  };
}
