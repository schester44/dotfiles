local dap_keymap = function(key, fn, opts)
  opts = opts or {}
  opts.noremap = true
  vim.keymap.set('n', '<leader>d' .. key, fn, opts)
end

dap_keymap('n', function() end)

return {
  {
    'rcarriga/nvim-dap-ui',
    dependencies = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' },
    config = function()
      require('dapui').setup()
    end,
  },
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      {
        'theHamsta/nvim-dap-virtual-text',
        config = function()
          require('nvim-dap-virtual-text').setup {
            enabled = true,
          }
        end,
      },
      'jbyuki/one-small-step-for-vimkind',
    },
    opts = {},
    config = function()
      local dap = require 'dap'

      dap.configurations.lua = {
        {
          type = 'nlua',
          request = 'attach',
          name = 'Attach to running Neovim instance',
        },
      }

      local dapui = require 'dapui'

      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end

      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end

      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end

      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end

      vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl = '', linehl = 'DapBreakpoint', numhl = '' })
      vim.fn.sign_define('DapStopped', { text = '󰳟', texthl = '', linehl = 'DapStopped', numhl = '' })

      dap_keymap('b', dap.toggle_breakpoint, { noremap = true, desc = 'Toggle Breakpoint' })
      dap_keymap('c', dap.continue, { noremap = true, desc = 'Continue' })
      dap_keymap('o', dap.step_over, { noremap = true, desc = 'Step Over' })
      dap_keymap('i', dap.step_into, { noremap = true, desc = 'Step Into' })
      dap_keymap('r', dap.repl.open, { noremap = true, desc = 'Open REPL' })
      dap_keymap('q', dap.close, { noremap = true, desc = 'Open REPL' })

      dap_keymap('f', function()
        local widgets = require 'dap.ui.widgets'
        widgets.centered_float(widgets.frames)
      end, { noremap = true, desc = 'List Frames' })

      dap_keymap('w', function()
        local widgets = require 'dap.ui.widgets'
        widgets.hover()
      end, { noremap = true, desc = 'Hover' })

      dap_keymap('l', function()
        require('osv').launch { port = 8086 }
      end, { noremap = true, desc = 'Launch' })

      dap.adapters.nlua = function(callback, config)
        callback { type = 'server', host = config.host or '127.0.0.1', port = config.port or 8086 }
      end
    end,
  },
}
