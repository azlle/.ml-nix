# nvim.nix
{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      nixfmt-rfc-style
    ];
    plugins = with pkgs.vimPlugins; [ lazy-nvim ];
  };
}
