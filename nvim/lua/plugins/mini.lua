return { -- Collectindent plugins/modules
  'echasnovski/mini.nvim',
  config = function()
    -- matching pairs of characters
    require('mini.pairs').setup()

    -- Dashboard
    require('mini.starter').setup { header = '', footer = '' }
    -- Better Around/Inside textobjects
    --
    -- Examples:
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
    --  - ci'  - [C]hange [I]nside [']quote
    require('mini.ai').setup { n_lines = 500 }

    -- TODO: Get these to work
    --
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
