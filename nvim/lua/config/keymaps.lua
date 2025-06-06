local set = vim.keymap.set
local k = require 'lib.keymaps'

set('i', 'jj', '<Esc>')

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
-- For other diagnostic commands, see trouble.lua
set('n', '<leader>xm', function()
  vim.diagnostic.open_float { border = 'rounded' }
end, { desc = 'Open floating [L]sp [D]iagnostic message' })

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

set('n', 'U', '<C-r>', { desc = 'Redo' })

set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

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

set('n', ']b', '<cmd>BuffyCycleNext<CR>', { desc = 'Next Buffer' })
set('n', '[b', '<cmd>BuffyCyclePrev<CR>', { desc = 'Prev Buffer' })

set('n', '<leader>fcp', '<cmd>let @+=expand("%:p")<CR>', { desc = 'Copy file path to clipboard' })
set('n', '<leader>fof', '<cmd>silent !open %:p:h<CR>', { desc = 'Open file in Finder' })

-- append a comma to end of line
set('n', ',,', 'A,<esc>', { desc = 'Append ,' })

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
