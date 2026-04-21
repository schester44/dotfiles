local plugins = require 'lib.plugins'

plugins.add {
  { src = 'nvim-lua/plenary.nvim' },

  {
    src = 'trevorhauter/gitportal.nvim',
    opts = function(ctx)
      local gp = require 'gitportal'

      -- Opens the current file in your browser at the correct branch/commit.
      -- When in visual mode, selected lines are included in the permalink.
      ctx.map('n', '<leader>go', gp.open_file_in_browser, { desc = 'Open file in Github' })
      ctx.map('v', '<leader>go', gp.open_file_in_browser, { desc = 'Open file in Github' })

      -- Opens a Githost link directly in Neovim, optionally switching to the branch/commit.
      ctx.map('n', '<leader>ig', gp.open_file_in_neovim, { desc = 'Open Github link in Neovim' })

      -- Generates and copies the permalink of your current file to your clipboard.
      -- When in visual mode, selected lines are included in the permalink.
      ctx.map('n', '<leader>gc', gp.copy_link_to_clipboard, { desc = 'Copy GitHub link to clipboard' })
      ctx.map('v', '<leader>gc', gp.copy_link_to_clipboard, { desc = 'Copy GitHub link to clipboard' })

      return { always_include_current_line = true }
    end,
  },

  {
    src = 'NeogitOrg/neogit',
    opts = function(ctx)
      ctx.map('n', '<leader>gg', '<cmd>Neogit<cr>', { desc = 'Neogit' })
    end,
  },

  {
    src = 'sindrets/diffview.nvim',
    opts = function(ctx)
      vim.opt.diffopt = {
        'internal',
        'filler',
        'closeoff',
        'context:12',
        'algorithm:histogram',
        'linematch:200',
        'indent-heuristic',
      }

      ctx.map('n', '<leader>gh', '<cmd>:DiffviewFileHistory %<CR>', { desc = 'File history' })

      ctx.map('n', '<leader>gD', function()
        local ref = vim.fn.input('DiffviewOpen ref/range: ', 'main')
        if ref ~= '' then
          vim.cmd('DiffviewOpen ' .. ref)
        end
      end, { desc = 'Diffview' })

      -- Merge conflict resolution: opens 3-way diff when in a merge/rebase state
      ctx.map('n', '<leader>gd', '<cmd>DiffviewOpen<CR>', { desc = 'Diffview merge conflicts' })
      ctx.map('n', '<leader>gq', '<cmd>DiffviewClose<CR>', { desc = 'Diffview close' })

      return { enhanced_diff_hl = true }
    end,
  },

  {
    src = 'lewis6991/gitsigns.nvim',
    version = vim.version.range('2.0'),
    opts = function(ctx)
      ctx.map('n', '<leader>gb', '<cmd>:Gitsigns blame<CR>', { desc = 'Git blame' })

      local gs = require 'gitsigns'

      ctx.map('n', ']c', function()
        if vim.wo.diff then
          vim.cmd.normal { ']c', bang = true }
        else
          gs.nav_hunk 'next'
        end
      end, { desc = 'Next hunk' })

      ctx.map('n', '[c', function()
        if vim.wo.diff then
          vim.cmd.normal { '[c', bang = true }
        else
          gs.nav_hunk 'prev'
        end
      end, { desc = 'Prev hunk' })

      ctx.map('n', '<leader>gs', gs.stage_hunk, { desc = 'Stage hunk' })
      ctx.map('n', '<leader>gr', gs.reset_hunk, { desc = 'Reset hunk' })
      ctx.map('n', '<leader>gu', gs.undo_stage_hunk, { desc = 'Undo stage hunk' })
      ctx.map('n', '<leader>gp', gs.preview_hunk_inline, { desc = 'Preview hunk' })
      ctx.map('n', '<leader>gP', gs.preview_hunk, { desc = 'Preview hunk inline' })
      ctx.map('n', '<leader>xb', gs.toggle_current_line_blame, { desc = 'Toggle line blame' })
    end,
  },

}
