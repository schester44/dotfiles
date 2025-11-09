local set = vim.keymap.set

return {
  {
    'NeogitOrg/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim', -- required
      'sindrets/diffview.nvim', -- optional - Diff integration
      'folke/snacks.nvim', -- optional
    },
    keys = {
      { '<leader>gg', '<cmd>Neogit<cr>', desc = 'Neogit' },
      {
        '<leader>gb',
        ':Neogit branch<CR>',
        desc = 'Neogit Branches',
      },
      {
        '<leader>gP',
        ':Neogit push<CR>',
        desc = 'Neogit Push',
      },
      {
        '<leader>gp',
        ':Neogit pull<CR>',
        desc = 'Neogit Pull',
      },
    },
  },

  {
    'sindrets/diffview.nvim',
    cond = not vim.g.vscode,
    config = function()
      set('n', '<leader>gh', '<cmd>:DiffviewFileHistory %<CR>', { desc = 'File history' })

      set('n', '<leader>gd', function()
        local ref = vim.fn.input('DiffviewOpen ref/range: ', 'main')
        if ref ~= '' then
          vim.cmd('DiffviewOpen ' .. ref)
        end
      end, { desc = 'Diffview' })
    end,
  },
  {
    'lewis6991/gitsigns.nvim',
    opts = {},
    cond = not vim.g.vscode,
    config = function()
      set('n', '<leader>gB', '<cmd>:Gitsigns blame<CR>', { desc = 'Git blame' })

      set('n', ']c', function()
        local gitsigns = require 'gitsigns'

        if vim.wo.diff then
          vim.cmd.normal { ']c', bang = true }
        else
          gitsigns.nav_hunk 'next'
        end
      end, { desc = 'Next hunk' })

      set('n', '[c', function()
        local gitsigns = require 'gitsigns'

        if vim.wo.diff then
          vim.cmd.normal { '[c', bang = true }
        else
          gitsigns.nav_hunk 'prev'
        end
      end, { desc = 'Prev hunk' })

      set('n', '<leader>gv', function()
        require('gitsigns').preview_hunk()
      end, { desc = 'Git preview hunk' })
    end,
  },
}
