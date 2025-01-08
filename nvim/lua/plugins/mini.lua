return { -- Collectindent plugins/modules
  'echasnovski/mini.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
  config = function()
    -- Dashboard

    local header = [[
   ▄█    █▄       ▄████████  ▄█        ▄█        ▄██████▄  
  ███    ███     ███    ███ ███       ███       ███    ███ 
  ███    ███     ███    █▀  ███       ███       ███    ███ 
 ▄███▄▄▄▄███▄▄  ▄███▄▄▄     ███       ███       ███    ███ 
▀▀███▀▀▀▀███▀  ▀▀███▀▀▀     ███       ███       ███    ███ 
  ███    ███     ███    █▄  ███       ███       ███    ███ 
  ███    ███     ███    ███ ███▌    ▄ ███▌    ▄ ███    ███ 
  ███    █▀      ██████████ █████▄▄██ █████▄▄██  ▀██████▀  
]]

    require('mini.starter').setup { header = header, footer = '' }
    -- Better Around/Inside textobjects
    --
    -- Examples:
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
    --  - ci'  - [C]hange [I]nside [']quote
    local ai = require 'mini.ai'

    ai.setup {
      n_lines = 500,
      custom_textobjects = {
        f = ai.gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }, {}),
        c = ai.gen_spec.treesitter({ a = '@class.outer', i = '@class.inner' }, {}),
        a = ai.gen_spec.treesitter({ a = '@parameter.outer', i = '@parameter.inner' }, {}),
        p = ai.gen_spec.treesitter({ a = '@parameter.list', i = '@parameter.list' }, {}),
      },
    }

    require('mini.move').setup()
    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    --
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
    require('mini.surround').setup()
    -- ... and there is more!
    --  Check out: https://github.com/echasnovski/mini.nvim
  end,
}
