-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = false
vim.opt.listchars = { tab = '· ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
-- this is needed for the status column color
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

vim.bo.expandtab = true -- Use spaces
vim.bo.shiftwidth = 2 -- Indent by 2 spaces
vim.bo.softtabstop = 2 -- Tab inserts 2 spaces
vim.bo.tabstop = 2 -- Tab width is 2 spaces

vim.opt.conceallevel = 2 -- Conceal text

vim.opt.numberwidth = 4

vim.o.statuscolumn = "%!v:lua.require('lib/statuscolumn').render()"

local diag_icons = {
  error = '󰅙',
  warn = '',
  info = '󰋼',
  hint = '󰌵',
}

vim.diagnostic.config {
  update_in_insert = false,
  virtual_lines = {
    enabled = true,
    current_line = true,
    severity = {
      min = vim.diagnostic.severity.ERROR,
    },
  },
  virtual_text = {
    enabled = true,
    current_line = true,
    severity = {
      min = vim.diagnostic.severity.HINT,
      max = vim.diagnostic.severity.WARN,
    },
  },
  signs = {
    linehl = {
      [vim.diagnostic.severity.ERROR] = 'DiagnosticLineError',
      [vim.diagnostic.severity.WARN] = 'DiagnosticLineWarn',
      [vim.diagnostic.severity.INFO] = 'DiagnosticLineInfo',
      [vim.diagnostic.severity.HINT] = 'DiagnosticLineHint',
    },
    text = {
      [vim.diagnostic.severity.ERROR] = diag_icons.error,
      [vim.diagnostic.severity.WARN] = diag_icons.warn,
      [vim.diagnostic.severity.INFO] = diag_icons.info,
      [vim.diagnostic.severity.HINT] = diag_icons.hint,
    },
  },
}
