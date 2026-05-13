# zen-browser.nix
{ pkgs, ... }:

{
  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;

    policies = let
      mkExtensionSettings = builtins.mapAttrs (_: pluginId: {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/${pluginId}/latest.xpi";
        installation_mode = "force_installed";
      });
    in {
      AutofillAddressEnabled = true;
      AutofillCreditCardEnabled = false;
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      Preferences = {
        "browser.startup.homepage" = {
          Value = "chrome://browser/content/aboutDialog.xhtml";
          Status = "locked";
        };
        "browser.tabs.warnOnClose" = {
          Value = false;
          Status = "locked"; # User cannot change this
        };
      };
      ExtensionSettings = mkExtensionSettings {
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = "bitwarden-password-manager";
        "uBlock0@raymondhill.net" = "ublock-origin";
        "jid0-RvYT2rGWfM8q5yWxIxAHYAeo5Qg@jetpack" = "duplicate-tabs-closer";
        "{12cf650b-1822-40aa-bff0-996df6948878}" = "cookies-txt";
        "{e63ff88d-6742-4e81-9544-87f60f0d0c00}" = "twitch-chat-danmaku";
        "{9350bc42-47fb-4598-ae0f-825e3dd9ceba}" = "absolute-enable-right-click";
        "simple-translate@sienori" = "simple-translate";
      };
    };

    profiles = {
      default = {
        pinsForce = true;
        pinsForceAction = "remove";
        extraConfig = ''
          user_pref("browser.urlbar.restrict.history", "!");
        '';
        search = {
          force = true;
          default = "google";
          engines = {
            mynixos = {
              name = "My NixOS";
              urls = [ {
                template = "https://mynixos.com/search?q={searchTerms}";
                params = [ { name = "query"; value = "searchTerms"; } ];
              } ];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = ["!nx"];
            };
          };
        };

        # UUID v4はuuidgen | tr '[:upper:]' '[:lower:]'で生成できる
        pins = {
          "upd.dev: Azlle" = {
            id = "dafa0d6c-c267-490f-9908-617e47cc8d77";
            url = "https://upd.dev/Azlle";
            position = 101;
            isEssential = true;
          };
          "DHU Portal" = {
            id = "f9ad3d13-12fc-4258-b2dd-7625d1056e6e";
            url = "https://portal.dhw.ac.jp/uprx/";
            position = 102;
            isEssential = true;
          };
          "AI" = {
            id = "fff03149-0d8b-4cab-bfd5-0d1924f15a02";
            isGroup = true;
            isFolderCollapsed = true;
            editedTitle = true;
            position = 200;
          };
          "ChatGPT" = {
            id = "77df46b1-3628-4597-956c-36c466a93806";
            url = "https://chatgpt.com/";
            position = 201;
            isEssential = true;
          };
          "Claude" = {
            id = "3d286785-624f-472c-bd9f-c0717a843dbc";
            url = "https://claude.ai/new";
            position = 202;
            isEssential = true;
          };
          "Gemini" = {
            id = "7687cd6a-22db-458b-9213-29432e7d5e3a";
            url = "https://gemini.google.com/app";
            position = 203;
            isEssential = true;
          };
          "Youtube" = {
            id = "6387f985-d895-4507-a9b8-8b09f4e2f5f5";
            url = "https://www.youtube.com/feed/subscriptions";
            position = 300;
            isEssential = true;
          };
          "Twitter" = {
            id = "47d12e04-8306-45ae-ae2a-f71db69613da";
            url = "https://twitter.com/home";
            position = 301;
            isEssential = true;
          };
        };
      };
    };
  };
}
