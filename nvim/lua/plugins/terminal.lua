return {
  'akinsho/toggleterm.nvim',
  cond = not vim.g.vscode,
  version = '*',
  opts = {
    size = function(term)
      if term.direction == 'horizontal' then
        return 15
      elseif term.direction == 'vertical' then
        return vim.o.columns * 0.4
      end
    end,
    open_mapping = [[<c-\>]],
    hide_numbers = true,
    shade_terminals = false,
    start_in_insert = true,
    insert_mappings = true,
    persist_size = true,
    direction = 'float',
    close_on_exit = true,
    shell = vim.o.shell,
    float_opts = {
      border = 'curved',
      winblend = 0,
      highlights = {
        border = 'Normal',
        background = 'Normal',
      },
    },
  },
  config = function(_, opts)
    require('toggleterm').setup(opts)

    local Terminal = require('toggleterm.terminal').Terminal

    -- Lazygit terminal
    local lazygit = Terminal:new {
      cmd = 'lazygit',
      dir = 'git_dir',
      direction = 'float',
      float_opts = {
        border = 'curved',
        width = function()
          return math.floor(vim.o.columns * 0.9)
        end,
        height = function()
          return math.floor(vim.o.lines * 0.9)
        end,
      },
      on_open = function(term)
        vim.cmd 'startinsert!'
        vim.api.nvim_buf_set_keymap(term.bufnr, 'n', 'q', '<cmd>close<CR>', { noremap = true, silent = true })
      end,
      on_close = function(term)
        vim.cmd 'startinsert!'
      end,
    }

    -- Node REPL
    local node = Terminal:new {
      cmd = 'node',
      direction = 'float',
    }

    -- Python REPL
    local python = Terminal:new {
      cmd = 'python3',
      direction = 'float',
    }

    function _LAZYGIT_TOGGLE()
      lazygit:toggle()
    end

    function _NODE_TOGGLE()
      node:toggle()
    end

    function _PYTHON_TOGGLE()
      python:toggle()
    end

    -- Key mappings
    local k = require 'lib.keymaps'
    
    k.set_toggle_keymap {
      keys = 't',
      desc = 'Terminal',
      cmd = '<cmd>ToggleTerm<CR>',
    }

    vim.keymap.set('n', '<leader>gg', '<cmd>lua _LAZYGIT_TOGGLE()<CR>', { desc = 'Lazygit' })
    vim.keymap.set('n', '<leader>tn', '<cmd>lua _NODE_TOGGLE()<CR>', { desc = 'Node REPL' })
    vim.keymap.set('n', '<leader>tp', '<cmd>lua _PYTHON_TOGGLE()<CR>', { desc = 'Python REPL' })

    -- Terminal mode mappings
    vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], { desc = 'Exit terminal mode' })
    vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], { desc = 'Move to left window' })
    vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], { desc = 'Move to bottom window' })
    vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], { desc = 'Move to top window' })
    vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], { desc = 'Move to right window' })
    vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], { desc = 'Window commands' })
  end,
}