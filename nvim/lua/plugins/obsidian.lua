local oneOnOneTemplate = [[
      ## {date}

      ### Topics
      - {a}
      ### Notes
      - {b}
      ### Action Items

      ---
      ]]

return {
  {
    'epwalsh/obsidian.nvim',
    version = '*', -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = 'markdown',
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    -- event = {
    --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
    --   -- refer to `:h file-pattern` for more examples
    --   "BufReadPre path/to/my-vault/*.md",
    --   "BufNewFile path/to/my-vault/*.md",
    -- },
    dependencies = {
      -- Required.
      'nvim-lua/plenary.nvim',
    },
    config = function()
      local ls = require 'luasnip'
      local fmt = require('luasnip.extras.fmt').fmt

      ls.add_snippets('markdown', {
        ls.snippet(
          '11header',
          fmt(
            oneOnOneTemplate,
            { a = ls.insert_node(1, 'Write your topics'), b = ls.insert_node(2, 'Write your notes'), date = ls.text_node(os.date '%Y-%m-%d') }
          )
        ),
      })

      vim.keymap.set('n', '<leader>od', '<CMD>ObsidianDailies<CR>', { desc = '[O]bsidian [D]aily Note' })

      require('obsidian').setup {
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
