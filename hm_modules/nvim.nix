_:

{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    waylandSupport = true;
    plugins = {
      neogit.enable = true;
      orgmode.enable = true;
    };
    colorschemes.monokai-pro.enable = true;
  };
}
