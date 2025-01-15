local setup_starter = function()
  local header = [[]]
  local footer = [[]]

  local items = nil

  local is_vault = vim.fn.expand('%:p:h'):match '/vaults'

  local starter = require 'mini.starter'

  if is_vault then
    local name_of_vault = vim.fn.expand '%:p:h:t'
    items = { {
      action = 'edit' .. ' ' .. vim.fn.expand '%:p:h' .. '/index.md',
      name = 'index.md',
      section = name_of_vault,
    } }
  else
    items = {
      starter.sections.recent_files(10, true, false),
    }
  end

  starter.setup {
    header = header,
    footer = footer,
    items = items,
  }
end

return {
  'echasnovski/mini.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
  config = function()
    setup_starter()

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
  end,
}
