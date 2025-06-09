require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'horizon',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    always_show_tabline = true,
    globalstatus = false,
    refresh = {
      statusline = 100,
      tabline = 100,
      winbar = 100,
      refresh_time = 6, -- ~60fps
      events = {
        'WinEnter',
        'BufEnter',
        'BufWritePost',
        'SessionLoadPost',
        'FileChangedShellPost',
        'VimResized',
        'Filetype',
        'CursorMoved',
        'CursorMovedI',
        'ModeChanged',
      },
    }
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {
    lualine_a = {'buffers'},
    lualine_b = {'branch'},
    lualine_c = {'filename'},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {'tabs'}
  },
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}

local encoding_config = {
  encoding = 'utf-8',
  fileencoding = 'utf-8',
  fileencodings = { 'utf-8', 'iso-2022-jp', 'euc-jp', 'sjis' },
  fileformats = { 'unix', 'dos', 'mac' },
}

local config = {
  options = {
    backup = false,
    swapfile = false,
    autoread = true,
    hidden = true,

    number = true,
    relativenumber = true,
    cursorline = true,
    cursorcolumn = true,
    virtualedit = 'onemore',
    smartindent = true,
    visualbell = true,
    showmatch = true,
    laststatus = 2,
    wildmode = 'list:longest',
    wildmenu = true,
    showcmd = true,

    list = true,
    listchars = 'tab:aa',
    expandtab = true,
    tabstop = 2,
    shiftwidth = 2,

    ignorecase = true,
    smartcase = true,
    incsearch = true,
    wrapscan = true,
    hlsearch = true,

    -- t_u7 = '',
  }
}

local highlights = {
  Normal     = { bg = 'none' },
  NormalNC   = { bg = 'none' },
  SignColumn = { bg = 'none' },
  VertSplit  = { bg = 'none' },
  StatusLine = { bg = 'none' },
}

local keymaps = {
  { "n", "j", "gj", { desc = "Down in wrappaed lines" } },
  { "n", "k", "gk", { desc = "Up in wrapped lines" } },

  { "i", "jj", "<ESC>", { silent = true, desc = "Exit insert mode" } },
  { "n", "<C-j>", ":bnext<CR>", { silent = true, desc = "Next buffer" } },
  { "n", "<C-k>", ":bnext<CR>", { silent = true, desc = "Previous buffer" } },
  { "n", "<Esc><Esc>", ":noh<CR>", { desc = "Clear search highlight" } },
}

for key, value in pairs(config.options) do
  vim.opt[key] = value
end

for group, opts in pairs(highlights) do
  vim.api.nvim_set_hl(0, group, opts)
end

for _, keymap in ipairs(keymaps) do
  vim.keymap.set(keymap[1], keymap[2], keymap[3], keymap[4] or {})
end

