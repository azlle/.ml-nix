# zsh.nix
{
  pkgs,
  config,
  lib,
  ...
}:
with lib;

{
  xdg.configFile."zsh" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.ml-nix/hm_modules/.config/zsh";
  };

  home.packages = with pkgs; [
    sheldon
    keychain
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = false;

    initContent = mkMerge [
      (mkOrder 500 ''
        # zmodload zsh/zprof
        export LANG=en_US.UTF-8
        ZSH_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

        # source "$ZSH_HOME/zcompile.zsh"
        source "$ZSH_HOME/setopt.zsh"
      '')

      (mkOrder 1000 ''
        source "$ZSH_HOME/comp.zsh"
        source "$ZSH_HOME/history.zsh"
        source "$ZSH_HOME/keychain.zsh"
      '')

      (mkOrder 1500 ''
        source "$ZSH_HOME/sheldon.zsh"
        source "$ZSH_HOME/alias.zsh"
        source "$ZSH_HOME/bindkey.zsh"

        [ -n "$EAT_SHELL_INTEGRATION_DIR" ] && \
          source "$EAT_SHELL_INTEGRATION_DIR/zsh"

        # zsh-defer unfunction source
        # zprof
      '')
    ];
  };
}
