# modules/desktop/nixcord.nix
{ delib, inputs, ... }:
delib.module {
  name = "desktop.nixcord";

  options = delib.singleCascadeEnableOption;

  # nixcord only registers its options here; it has no effect until enabled below.
  home.always.imports = [ inputs.nixcord.homeModules.nixcord ];

  home.ifEnabled = {
    # programs.nixcord.config.themesが機能してないのでココで配置
    xdg.configFile = {
      "Vencord/themes/midnight-mellow.theme.css".source =
        ../../hm_modules/.config/midnight-mellow.theme.css;
    };

    programs.nixcord = {
      enable = true;
      discord.vencord.enable = true;
      config = {
        enabledThemes = [ "midnight-mellow.theme.css" ];
        plugins = {
          platformIndicators.enable = true;
          betterFolders.enable = true;
          mentionAvatars.enable = true;
          openInApp.enable = true;
          alwaysAnimate.enable = true;
          alwaysTrust.enable = true;
        };
      };
    };
  };
}
