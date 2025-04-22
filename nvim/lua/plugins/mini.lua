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
    if not vim.g.vscode then
      setup_starter()
    end

    local hipatterns = require 'mini.hipatterns'

    hipatterns.setup {
      highlighters = {
        fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
        fixme2 = { pattern = '%f[%w]()fixme()%f[%W]', group = 'MiniHipatternsFixme' },
        todo = {
          pattern = '%f[%w]()TODO()%f[%W]',
          group = 'MiniHipatternsTodo',
        },
        todo2 = {
          pattern = '%f[%w]()todo()%f[%W]',
          group = 'MiniHipatternsTodo',
        },
        note = { pattern = '%f[%w]()NOTE()%f[%W]', group = 'MiniHipatternsNote' },
        hex_color = hipatterns.gen_highlighter.hex_color(),
      },
    }

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

    require('mini.bufremove').setup()

    -- Move lines
    require('mini.move').setup {
      mappings = {
        -- visual mode
        left = '<S-h>',
        right = '<S-l>',
        down = '<S-j>',
        up = '<S-k>',
        -- normal mode
        line_left = '<S-h>',
        line_right = '<S-l>',
        line_down = '<S-j>',
        line_up = '<S-k>',
      },
    }
    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    --
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
    require('mini.surround').setup()
  end,
}
