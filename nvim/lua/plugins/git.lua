local set = vim.keymap.set

return {
  {
    'trevorhauter/gitportal.nvim',
    config = function()
      local gitportal = require 'gitportal'

      gitportal.setup {
        always_include_current_line = true,
      }

      -- Opens the current file in your browser at the correct branch/commit.
      -- When in visual mode, selected lines are included in the permalink.
      set('n', '<leader>go', gitportal.open_file_in_browser, { desc = 'Open file in Github' })
      set('v', '<leader>go', gitportal.open_file_in_browser, { desc = 'Open file in Github' })

      -- Opens a Githost link directly in Neovim, optionally switching to the branch/commit.
      set('n', '<leader>ig', gitportal.open_file_in_neovim, { desc = 'Open Github link in Neovim' })

      -- Generates and copies the permalink of your current file to your clipboard.
      -- When in visual mode, selected lines are included in the permalink.
      set('n', '<leader>gc', gitportal.copy_link_to_clipboard, { desc = 'Copy GitHub link to clipboard' })
      set('v', '<leader>gc', gitportal.copy_link_to_clipboard, { desc = 'Copy GitHub link to clipboard' })
    end,
  },

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

      local gs = require 'gitsigns'

      set('n', ']c', function()
        if vim.wo.diff then
          vim.cmd.normal { ']c', bang = true }
        else
          gs.nav_hunk 'next'
        end
      end, { desc = 'Next hunk' })

      set('n', '<leader>hs', gs.stage_hunk, { desc = 'Stage hunk' })
      set('n', '<leader>hr', gs.reset_hunk, { desc = 'Reset hunk' })
      set('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'Undo stage hunk' })
      set('n', '<leader>hp', gs.preview_hunk, { desc = 'Preview hunk' })
      set('n', '<leader>hd', gs.diffthis, { desc = 'Diff hunk' })
      set('n', '<leader>Tb', gs.toggle_current_line_blame, { desc = 'Toggle line blame' })

      set('n', '[c', function()
        if vim.wo.diff then
          vim.cmd.normal { '[c', bang = true }
        else
          gs.nav_hunk 'prev'
        end
      end, { desc = 'Prev hunk' })

      set('n', '<leader>gv', function()
        require('gitsigns').preview_hunk()
      end, { desc = 'Git preview hunk' })
    end,
  },
}
