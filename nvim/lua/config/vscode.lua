vim.g.mapleader = ' '
vim.g.maplocalleader = ' '


vim.bo.expandtab = true -- Use spaces
vim.bo.shiftwidth = 2   -- Indent by 2 spaces
vim.bo.softtabstop = 2  -- Tab inserts 2 spaces
vim.bo.tabstop = 2      -- Tab width is 2 spaces


-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true


local set = vim.keymap.set
local vscode = require('vscode')


set("n", '-', function()
  vscode.action('workbench.view.explorer')
end)

set('n', 'U', '<C-r>', { desc = 'Redo' })

vim.keymap.set('n', 'gk', vim.lsp.buf.hover, { desc = 'Show Hover' })

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
vim.opt.rtp:prepend(lazypath)

require('lazy').setup("plugins")
