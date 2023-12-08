require "options"
require "lazy-config"
require "keymaps"
require "telescope-config"
require "lsp-config"
require "cmp-config"
require "whichkey-config"

require("nvim-tree").setup()

require("marks").setup({
  builtin_marks = { ".", "<", ">", "^", "a", "b", "c" },
})

-- Format on save
vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format()]]
vim.cmd [[autocmd BufWritePre *.tsx,*.ts,*.js,*.html,*.css  Prettier]]

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})


-- Theme
require('colorbuddy').colorscheme('cobalt2')

-- Setup neovim lua configuration
require('neodev').setup()

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
