return {
  cond = not vim.g.vscode,
  'Wansmer/treesj',
  dependencies = { 'nvim-treesitter/nvim-treesitter' }, -- if you install parsers with `nvim-treesitter`
  config = function()
    local tj = require 'treesj'
    tj.setup {
      use_default_keymaps = false,
      max_join_length = 999,
    }

    vim.keymap.set('n', 'gS', function()
      tj.toggle()
    end, { desc = 'Treejs - Split/Join', noremap = true, silent = true })
  end,
}
