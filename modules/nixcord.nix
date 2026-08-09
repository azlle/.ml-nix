# modules/nixcord.nix
{ delib, inputs, ... }:
delib.module {
  name = "nixcord";

  home.always = {
    imports = [ inputs.nixcord.homeModules.nixcord ];

    # programs.nixcord.config.themesが機能してないのでココで配置
    xdg.configFile = {
      "Vencord/themes/midnight-mellow.theme.css".source = ../hm_modules/.config/midnight-mellow.theme.css;
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
