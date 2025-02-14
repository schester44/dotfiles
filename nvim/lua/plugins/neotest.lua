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
    vim.keymap.set('n', '<leader>Tf', function()
      require('neotest').run.run(vim.fn.expand '%')
    end, { desc = 'Run [T]est [F]ile' })

    vim.keymap.set('n', '<leader>Tl', function()
      require('neotest').run.run_last()
    end, { desc = 'Run Last Test' })

    vim.keymap.set('n', '<leader>Tn', function()
      require('neotest').run.run()
    end, { desc = 'Run [T]est [N]earest' })

    vim.keymap.set('n', '<leader>Ts', function()
      require('neotest').run.stop()
    end, { desc = '[T]est [S]top' })

    vim.keymap.set('n', '<leader>Twf', function()
      require('neotest').watch.watch(vim.fn.expand '%')
    end, { desc = 'Run [T]est [W]atch [F]ile' })

    vim.keymap.set('n', '<leader>Twn', function()
      require('neotest').watch.watch()
    end, { desc = 'Run [T]est [W]atch [N]earest' })

    vim.keymap.set('n', '<leader>Twsn', function()
      ---@diagnostic disable-next-line: missing-parameter
      require('neotest').watch.stop()
    end, { desc = '[T]est [W]atch [S]top [N]earest' })

    vim.keymap.set('n', '<leader>Twsf', function()
      require('neotest').watch.stop(vim.fn.expand '%')
    end, { desc = '[T]est [W]atch [S]top [F]ile' })

    vim.keymap.set('n', '<leader>TO', function()
      require('neotest').summary.toggle()
    end, { desc = '[T]est Summary [O]utput' })

    vim.keymap.set('n', '<leader>To', function()
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
