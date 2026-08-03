# yazi.nix
{ inputs, ... }:

{
  programs.yazi = {
    enable = true;
    shellWrapperName = "y";
    enableZshIntegration = true;

    settings = {
      mgr = {
        show_hidden = true;
        mouse_events = [ ];
      };

      opener = {
        emacs = [
          {
            run = "emacs \"$@\"";
            block = true;
          }
        ];
        mpv = [
          {
            run = "mpv \"$@\"";
            block = true;
          }
        ];
        imv = [
          {
            run = "imv \"$@\"";
            block = true;
          }
        ];
      };

      open.rules = [
        {
          mime = "text/*";
          use = "emacs";
        }
        {
          mime = "video/*";
          use = "mpv";
        }
        {
          mime = "image/*";
          use = "imv";
        }
      ];
    };

    plugins.bunny = "${inputs.bunny-yazi}";
    initLua = ''
      require("bunny"):setup({
        hops = {
          { key = "n", path = "/nix/store", desc = "Nix store" },
          { key = ".", path = "~/.ml-nix", desc = "dotfiles" },
          { key = "u", path = "/mnt/f/Users/Eeshta", desc = "%USERDATA%" },
          { key = "a", path = "/mnt/c/Users/Eeshta/AppData", desc = "%APPDATA%" },
          -- key and path attributes are required, desc is optional
        },
        desc_strategy = "path", -- If desc isn't present, use "path" or "filename", default is "path"
        ephemeral = true, -- Enable ephemeral hops, default is true
        tabs = true, -- Enable tab hops, default is true
        notify = false, -- Notify after hopping, default is false
        fuzzy_cmd = "fzf", -- Fuzzy searching command, default is "fzf"
      })
    '';
    keymap.mgr.prepend_keymap = [
      {
        on = "b";
        run = "plugin bunny";
        desc = "Start bunny.yazi";
      }
    ];
  };

  catppuccin.yazi = {
    enable = true;
    flavor = "mocha";
    accent = "yellow";
  };

  programs = {
    imv.enable = true;
    fd.enable = true;
    fzf.enable = true;
    zathura.enable = true;
    zoxide.enable = true;
  };
}
