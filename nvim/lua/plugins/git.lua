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
        '<leader>gbb',
        function()
          require('neogit').action('branch', 'checkout_recent_branch', {})()
        end,
        desc = 'Checkout Branch',
      },
      {
        '<leader>gcb',
        function()
          require('neogit').action('branch', 'checkout_create_branch', {})()
        end,
        desc = 'Create Branch from Current',
      },
      {
        '<leader>gP',
        function()
          require('neogit').action('push', 'to_upstream', {})()
        end,
        desc = 'Push Upstream',
      },

      {
        '<leader>gp',
        function()
          require('neogit').action('pull', 'from_upstream', {})()
        end,
        desc = 'Pull Upstream',
      },
    },
  },

  {
    'tpope/vim-fugitive',
    cond = not vim.g.vscode,
    config = function()
      set('n', '<leader>go', '<cmd>GBrowse<CR>', { desc = 'GBrowse' })
      set('x', '<leader>go', ':GBrowse<CR>', { desc = 'GBrowse (selection)' })

      set('n', '<leader>gh', '<cmd>:DiffviewFileHistory %<CR>', { desc = 'File history' })
      set('n', '<leader>gB', '<cmd>:Git blame<CR>', { desc = 'Git blame' })
    end,
  },
  { 'tpope/vim-rhubarb', cond = not vim.g.vscode },
  {
    'sindrets/diffview.nvim',
    cond = not vim.g.vscode,
    config = function()
      set('n', '<leader>gd', function()
        local ref = vim.fn.input('DiffviewOpen ref/range: ', 'main')
        if ref ~= '' then
          vim.cmd('DiffviewOpen ' .. ref)
        end
      end, { desc = 'Diffview' })

      -- set('n', '<leader>gd', '<cmd>:DiffviewOpen', { desc = 'Git diff' })

      set('n', '<leader>gb', function()
        Snacks.picker.git_log_line()
      end, { desc = 'Git blame line' })
    end,
  },
  {
    'lewis6991/gitsigns.nvim',
    opts = {},
    cond = not vim.g.vscode,
    config = function()
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
