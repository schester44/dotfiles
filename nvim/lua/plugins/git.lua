local set = vim.keymap.set

return {
  {
    'tpope/vim-fugitive',
    cond = not vim.g.vscode,
    config = function()
      set('n', '<leader>go', '<cmd>GBrowse<CR>', { desc = 'GBrowse' })
      set('x', '<leader>go', ':GBrowse<CR>', { desc = 'GBrowse (selection)' })

      set('n', '<leader>gs', '<cmd>:G<CR>', { desc = 'Git status' })
      set('n', '<leader>gcm', '<cmd>:Git checkout main<CR>', { desc = 'Git checkout main' })
      set('n', '<leader>gcb', ':Git checkout -b ', { desc = 'Git checkout -b' })
      set('n', '<leader>gcl', '<cmd>:Git checkout @{-1}<CR>', { desc = 'Git checkout last' })
      set('n', '<leader>gl', '<cmd>:0Gclog<CR>', { desc = 'Git log' })
      set('n', '<leader>gh', '<cmd>:DiffviewFileHistory %<CR>', { desc = 'File history' })
      set('n', '<leader>gB', '<cmd>:Git blame<CR>', { desc = 'Git blame' })
    end,
  },
  { 'tpope/vim-rhubarb', cond = not vim.g.vscode },
  {
    'sindrets/diffview.nvim',
    cond = not vim.g.vscode,
    config = function()
      set('n', '<leader>gd', '<cmd>:DiffviewOpen main...HEAD<CR>', { desc = 'Git diff' })

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
      require('gitsigns').setup {
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
        },
        on_attach = function(bufnr)
          local gitsigns = require 'gitsigns'

          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
          end

          -- Navigation
          map('n', ']c', function()
            if vim.wo.diff then
              vim.cmd.normal { ']c', bang = true }
            else
              gitsigns.nav_hunk 'next'
            end
          end, 'Next hunk')

          map('n', '[c', function()
            if vim.wo.diff then
              vim.cmd.normal { '[c', bang = true }
            else
              gitsigns.nav_hunk 'prev'
            end
          end, 'Prev hunk')

          -- Actions
          map('n', '<leader>hs', gitsigns.stage_hunk, 'Stage hunk')
          map('n', '<leader>hr', gitsigns.reset_hunk, 'Reset hunk')
          map('v', '<leader>hs', function()
            gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
          end, 'Stage hunk')
          map('v', '<leader>hr', function()
            gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
          end, 'Reset hunk')
          map('n', '<leader>hS', gitsigns.stage_buffer, 'Stage buffer')
          map('n', '<leader>hu', gitsigns.undo_stage_hunk, 'Undo stage hunk')
          map('n', '<leader>hR', gitsigns.reset_buffer, 'Reset buffer')
          map('n', '<leader>hp', gitsigns.preview_hunk, 'Preview hunk')
          map('n', '<leader>hb', function()
            gitsigns.blame_line { full = true }
          end, 'Blame line')
          map('n', '<leader>hd', gitsigns.diffthis, 'Diff this')
          map('n', '<leader>hD', function()
            gitsigns.diffthis '~'
          end, 'Diff this ~')

          -- Text object
          map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', 'GitSigns select hunk')
        end,
      }

      local set = vim.keymap.set
      
      set('n', '<leader>gv', function()
        require('gitsigns').preview_hunk()
      end, { desc = 'Git preview hunk' })
    end,
  },
}
