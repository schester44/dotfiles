-- [[ My Basic Keymaps ]] --
vim.keymap.set('i', 'jj', '<Esc>')

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<leader>ld', vim.diagnostic.open_float, { desc = 'Open floating [L]sp [D]iagnostic message' })
vim.keymap.set('n', '<leader>ll', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

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

-- Git
vim.keymap.set('n', '<leader>go', '<cmd>:GBrowse<CR>', { desc = 'Git browse' })
-- TODO: line selection doesn't work.
vim.keymap.set('v', '<leader>go', '<cmd>:GBrowse<CR>', { desc = 'Git browse' })
vim.keymap.set('n', '<leader>gs', '<cmd>:GStatus<CR>', { desc = 'Git status' })
vim.keymap.set('n', '<leader>gcm', '<cmd>:Git checkout main<CR>', { desc = 'Git checkout main' })
vim.keymap.set('n', '<leader>gco', ':Git checkout ', { desc = 'Git checkout' })
vim.keymap.set('n', '<leader>gcb', ':Git checkout -b ', { desc = 'Git checkout -b' })
vim.keymap.set('n', '<leader>gcl', '<cmd>:Git checkout @{-1}<CR>', { desc = 'Git checkout last' })
vim.keymap.set('n', '<leader>gmm', '<cmd>:Git merge main<CR>', { desc = 'Git merge main' })
vim.keymap.set('n', '<leader>gpm', '<cmd>:Git pull origin main<CR>', { desc = 'Git pull origin main' })
vim.keymap.set('n', '<leader>gP', '<cmd>:Git push origin HEAD<CR>', { desc = 'Git push origin HEAD' })
vim.keymap.set('n', '<leader>gl', '<cmd>:Git pull<CR>', { desc = 'Git pull' })

-- Buffers
-- Go to last buffer
vim.keymap.set('n', '<leader><Tab>', '<cmd>:b#<CR>', { desc = 'Go to last buffer' })
vim.keymap.set('n', '<leader>bp', '<cmd>:bnext<CR>', { desc = 'Go to next buffer' })
vim.keymap.set('n', '<leader>bn', '<cmd>:bprevious<CR>', { desc = 'Go to previous buffer' })
-- Close buffer
vim.keymap.set('n', '<leader>bd', '<cmd>:bd<CR>', { desc = 'Close buffer' })
-- Close All Buffers
vim.keymap.set('n', '<leader>bD', '<cmd>:bufdo bd<CR>', { desc = 'Close all buffers' })

-- Move lines with Option + j/k
vim.keymap.set('n', '<M-j>', ':m .+1<CR>==', { desc = 'Move line down' })
vim.keymap.set('n', '<M-k>', ':m .-2<CR>==', { desc = 'Move line up' })
vim.keymap.set('v', '<M-j>', ":m '>+1<CR>gv=gv", { desc = 'Move selected lines down' })
vim.keymap.set('v', '<M-k>', ":m '<-2<CR>gv=gv", { desc = 'Move selected lines up' })

-- Split windows easily
vim.keymap.set('n', '<leader>w-', '<cmd>:split<CR>', { desc = 'Split window horizontally' })
vim.keymap.set('n', '<leader>w|', '<cmd>:vsplit<CR>', { desc = 'Split window vertically' })

-- File Copy Path
vim.keymap.set('n', '<leader>fcp', '<cmd>let @+=expand("%:p")<CR>', { desc = 'Copy file path to clipboard' })
-- File Open in Finder
vim.keymap.set('n', '<leader>fof', '<cmd>silent !open %:p:h<CR>', { desc = 'Open file in Finder' })

-- TODO: These don't work, possible an issue with Wezterm or something else?
-- Global copy/paste to system clipboard
vim.keymap.set('v', '<D-c>', '"+y', { desc = 'Copy to system clipboard' }) -- Cmd+C
vim.keymap.set('n', '<D-v>', '"+P', { desc = 'Paste from system clipboard in normal mode' }) -- Cmd+V in normal mode
vim.keymap.set('v', '<D-v>', '"+P', { desc = 'Paste from system clipboard in visual mode' }) -- Cmd+V in visual mode
vim.keymap.set('i', '<D-v>', '<C-r>+', { desc = 'Paste from system clipboard in insert mode' }) -- Cmd+V in insert mode
vim.keymap.set('v', '<D-x>', '"+d', { desc = 'Cut to system clipboard' }) -- Cmd+x

-- Toggle Git Blame
vim.keymap.set('n', '<leader>tg', '<cmd>:GitBlameToggle<CR>', { desc = '[T]oggle [G]it Blame' })
vim.keymap.set('n', '<leader>tc', '<cmd>:TSContextToggle<CR>', { desc = '[T]oggle [C]ontext' })

-- Dismiss Noice Notifications
vim.keymap.set('n', '<leader>nd', '<cmd>:Noice dismiss<CR>', { desc = '[N]oice [D]ismiss' })
vim.keymap.set('n', '<leader>nl', '<cmd>:Noice last<CR>', { desc = '[N]oice [L]ast Message' })

-- Make "U" the opposite of "u"
vim.keymap.set('n', 'U', '<C-r>', { desc = 'Redo' })
