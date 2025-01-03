-- Run diagnostics in insert mode
-- vim.diagnostic.config {
--   update_in_insert = true,
-- }

-- Diagnostic Signs
local symbols = { Error = '󰅙', Info = '󰋼', Hint = '󰌵', Warn = '' }

for name, icon in pairs(symbols) do
  local hl = 'DiagnosticSign' .. name
  vim.fn.sign_define(hl, { text = icon, numhl = hl, texthl = hl })
end

vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = 'rounded',
  winhighlight = 'NormalFloat:LspHover,FloatBorder:LspHoverBorder',
})
