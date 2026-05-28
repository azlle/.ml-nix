# gallery-dl.nix
# Dear13ro.に気をつけろ
{ pkgs, username, ... }:

let
  gallery-dl = pkgs.gallery-dl.overrideAttrs (
    finalAttrs: _oldAttrs: {
      version = "1.31.10";
      # https://github.com/mikf/gallery-dl/discussions/9304
      src = pkgs.fetchFromCodeberg {
        owner = "mikf";
        repo = "gallery-dl";
        rev = "v${finalAttrs.version}";
        hash = "sha256-npt9jbBBHgjURmayhNgkSTQZYLC1aysDR83dLOm2Z/s=";
      };
    }
  );

  cookiesFromBrowser =
    if username == "eeshta" then
      [
        "firefox"
      ]
    else if username == "miyu" then
      [
        "firefox"
        "/mnt/c/Users/Eeshta/AppData/Roaming/Mozilla/Firefox/Profiles/907uf8a4.default-nightly"
      ]
    else
      [
        "firefox"
      ];
in

{
  programs.gallery-dl = {
    enable = true;
    package = gallery-dl;

    settings = {
      cache.file = "~/.config/gallery-dl/cache.sqlite3";

      extractor = {
        cookies = cookiesFromBrowser;
        fallback = false;

        pixiv = {
          directory = [
            "{category}"
            "{user[id]}_{user[account]}"
            "{series[id]}_{series[title]}"
            "{num_series:>03}.{title}"
          ];
          filename = "{date:%y%m%d}-{user[account]}-{id}_p{num}.{extension}";
        };

        twitter = {
          conversations = true;
          directory = [
            "{category}"
          ];
          filename = "{date:%y%m%d}-{author[name]}-{filename}.{extension}";
          replies = "self";
          size = [
            "orig"
          ];
        };
      };
    };
  };
}
