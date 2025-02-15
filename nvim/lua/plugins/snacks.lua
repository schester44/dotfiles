return {
  {
    'folke/snacks.nvim',
    config = function()
      require('snacks').setup {
        picker = {
          ui_select = true,
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
              preview = false,
              layout = {
                backdrop = false,
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
          Snacks.picker.smart { title = 'Find Files' }
        end,
        desc = 'Find Files',
      },

      {
        '<leader>,',
        function()
          -- TODO: Simplify layout, dont need complete layout but want it centered.
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
          Snacks.picker.grep()
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

      {

        '<leader>ps',
        function()
          Snacks.profiler.scratch()
        end,
        desc = 'Profiler Scratch Bufer',
      },
    },
  },
}
