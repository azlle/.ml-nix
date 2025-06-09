# nvim.nix
{ pkgs, config, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      nixfmt-rfc-style
    ];
    plugins = with pkgs.vimPlugins; [
      lazy-nvim
      lualine-nvim
    ];
  };

  xdg.configFile."../.config/nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/hm_modules/.config/nvim";
    recursive = true;
  };
}
