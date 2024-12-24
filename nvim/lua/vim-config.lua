-- Run diagnostics in insert mode
-- vim.diagnostic.config {
--   update_in_insert = true,
-- }

-- Fix all eslint issue on save
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = { '*.tsx', '*.ts', '*.jsx', '*.js' },
  command = 'silent! EslintFixAll',
  group = vim.api.nvim_create_augroup('MyAutocmdsJavaScripFormatting', {}),
})

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Autocmd to toggle line numbers when entering or leaving the command-line mode
-- So that I can see absolute numbers when using cmd to run commands
vim.api.nvim_create_autocmd('CmdlineEnter', {
  pattern = ':',
  callback = function()
    vim.o.relativenumber = false -- Disable relative numbers
  end,
})

vim.api.nvim_create_autocmd('CmdlineLeave', {
  pattern = ':',
  callback = function()
    vim.o.relativenumber = true -- Enable relative numbers
  end,
})

-- Diagnostic Signs
local symbols = { Error = '󰅙', Info = '󰋼', Hint = '󰌵', Warn = '' }

for name, icon in pairs(symbols) do
  local hl = 'DiagnosticSign' .. name
  vim.fn.sign_define(hl, { text = icon, numhl = hl, texthl = hl })
end
