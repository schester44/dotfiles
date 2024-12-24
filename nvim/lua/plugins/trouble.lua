return {
  {
    'artemave/workspace-diagnostics.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'folke/trouble.nvim',
    },
    config = function()
      require('workspace-diagnostics').setup {

        -- TODO: This works but outputs entirely too many useless files for the project
        workspace_files = function() -- Customize this function to return project files.
          -- ignore .semaphore and .yarn files
          return vim.fn.systemlist 'git ls-files' -- Example to get files from Git.
        end,
        -- Add any other configuration options as needed.
      }

      -- Populate workspace diagnostics on demand
      vim.api.nvim_set_keymap('n', '<space>xp', '', {
        noremap = true,
        callback = function()
          for _, client in ipairs(vim.lsp.get_clients()) do
            require('workspace-diagnostics').populate_workspace_diagnostics(client, 0)
          end
        end,
        desc = 'Populate workspace diagnostics',
      })
    end,
  },
  {
    'folke/trouble.nvim',
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = 'Trouble',
    keys = {
      { '<leader>xw', '<cmd>Trouble diagnostics toggle<cr>', desc = 'All Diagnostics (Trouble)' },
      {
        '<leader>xx',
        '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
        desc = 'Buffer Diagnostics (Trouble)',
      },
      {
        '<leader>xL',
        '<cmd>Trouble loclist toggle<cr>',
        desc = 'Location List (Trouble)',
      },
      {
        '<leader>xQ',
        '<cmd>Trouble qflist toggle<cr>',
        desc = 'Quickfix List (Trouble)',
      },
    },
  },
}
