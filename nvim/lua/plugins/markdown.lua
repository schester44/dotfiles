return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    cond = not vim.g.vscode,
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
    ft = { 'markdown', 'codecompanion' },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      link = { wiki = { icon = '󰎛 ' } },
      heading = {
        render_modes = { 'n', 'i' },
        border = true,
        border_virtual = true,
        position = 'inline',
        signs = { '' },
        icons = { '󰎤 ', '󰎧 ', '󰎪 ', '󰎭 ', '󰎱 ', '󰎳 ' },
        backgrounds = { 'Headline1', 'Headline2', 'Headline3', 'Headline4', 'Headline5', 'Headline6' },
        foregrounds = { 'Headline1', 'Headline2', 'Headline3', 'Headline4', 'Headline5', 'Headline6' },
      },
    },
  },
  {
    'epwalsh/obsidian.nvim',
    cond = not vim.g.vscode,
    version = '*', -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = 'markdown',
    dependencies = {
      -- Required.
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require('obsidian').setup {
        ui = { enable = false },
        workspaces = {
          {
            name = 'work',
            path = '~/vaults/work',
          },
        },
        note_id_func = function(title)
          -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
          -- In this case a note with the title 'My new note' will be given an ID that looks
          -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
          local suffix = ''
          if title ~= nil then
            -- If title is given, transform it into valid file name.
            suffix = title:gsub(' ', '-'):gsub('[^A-Za-z0-9-]', ''):lower()
          else
            -- If title is nil, just add 4 random uppercase letters to the suffix.
            for _ = 1, 4 do
              suffix = suffix .. string.char(math.random(65, 90))
            end
          end

          local year = os.date '%Y'
          local month = os.date '%m'
          local day = os.date '%d'

          return year .. '-' .. month .. '-' .. day .. '-' .. suffix
        end,
      }
    end,
  },
}
