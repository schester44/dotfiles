return {
  {
    'folke/snacks.nvim',
    cond = not vim.g.vscode,
    config = function()
      require('snacks').setup {
        picker = {
          ui_select = true,
          ----@class snacks.picker.formatters.Config
          formatters = {
            file = {
              filename_first = true, -- display filename before the file path
              truncate = 100,
            },
          },
          layouts = {
            default = {
              layout = {
                box = 'horizontal',
                width = 0.8,
                min_width = 120,
                height = 0.8,
                {
                  box = 'vertical',
                  border = 'rounded',
                  title = '{title} {live} {flags}',
                  { win = 'input', height = 2, border = 'bottom' },
                  { win = 'list', border = 'none' },
                },
                {
                  win = 'preview',
                  title = '{preview}',
                  border = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', '▏' },
                  width = 0.5,
                },
              },
            },
            select = {
              layout = {
                width = 0.3,
                min_width = 60,
                height = 0.4,
                min_height = 3,
                box = 'vertical',
                border = require('lib.ui').border_chars_outer_thin,
                title = '{title}',
                title_pos = 'center',
                { win = 'input', height = 2, border = 'none' },
                { win = 'list', border = 'none' },
                { win = 'preview', title = '{preview}', height = 0.4, border = 'top' },
              },
            },
          },
        },
      }
      -- Toggle the profiler
      Snacks.toggle.profiler():map '<leader>pp'
      -- Toggle the profiler highlights
      Snacks.toggle.profiler_highlights():map '<leader>ph'
    end,
    keys = {

      {
        '<leader><space>',
        function()
          Snacks.picker.smart { title = 'Find Files', sources = { files = { hidden = true } } }
        end,
        desc = 'Find Files',
      },
      {
        '<leader>sM',
        function()
          local function fetch()
            local handle = io.popen 'git status --porcelain'
            if not handle then
              return {}
            end

            local result = handle:read '*a'
            handle:close()

            local entries = {}

            for line in result:gmatch '[^\r\n]+' do
              local status = line:sub(1, 2)
              local file = line:sub(4)

              if status:match 'M' then
                table.insert(entries, {
                  label = status .. ' ' .. file,
                  value = file,
                  file = file,
                })
              end
            end

            return entries
          end

          Snacks.picker {
            title = 'Git Modified Files',
            items = fetch(),
          }
        end,
        desc = 'Git Modified Files',
      },
      {
        '<leader>,',
        function()
          Snacks.picker.buffers {
            layout = {
              layout = {
                box = 'vertical',
                width = 0.3,
                min_width = 80,
                height = 0.3,
                {
                  box = 'vertical',
                  border = 'rounded',
                  title = '{title} {live} {flags}',
                  { win = 'input', height = 2, border = 'bottom' },
                  { win = 'list', border = 'none' },
                },
              },
            },
          }
        end,
        desc = 'Buffers',
      },

      {
        '<leader>sg',
        function()
          Snacks.picker.grep {
            hidden = true,
          }
        end,
        desc = 'Grep',
      },
      {
        '<leader>sb',
        function()
          Snacks.picker.lines()
        end,
        desc = 'Buffer Lines',
      },

      {
        '<leader>sm',
        function()
          Snacks.picker.marks()
        end,
        desc = 'Marks',
      },

      {
        '<leader>sh',
        function()
          Snacks.picker.help()
        end,
        desc = 'Help',
      },

      {
        '<leader>sH',
        function()
          Snacks.picker.highlights()
        end,
        desc = 'Highlights',
      },

      {
        '<leader>sk',
        function()
          Snacks.picker.keymaps()
        end,
        desc = 'Keymaps',
      },

      {
        '<leader>sr',
        function()
          Snacks.picker.resume()
        end,
        desc = 'Resume',
      },

      {
        '<leader>sw',
        function()
          Snacks.picker.grep_word()
        end,
        desc = 'Word (or visual selection)',
        mode = { 'n', 'x' },
      },

      {
        '<leader>ss',
        function()
          require('auto-session.session-lens').search_session()
        end,
        desc = 'Session search',
      },

      {
        '<leader>sy',
        function()
          Snacks.picker.lsp_symbols()
        end,
        desc = 'LSP Symbols',
      },

      {
        '<leader>sS',
        function()
          Snacks.picker.lsp_workspace_symbols()
        end,
        desc = 'LSP Workspace Symbols',
      },
    },
  },
}
