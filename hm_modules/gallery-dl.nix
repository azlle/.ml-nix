# gallery-dl.nix
# Dear13ro.に気をつけろ
{ pkgs, ... }:

let
  gallery-dl = pkgs.gallery-dl.overrideAttrs (finalAttrs: {
    version = "1.31.10";
    # https://github.com/mikf/gallery-dl/discussions/9304
    src = pkgs.fetchFromCodeberg {
      owner = "mikf";
      repo = "gallery-dl";
      rev = "v${finalAttrs.version}";
      hash = "sha256-npt9jbBBHgjURmayhNgkSTQZYLC1aysDR83dLOm2Z/s=";
    };
  });
in

{
  home.packages = [ gallery-dl ];

  xdg.configFile."gallery-dl/config.json".text = ''
    {
      "cache": {
        "file": "~/.config/gallery-dl/cache.sqlite3"
      },

      "extractor": {
        "pixiv": {
          "directory": [
            "{category}",
            "{user[id]}_{user[account]}",
            "{series[id]}_{series[title]}",
            "{num_series:>03}.{title}"
          ],
          "filename": "{date:%y%m%d}-{user[account]}-{id}_p{num}.{extension}",
          "refresh-token": "***REMOVED***",
          "cookies": {
            "PHPSESSID": "***REMOVED***"
          }
        },

        "twitter": {
          "directory": ["{category}"],
          "filename": "{date:%y%m%d}-{author[name]}-{filename}.{extension}"
        }
      }
    }
  '';
}
