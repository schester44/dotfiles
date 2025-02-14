return {
  {
    'folke/snacks.nvim',
    config = function()
      require('snacks').setup {
        picker = {
          ui_select = true,
          layouts = {
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
          Snacks.picker.smart()
        end,
        desc = 'Find Files',
      },

      {
        '<leader>,',
        function()
          -- TODO: Simplify layout, dont need complete layout but want it centered.
          Snacks.picker.buffers()
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
        '<leader>fm',
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
