local set = vim.keymap.set

-- Exit with jj
set('i', 'jj', '<Esc>')

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
-- For other diagnostic commands, see trouble.lua
set('n', '<leader>xm', vim.diagnostic.open_float, { desc = 'Open floating [L]sp [D]iagnostic message' })

-- Go to next and previous diagnostic
set('n', '<leader>dn', vim.diagnostic.goto_next, { desc = 'Go to [N]ext diagnostic' })
set('n', '<leader>dp', vim.diagnostic.goto_prev, { desc = 'Go to [P]revious diagnostic' })

set('n', '<leader>lr', '<cmd>LspRestart<CR>', { desc = '[L]sp [R]estart' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

set('n', '<A-j>', ':m .+1<CR>==', { desc = 'Move the current line down' })

-- Copy to clipboard
set('v', '<leader>y', '"+y', { desc = 'Copy selected text to system clipboard' })
set('n', '<leader>Y', '"+yg_', { desc = 'Copy to the end of line to system clipboard' })
set('n', '<leader>y', '"+y', { desc = 'Copy the current line to system clipboard' })
set('n', '<leader>yy', '"+yy', { desc = 'Copy the current line to system clipboard' })

-- Paste from clipboard
set('n', '<leader>p', '"+p', { desc = 'Paste from system clipboard' })
set('n', '<leader>P', '"+P', { desc = 'Paste from system clipboard' })
set('v', '<leader>p', '"+p', { desc = 'Paste from system clipboard' })
set('v', '<leader>P', '"+P', { desc = 'Paste from system clipboard' })

-- Git
set('n', '<leader>go', '<cmd>:GBrowse<CR>', { desc = 'Git browse' })
-- TODO: line selection doesn't work.
set('v', '<leader>go', '<cmd>:GBrowse<CR>', { desc = 'Git browse' })
set('n', '<leader>gs', '<cmd>:GStatus<CR>', { desc = 'Git status' })
set('n', '<leader>gcm', '<cmd>:Git checkout main<CR>', { desc = 'Git checkout main' })
set('n', '<leader>gco', ':Git checkout ', { desc = 'Git checkout' })
set('n', '<leader>gcb', ':Git checkout -b ', { desc = 'Git checkout -b' })
set('n', '<leader>gcl', '<cmd>:Git checkout @{-1}<CR>', { desc = 'Git checkout last' })
set('n', '<leader>gmm', '<cmd>:Git merge main<CR>', { desc = 'Git merge main' })
set('n', '<leader>gpm', '<cmd>:Git pull origin main<CR>', { desc = 'Git pull origin main' })
set('n', '<leader>gP', '<cmd>:Git push origin HEAD<CR>', { desc = 'Git push origin HEAD' })
set('n', '<leader>gl', '<cmd>:Git pull<CR>', { desc = 'Git pull' })

-- Buffers
-- Go to last buffer
set('n', '<leader><Tab>', '<cmd>:b#<CR>', { desc = 'Go to last buffer' })
set('n', '<leader>bp', '<cmd>:bnext<CR>', { desc = 'Go to next buffer' })
set('n', '<leader>bn', '<cmd>:bprevious<CR>', { desc = 'Go to previous buffer' })
-- Close buffer
set('n', '<leader>bd', '<cmd>:bd<CR>', { desc = 'Close buffer' })
-- Close All Buffers
set('n', '<leader>bD', '<cmd>:bufdo bd<CR>', { desc = 'Close all buffers' })

-- Move lines with Option + j/k
set('n', '<M-j>', ':m .+1<CR>==', { desc = 'Move line down' })
set('n', '<M-k>', ':m .-2<CR>==', { desc = 'Move line up' })
set('v', '<M-j>', ":m '>+1<CR>gv=gv", { desc = 'Move selected lines down' })
set('v', '<M-k>', ":m '<-2<CR>gv=gv", { desc = 'Move selected lines up' })

-- Save with <leader>w
set('n', '<leader>w', '<cmd>:w<CR>', { desc = '[W]rite' })

-- File Copy Path
set('n', '<leader>fcp', '<cmd>let @+=expand("%:p")<CR>', { desc = 'Copy file path to clipboard' })
-- File Open in Finder
set('n', '<leader>fof', '<cmd>silent !open %:p:h<CR>', { desc = 'Open file in Finder' })

-- TODO: These don't work, possible an issue with Wezterm or something else?
-- Global copy/paste to system clipboard
set('v', '<D-c>', '"+y', { desc = 'Copy to system clipboard' }) -- Cmd+C
set('n', '<D-v>', '"+P', { desc = 'Paste from system clipboard in normal mode' }) -- Cmd+V in normal mode
set('v', '<D-v>', '"+P', { desc = 'Paste from system clipboard in visual mode' }) -- Cmd+V in visual mode
set('i', '<D-v>', '<C-r>+', { desc = 'Paste from system clipboard in insert mode' }) -- Cmd+V in insert mode
set('v', '<D-x>', '"+d', { desc = 'Cut to system clipboard' }) -- Cmd+x

-- Toggle Git Blame
set('n', '<leader>tg', '<cmd>:GitBlameToggle<CR>', { desc = '[T]oggle [G]it Blame' })
set('n', '<leader>tc', '<cmd>:TSContextToggle<CR>', { desc = '[T]oggle [C]ontext' })

-- Dismiss Noice Notifications
set('n', '<leader>nd', '<cmd>:Noice dismiss<CR>', { desc = '[N]oice [D]ismiss' })
set('n', '<leader>nl', '<cmd>:Noice last<CR>', { desc = '[N]oice [L]ast Message' })

-- Make "U" the opposite of "u"
set('n', 'U', '<C-r>', { desc = 'Redo' })
