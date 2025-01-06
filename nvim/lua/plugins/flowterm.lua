return {
  {
    'schester44/flowterm.nvim',
    dev = true,
    config = function()
      local flowterm = require 'flowterm'

      vim.keymap.set({ 'n', 't' }, '<leader>ot', flowterm.toggle_terminal, { desc = '[O]pen [T]erminal' })
    end,
  },
}
