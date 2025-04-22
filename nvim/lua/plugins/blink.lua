local snippets_dir = '~/.dotfiles/nvim/snippets'
local ui = require 'lib.ui'

return {
  'saghen/blink.cmp',
  event = 'VimEnter',
  cond = not vim.g.vscode,
  dependencies = {
    {
      'chrisgrieser/nvim-scissors',
      'folke/lazydev.nvim',
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
      menu = {
        border = ui.border_chars_outer_thin,
        draw = {
          treesitter = {},
          columns = { { 'kind_icon', 'label', 'label_description', gap = 1, 'source_name' } },
        },
      },
      documentation = { auto_show = false, window = { border = ui.border_chars_outer_thin } },
    },
    sources = {
      providers = {
        snippets = {
          opts = {
            search_paths = { snippets_dir },
          },
        },
        lazydev = {
          name = 'LazyDev',
          module = 'lazydev.integrations.blink',
          -- make lazydev completions top priority (see `:h blink.cmp`)
          score_offset = 100,
        },
      },
      default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
    },

    fuzzy = { implementation = 'prefer_rust_with_warning' },
    signature = { enabled = true },
  },
  opts_extend = { 'sources.default' },
}
