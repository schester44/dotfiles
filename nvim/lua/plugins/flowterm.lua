return {
  {
    'schester44/flowterm.nvim',
    dev = true,
    config = function()
      local flowterm = require 'flowterm'

      vim.keymap.set({ 'n', 't' }, '<leader>ts', function()
        flowterm.toggle_floating_win()
      end, { desc = '[T]oggle [S]cratchpad' })

      vim.keymap.set({ 'n', 't' }, '<leader>tt', function()
        flowterm.toggle_floating_win 'terminal'
      end, { desc = '[T]oggle [T]erminal' })
    end,
  },
}
