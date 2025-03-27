local set = vim.keymap.set
local k = require 'lib.keymaps'

-- Exit with jj
set('i', 'jj', '<Esc>')

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
-- For other diagnostic commands, see trouble.lua
set('n', '<leader>xm', function()
  vim.diagnostic.open_float { border = 'rounded' }
end, { desc = 'Open floating [L]sp [D]iagnostic message' })

set('n', '<leader>lr', '<cmd>LspRestart<CR>', { desc = '[L]sp [R]estart' })

k.set_toggle_keymap {
  keys = 'q',
  desc = 'Quickfix',
  cmd = function()
    require('quicker').toggle()
  end,
}

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
--  These conflict with move.mini
set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Copy to clipboard
set({ 'v', 'n' }, '<leader>y', '"+y', { desc = 'Copy selected text to system clipboard' })
set('n', '<leader>Y', '"+yg_', { desc = 'Copy to the end of line to system clipboard' })
-- Paste from clipboard
set({ 'n', 'v' }, '<leader>p', '"+p', { desc = 'Paste from system clipboard' })

-- Git
set({ 'n', 'v' }, '<leader>go', '<cmd>:GBrowse<CR>', { desc = 'Git browse' })
set('n', '<leader>gs', '<cmd>:G<CR>', { desc = 'Git status' })
set('n', '<leader>gcm', '<cmd>:Git checkout main<CR>', { desc = 'Git checkout main' })
set('n', '<leader>gcc', ':Git checkout ', { desc = 'Git checkout' })
set('n', '<leader>gcn', ':Git checkout -b ', { desc = 'Git checkout -b' })
set('n', '<leader>gcl', '<cmd>:Git checkout @{-1}<CR>', { desc = 'Git checkout last' })
set('n', '<leader>gp', '<cmd>:Git pull<CR>', { desc = 'Git pull' })
set('n', '<leader>gM', '<cmd>:Git pull origin main<CR>', { desc = 'Git pull origin main' })
set('n', '<leader>gP', '<cmd>:Git push origin HEAD<CR>', { desc = 'Git push origin HEAD' })
set('n', '<leader>gl', '<cmd>:0Gclog<CR>', { desc = 'Git log' })
set('n', '<leader>gd', '<cmd>:Gdiff<CR>', { desc = 'Git diff' })
set('n', '<leader>gB', '<cmd>:Git blame<CR>', { desc = 'Git blame' })
set('n', '<leader>gb', function()
  Snacks.picker.git_log_line()
end, { desc = 'Git blame line' })

-- Buffers
set('n', '<leader><Tab>', '<cmd>:b#<CR>', { desc = 'Go to last buffer' })

set('n', '<leader>bd', function()
  Snacks.bufdelete()
end, { desc = 'Delete Buffer' })

set('n', '<leader>bo', function()
  Snacks.bufdelete.other()
end, { desc = 'Delete Other Buffers' })

set('n', '<leader>bD', '<cmd>:bd<cr>', { desc = 'Delete Buffer and Window' })

set('n', '<leader>w', '<cmd>:w<CR>', { desc = 'Write' })
set('n', '<leader>q', '<cmd>:q<CR>', { desc = 'Quit' })
set('n', '<leader>qq', '<cmd>qa<CR>', { desc = 'Quit All' })

-- File Copy Path
set('n', '<leader>fcp', '<cmd>let @+=expand("%:p")<CR>', { desc = 'Copy file path to clipboard' })
-- File Open in Finder
set('n', '<leader>fof', '<cmd>silent !open %:p:h<CR>', { desc = 'Open file in Finder' })


k.set_toggle_keymap {
  keys = 'c',
  desc = 'Copilot',
  cmd = function()
    local copilot = require 'copilot.command'

    if not vim.g.copilot_disabled then
      copilot.disable()
      vim.g.copilot_disabled = true
    else
      copilot.enable()
      vim.g.copilot_disabled = false
    end

    vim.defer_fn(function()
      vim.cmd 'Copilot status'
    end, 1000)
  end,
}

-- Make "U" the opposite of "u"
set('n', 'U', '<C-r>', { desc = 'Redo' })

-- Exit terminal with <esc><esc>
set('t', '<esc><esc>', '<C-\\><C-n>')
