local snippets_dir = '~/.dotfiles/nvim/snippets'
local ui = require 'lib.ui'

return {
  'saghen/blink.cmp',
  cond = not vim.g.vscode,
  dependencies = {
    {
      'chrisgrieser/nvim-scissors',
    },
  },

  version = '1.*',

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = {
      preset = 'enter',
      ['<Tab>'] = {
        function()
          local copilot_suggestion = require 'copilot.suggestion'

          if copilot_suggestion.is_visible() then
            copilot_suggestion.accept()
            return true
          end
        end,
        'fallback',
      },
    },

    appearance = {
      nerd_font_variant = 'mono',
    },

    -- (Default) Only show the documentation popup when manually triggered
    completion = {
      menu = { border = ui.border_chars_outer_thin },
      documentation = { auto_show = false, window = { border = ui.border_chars_outer_thin } },
    },

    -- Default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, due to `opts_extend`
    sources = {
      providers = {
        snippets = {
          opts = {
            search_paths = { snippets_dir },
          },
        },
      },
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },

    -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
    -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
    -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
    --
    -- See the fuzzy documentation for more information
    fuzzy = { implementation = 'prefer_rust_with_warning' },
  },
  opts_extend = { 'sources.default' },
}
