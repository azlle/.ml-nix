# modules/nixvim.nix
{ delib, inputs, ... }:
delib.module {
  name = "nixvim";

  home.always = {
    imports = [
      inputs.nixvim.homeModules.nixvim
      (
        { config, pkgs, ... }:
        {
          programs.nixvim = {
            enable = true;
            defaultEditor = true;
            viAlias = true;
            vimAlias = true;
            waylandSupport = true;

            plugins = {
              neogit.enable = true;
              gitsigns.enable = true;
              # indent-blankline.enable = true;
              mini-trailspace = {
                enable = true;
                settings = {
                  only_in_normal_buffers = false;
                };
                luaConfig.post = ''
                  vim.api.nvim_create_autocmd("BufWritePre", {
                    callback = function()
                      require('mini.trailspace').trim()
                    end,
                  })
                '';
              };
              orgmode.enable = true;
              lualine = {
                enable = true;
                settings = {
                  options = { };
                };
              };
              treesitter = {
                enable = true;
                settings = {
                  highlight.enable = true;
                  indent.enable = true;
                };
                grammarPackages =
                  (with config.programs.nixvim.plugins.treesitter.package.builtGrammars; [
                    nix
                  ])
                  ++ [
                    pkgs.tree-sitter-grammars.tree-sitter-org
                  ];
              };
              snacks = {
                enable = true;
                settings = {
                  picker.enabled = true;
                  indent.enabled = true;
                  dashboard = {
                    enabled = true;
                    sections = [
                      { section = "header"; }
                      {
                        section = "keys";
                        gap = 1;
                        padding = 1;
                      }
                      # { section = "startup"; }
                    ];
                  };
                };
              };
            };

            colorschemes.rose-pine.enable = true;

            opts = {
              backup = false;
              swapfile = false;
              autoread = true;
              hidden = true;
              autochdir = true;

              number = true;
              relativenumber = true;
              cursorline = true;
              cursorcolumn = false;
              virtualedit = "onemore";
              smartindent = true;
              visualbell = true;
              showmatch = true;
              laststatus = 2;
              wildmode = "longest:full,full";
              wildoptions = "pum";
              wildmenu = true;
              wildignorecase = true;
              showcmd = true;

              list = true;
              listchars = "tab:aa";
              expandtab = true;
              tabstop = 2;
              shiftwidth = 2;

              ignorecase = true;
              smartcase = true;
              incsearch = true;
              wrapscan = true;
              hlsearch = true;
            };

            files = {
              "lua/urls-cleanup.lua" = {
                extraConfigLua = builtins.readFile ../hm_modules/nixvim/lua/urls-cleanup.lua;
              };
              "lua/countchars.lua" = {
                extraConfigLua = builtins.readFile ../hm_modules/nixvim/lua/countchars.lua;
              };
            };

            extraConfigLua = ''
              require("urls-cleanup")
              require("countchars")
            '';

            globals = {
              mapleader = " ";
              maplocalleader = " ";
            };

            keymaps = [
              {
                mode = "i";
                key = "jk";
                action = "<ESC>";
              }
              {
                mode = [
                  "n"
                  "v"
                ];
                key = "gh";
                action = "^";
              }
              {
                mode = [
                  "n"
                  "v"
                ];
                key = "gl";
                action = "$";
              }
              {
                mode = "n";
                key = "<leader>b";
                action = "<cmd>lua Snacks.picker.buffers()<CR>";
              }
            ];
          };
        }
      )
    ];
  };
}
