# nixcord.nix
_:

{
  # programs.nixcord.config.themesが機能してないのでココで配置
  xdg.configFile = {
    "Vencord/themes/midnight-mellow.theme.css".source = ../.config/midnight-mellow.theme.css;
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
}
