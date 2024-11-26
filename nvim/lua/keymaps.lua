-- [[ My Basic; Keymaps ]] --
vim.keymap.set('i', 'jj', '<Esc>')

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set('n', '<A-j>', ':m .+1<CR>==', { desc = 'Move the current line down' })

-- Copy to clipboard
vim.keymap.set('v', '<leader>y', '"+y', { desc = 'Copy selected text to system clipboard' })
vim.keymap.set('n', '<leader>Y', '"+yg_', { desc = 'Copy to the end of line to system clipboard' })
vim.keymap.set('n', '<leader>y', '"+y', { desc = 'Copy the current line to system clipboard' })
vim.keymap.set('n', '<leader>yy', '"+yy', { desc = 'Copy the current line to system clipboard' })

-- Paste from clipboard
vim.keymap.set('n', '<leader>p', '"+p', { desc = 'Paste from system clipboard' })
vim.keymap.set('n', '<leader>P', '"+P', { desc = 'Paste from system clipboard' })
vim.keymap.set('v', '<leader>p', '"+p', { desc = 'Paste from system clipboard' })
vim.keymap.set('v', '<leader>P', '"+P', { desc = 'Paste from system clipboard' })

vim.keymap.set('n', '<leader>rt', '<cmd>Lazy reload cobalt44.nvim<CR>', { desc = 'Reload cobalt44.nvim' })

vim.keymap.set('n', '<leader>fcp', function()
  vim.fn.setreg('+', vim.fn.expand '%:p')
end, { desc = 'Copy current file path to clipboard' })
