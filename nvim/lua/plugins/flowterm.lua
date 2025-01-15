return {
  {
    'schester44/flowterm.nvim',
    dev = true,
    config = function()
      local flowterm = require 'flowterm'

      vim.keymap.set({ 'n', 't' }, '<leader>tt', flowterm.toggle_terminal, { desc = '[T]oggle [T]erminal' })
    end,
  },
}
