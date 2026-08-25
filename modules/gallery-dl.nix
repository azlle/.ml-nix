# modules/gallery-dl.nix
# Dear13ro.に気をつけろ
{ delib, ... }:
delib.module {
  name = "gallery-dl";

  home.always = {
    imports = [
      (
        { pkgs, wsl, ... }:
        let
          gallery-dl = pkgs.gallery-dl.overrideAttrs (
            finalAttrs: _oldAttrs: {
              version = "1.32.9";
              # https://github.com/mikf/gallery-dl/discussions/9304
              src = pkgs.fetchFromCodeberg {
                owner = "mikf";
                repo = "gallery-dl";
                rev = "v${finalAttrs.version}";
                hash = "sha256-3Bva0VQ75mA6B8HsW7zieeXRgRw5DJ6wuASiV3/UiFY=";
              };
            }
          );

          cookiesFromBrowser =
            if wsl then
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
      )
    ];
  };
}
