local set = vim.keymap.set

return {
  {
    'tpope/vim-fugitive',
    cond = not vim.g.vscode,
    config = function()
      set({ 'n', 'v' }, '<leader>go', '<cmd>:GBrowse<CR>', { desc = 'Git browse' })
      set('n', '<leader>gs', '<cmd>:G<CR>', { desc = 'Git status' })
      set('n', '<leader>gcm', '<cmd>:Git checkout main<CR>', { desc = 'Git checkout main' })
      set('n', '<leader>gcc', ':Git checkout ', { desc = 'Git checkout' })
      set('n', '<leader>gcn', ':Git checkout -b ', { desc = 'Git checkout -b' })
      set('n', '<leader>gcl', '<cmd>:Git checkout @{-1}<CR>', { desc = 'Git checkout last' })
      set('n', '<leader>gM', '<cmd>:Git pull origin main<CR>', { desc = 'Git pull origin main' })
      set('n', '<leader>gP', '<cmd>:Git push origin HEAD<CR>', { desc = 'Git push origin HEAD' })
      set('n', '<leader>gl', '<cmd>:0Gclog<CR>', { desc = 'Git log' })
      set('n', '<leader>gl', '<cmd>:0Gclog<CR>', { desc = 'Git log' })
      set('n', '<leader>>gh', '<cmd>:LazyGitFilterCurrentFile<CR>', { desc = 'LazyGit file history' })
    end,
  },
  { 'tpope/vim-rhubarb', cond = not vim.g.vscode },
  {
    'sindrets/diffview.nvim',
    cond = not vim.g.vscode,
    config = function()
      set('n', '<leader>gd', function()
        if next(require('diffview.lib').views) == nil then
          vim.cmd 'DiffviewOpen'
        else
          -- If diffview is already open, close it
          vim.cmd 'DiffviewClose'
        end
      end, { desc = 'Git diff' })

      set('n', '<leader>gB', '<cmd>:Git blame<CR>', { desc = 'Git blame' })

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
