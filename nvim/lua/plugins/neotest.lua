return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'antoinemadec/FixCursorHold.nvim',
    'nvim-treesitter/nvim-treesitter',
    'marilari88/neotest-vitest',
  },
  config = function()
    -- Keymaps
    vim.keymap.set('n', '<leader>tf', function()
      require('neotest').run.run(vim.fn.expand '%')
    end, { desc = 'Run [T]est [F]ile' })

    vim.keymap.set('n', '<leader>tl', function()
      require('neotest').run.run_last()
    end, { desc = 'Run Last Test' })

    vim.keymap.set('n', '<leader>tn', function()
      require('neotest').run.run()
    end, { desc = 'Run [T]est [N]earest' })

    vim.keymap.set('n', '<leader>twf', function()
      require('neotest').watch.watch(vim.fn.expand '%')
    end, { desc = 'Run [T]est [W]atch [F]ile' })

    vim.keymap.set('n', '<leader>twn', function()
      require('neotest').watch.watch()
    end, { desc = 'Run [T]est [W]atch [N]earest' })

    vim.keymap.set('n', '<leader>twsn', function()
      require('neotest').watch.stop()
    end, { desc = 'Run [T]est [W]atch [S]top [N]earess' })

    vim.keymap.set('n', '<leader>twsf', function()
      require('neotest').watch.stop(vim.fn.expand '%')
    end, { desc = '[T]est [W]atch [S]top [F]ile' })

    vim.keymap.set('n', '<leader>ts', function()
      require('neotest').summary.toggle()
    end, { desc = '[T]est [S]ummary' })

    vim.keymap.set('n', '<leader>to', function()
      require('neotest').output_panel.toggle()
    end, { desc = '[T]est [O]utput' })

    --- Adapters
    require('neotest').setup {
      adapters = {
        require 'neotest-vitest' {
          -- TODO: This shouldn't be hardcoded
          cwd = function()
            return '/Users/schester/work/risk-management/web-client'
          end,
          vitestCommand = 'yarn test', -- Uses `npx vitest` to run tests
        },
      },
    }
  end,
}
