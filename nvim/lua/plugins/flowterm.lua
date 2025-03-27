return {
  {
    'schester44/flowterm.nvim',
    dev = true,
    cond = not vim.g.vscode,
    config = function()
      local flowterm = require 'flowterm'
      local k = require 'lib.keymaps'

      k.set_toggle_keymap {
        keys = 't',
        cmd = function()
          flowterm.toggle_floating_win 'terminal'
        end,
        desc = 'Terminal',
      }

      k.set_toggle_keymap {
        keys = 's',
        cmd = function()
          flowterm.toggle_floating_win()
        end,
        desc = 'Scratchpad',
      }
    end,
  },
}
