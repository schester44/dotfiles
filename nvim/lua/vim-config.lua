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
