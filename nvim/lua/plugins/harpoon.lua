return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {},
  config = function()
    local harpoon = require 'harpoon'
    harpoon:setup {}

    local function git_diff()
      local pickers = require 'telescope.pickers'
      local finders = require 'telescope.finders'
      local conf = require('telescope.config').values
      local list = vim.fn.systemlist 'git diff --name-only'

      pickers
        .new({}, {
          prompt_title = 'git diff',
          finder = finders.new_table { results = list },
          sorter = conf.generic_sorter {},
          previewer = conf.file_previewer {},
        })
        :find()
    end

    vim.keymap.set('n', '<leader>hg', function()
      git_diff()
    end, { desc = 'Harpoon: Git diff files' })

    vim.keymap.set('n', '<leader>ha', function()
      harpoon:list():add()
    end, { desc = 'Harpoon: Add current file' })

    vim.keymap.set('n', '<leader>h1', function()
      harpoon:list():select(1)
    end)

    vim.keymap.set('n', '<leader>h2', function()
      harpoon:list():select(2)
    end)

    vim.keymap.set('n', '<leader>h3', function()
      harpoon:list():select(3)
    end)

    vim.keymap.set('n', '<leader>h4', function()
      harpoon:list():select(4)
    end)

    vim.keymap.set('n', '<leader>hh', function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = 'Harpoon: Open list' })
  end,
}
