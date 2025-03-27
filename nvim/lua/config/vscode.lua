vim.g.mapleader = ' '
vim.g.maplocalleader = ' '


vim.bo.expandtab = true -- Use spaces
vim.bo.shiftwidth = 2   -- Indent by 2 spaces
vim.bo.softtabstop = 2  -- Tab inserts 2 spaces
vim.bo.tabstop = 2      -- Tab width is 2 spaces

local set = vim.keymap.set
local vscode = require('vscode')

set('n', '<leader>w', '<cmd>:w<CR>', { desc = 'Write' })
set('n', '<leader>q', function()
  vscode.action('workbench.action.closeActiveEditor')
end, { desc = 'Quit' })


-- Buffer navigation
set("n", '-', function()
  -- open the file explorer
  vscode.action('workbench.view.explorer')
end)

set('n', 'U', '<C-r>', { desc = 'Redo' })

-- These two are not working
-- Diagnostic navigation (built-in LSP)
-- set("n", "[d", vim.diagnostic.goto_prev)
-- set("n", "]d", vim.diagnostic.goto_next)
-- set("n", "[b", "<cmd>bprevious<CR>")
-- set("n", "]b", "<cmd>bnext<CR>")

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
vim.opt.rtp:prepend(lazypath)

require('lazy').setup("plugins")
