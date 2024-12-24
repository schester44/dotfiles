return {
  {
    'schester44/flowterm.nvim',
    dev = true,
    config = function()
      print 'config flowterm'

      -- Exit terminal with <esc><esc>
      vim.keymap.set('t', '<esc><esc>', '<C-\\><C-n>')

      local flowterm = require 'flowterm'

      vim.keymap.set({ 'n', 't' }, '<leader>ot', flowterm.toggle_terminal, { desc = '[O]pen [T]erminal' })
    end,
  },
}
