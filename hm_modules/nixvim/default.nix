# nvim.nix
{ config, ... }:

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
        grammerPackages = with config.plugins.treesitter.package.builtGrammars; [
          nix
          org
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
              { section = "keys"; gap = 1; padding = 1; }
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

    extraConfigLua = ''
      function GetCharCount()
          local text = vim.api.nvim_buf_get_lines(0, 0, -1, false)
          local full_text = table.concat(text, "\n")
          -- Unicodeの文字数としてカウントする
          local count = vim.fn.strdisplaywidth(full_text) -- これだと2になるため代替案

          -- UTF-8文字列の文字数を正確に数えるためのLua標準手法
          local _, count = string.gsub(full_text, "[^\128-\193]", "")
          print("文字数: " .. count)
      end

      -- コマンド登録
      vim.api.nvim_create_user_command('CountChars', GetCharCount, {})
    '';

    keymaps = [
      {
        mode = "i";
        key = "jk";
        action = "<ESC>";
      }
    ];
  };
}
