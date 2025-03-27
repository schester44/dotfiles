return {
  'nvim-neotest/neotest',
  cond = not vim.g.vscode,
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'antoinemadec/FixCursorHold.nvim',
    'nvim-treesitter/nvim-treesitter',
    'marilari88/neotest-vitest',
    'adrigzr/neotest-mocha',
    'thenbe/neotest-playwright',
  },
  config = function()
    -- Keymaps
    local k = require 'lib.keymaps'

    local n = require 'neotest'

    k.set_test_keymap {
      keys = 'f',
      cmd = function()
        n.run.run(vim.fn.expand '%')
      end,
      desc = 'Run File',
    }

    k.set_test_keymap {
      keys = 'a',
      cmd = function()
        require('neotest').playwright.attachment()
      end,
      desc = 'Playwright attachments',
    }

    k.set_test_keymap {
      keys = 'l',
      cmd = function()
        n.run.run_last()
      end,
      desc = 'Run Last',
    }

    k.set_test_keymap {
      keys = 'n',
      cmd = function()
        n.run.run()
      end,
      desc = 'Run Nearest',
    }

    k.set_test_keymap {
      keys = 's',
      cmd = function()
        n.run.stop()
      end,
      desc = 'Stop Test',
    }

    k.set_test_keymap {
      keys = 'wf',
      cmd = function()
        n.watch.watch(vim.fn.expand '%')
      end,
      desc = 'Watch File',
    }

    k.set_test_keymap {
      keys = 'wn',
      cmd = function()
        require('neotest').watch.watch()
      end,
      desc = 'Watch Nearest',
    }

    k.set_test_keymap {
      keys = 'wsn',
      cmd = function()
        ---@diagnostic disable-next-line: missing-parameter
        require('neotest').watch.stop()
      end,
      desc = 'Watch Stop Nearest',
    }

    k.set_test_keymap {
      keys = 'wsf',
      cmd = function()
        require('neotest').watch.stop(vim.fn.expand '%')
      end,
      desc = 'Watch Stop File',
    }

    k.set_test_keymap {
      keys = 'O',
      cmd = function()
        require('neotest').summary.toggle()
      end,
      desc = 'Summary Output',
    }

    k.set_test_keymap {
      keys = 'o',
      cmd = function()
        require('neotest').output_panel.toggle()
      end,
      desc = 'Output',
    }

    local mochaAdapter = require 'neotest-mocha' {
      command = 'yarn test:unfiltered:fast',
      cwd = '/Users/schester/work/risk-management/api',
    }

    mochaAdapter.filter_dir = function(name, rel_path, root)
      return string.match(rel_path, 'api')
    end

    ---@diagnostic disable-next-line: missing-fields
    n.setup {
      consumers = {
        playwright = require('neotest-playwright.consumers').consumers,
      },
      adapters = {
        mochaAdapter,
        require 'neotest-vitest' {
          vitestCommand = 'yarn test',
          cwd = '/Users/schester/work/risk-management/web-client',
        },
        require('neotest-playwright').adapter {
          options = {
            env = { NODE_ENV = 'test' },
            persist_project_selection = true,
            enable_dynamic_test_discovery = true,
            filter_dir = function(name, rel_path)
              return string.match(rel_path, 'playwright')
            end,
          },
        },
      },
    }
  end,
}
