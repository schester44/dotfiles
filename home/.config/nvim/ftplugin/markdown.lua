-- Prose-friendly settings for markdown buffers
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.spell = false

-- Navigate by display lines when wrapped
vim.keymap.set({ 'n', 'v' }, 'j', 'gj', { buffer = true })
vim.keymap.set({ 'n', 'v' }, 'k', 'gk', { buffer = true })
