return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'antoinemadec/FixCursorHold.nvim',
    'nvim-treesitter/nvim-treesitter',
    'marilari88/neotest-vitest',
    'adrigzr/neotest-mocha',
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
      ---@diagnostic disable-next-line: missing-parameter
      require('neotest').watch.stop()
    end, { desc = '[T]est [W]atch [S]top [N]earest' })

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
    local neotest = require 'neotest'

    ---@diagnostic disable-next-line: missing-fields
    neotest.setup {
      projects = {
        ['/Users/schester/work/risk-management/api'] = {
          default_strategy = 'integrated',
          discovery = { enabled = true, concurrent = 0 },
          running = { concurrent = false },
          adapters = {
            require 'neotest-mocha' {
              command = 'yarn test:unfiltered:fast',
              cwd = '/Users/schester/work/risk-management/api',
            },
          },
        },
        ['/Users/schester/work/risk-management/web-client'] = {
          default_strategy = 'integrated',
          discovery = { enabled = true, concurrent = 0 },
          running = { concurrent = true },
          adapters = {
            require 'neotest-vitest' {
              vitestCommand = 'yarn test',
              cwd = '/Users/schester/work/risk-management/web-client',
            },
          },
        },
      },
    }
  end,
}
