local snippets_dir = '~/.dotfiles/nvim/snippets'

return {
  'hrsh7th/nvim-cmp',
  event = 'InsertEnter',
  dependencies = {
    {
      'L3MON4D3/LuaSnip',
      build = (function()
        -- Build Step is needed for regex support in snippets.
        -- This step is not supported in many windows environments.
        -- Remove the below condition to re-enable on windows.
        if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
          return
        end
        return 'make install_jsregexp'
      end)(),

      dependencies = {
        {
          'chrisgrieser/nvim-scissors',
          dependencies = 'nvim-telescope/telescope.nvim',
          opts = {
            snippetDir = snippets_dir,
          },
          config = function()
            require('luasnip.loaders.from_vscode').lazy_load {
              paths = snippets_dir,
            }
            require('luasnip').filetype_extend('typescript', { 'javascript' })
            require('luasnip').filetype_extend('typescriptreact', { 'javascript' })
          end,
        },
      },
    },
    'onsails/lspkind.nvim',
    'saadparwaiz1/cmp_luasnip',

    -- Adds other completion capabilities.
    --  nvim-cmp does not ship with all sources by default. They are split
    --  into multiple repos for maintenance purposes.
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-path',
  },
  config = function()
    -- See `:help cmp`
    local cmp = require 'cmp'
    local luasnip = require 'luasnip'
    luasnip.config.setup {}

    local copilot_suggestion = require 'copilot.suggestion'

    local lspkind = require 'lspkind'
    local compare = require 'cmp.config.compare'
    local icons = require('lib.icons').icons

    -- If can prefix with index for each completion item, i can select with <number><tab>
    -- local select_by_index = function(index)
    --   return function()
    --     local selected_index = cmp.get_selected_index()
    --     local count = index
    --
    --     if selected_index > 0 then
    --       count = index - selected_index
    --     end
    --
    --     cmp.select_next_item { count = count }
    --   end
    -- end

    local has_words_before = function()
      if vim.api.nvim_buf_get_option(0, 'buftype') == 'prompt' then
        return false
      end
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      print(line, col)
      return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match '^%s*$' == nil
    end

    cmp.setup {
      experimental = {
        ghost_text = true,
      },
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },

      formatting = {
        fields = { 'kind', 'abbr', 'menu' },
        expandable_indicator = true,
        format = lspkind.cmp_format {
          preset = 'codicons',
          mode = 'symbol', -- show only symbol annotations
          symbol_map = {
            Copilot = icons.kinds.CopilotOnline,
          },
          maxwidth = {
            -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
            -- can also be a function to dynamically calculate max width such as
            -- menu = function() return math.floor(0.45 * vim.o.columns) end,
            menu = 30, -- leading text (labelDetails)
            abbr = 50, -- actual suggestion item
          },
          ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
          show_labelDetails = true, -- show labelDetails in menu. Disabled by default

          -- The function below will be called before any actual modifications from lspkind
          -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
          before = function(entry, vim_item)
            -- Append source and details for `nvim_lsp` suggestions

            if entry.source.name == 'nvim_lsp' and entry.completion_item.detail then
              vim_item.menu = string.format('%s %s', vim_item.menu or '', entry.completion_item.detail)
            end

            return vim_item
          end,
        },
      },
      completion = { completeopt = 'menu,menuone,noinsert' },

      sorting = {
        priority_weight = 1.0,
        comparators = {
          compare.locality,
          compare.recently_used,
          compare.score, -- based on :  score = score + ((#sources - (source_index - 1)) * sorting.priority_weight)
          compare.offset,
          compare.exact,
          compare.order,
        },
      },

      -- `:help ins-completion`
      mapping = cmp.mapping.preset.insert {
        -- Select the next item
        ['<C-j>'] = cmp.mapping.select_next_item(),
        -- Select the previous item
        ['<C-k>'] = cmp.mapping.select_prev_item(),

        ['<Tab>'] = vim.schedule_wrap(function(fallback)
          if cmp.visible() and has_words_before() then
            cmp.confirm { select = true } -- Confirm the currently selected nvim-cmp item
          elseif copilot_suggestion.is_visible() and has_words_before() then
            copilot_suggestion.accept() -- Accept the Copilot suggestion
          elseif luasnip.expand_or_locally_jumpable() then -- move to the right of the snippet
            luasnip.expand_or_jump()
          else
            fallback() -- Default tab behavior
          end
        end),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.expand_or_locally_jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { 'i', 's' }),
        -- Trigger snippet-only completion
        ['<C-s>'] = cmp.mapping(function()
          cmp.complete {
            config = {
              sources = {
                { name = 'luasnip' }, -- Only snippets
              },
            },
          }
          assert(cmp.visible(), 'No snippets available')
        end, { 'i', 's' }), -- Available in insert and select mode
        ['<C-[>'] = cmp.mapping.scroll_docs(-4),
        ['<C-]>'] = cmp.mapping.scroll_docs(4),

        -- Exit the completion
        ['<C-e>'] = cmp.mapping.abort(),
        ['<Esc>'] = cmp.mapping.abort(),

        -- Manually trigger a completion from nvim-cmp.
        --  Generally you don't need this, because nvim-cmp will display
        --  completions whenever it has completion options available.
        ['<C-Space>'] = cmp.mapping.complete {},

        -- Think of <c-l> as moving to the right of your snippet expansion.
        --  So if you have a snippet that's like:
        --  function $name($args)
        --    $body
        --  end
        --
        -- <c-l> will move you to the right of each of the expansion locations.
        -- <c-h> is similar, except moving you backwards.
        -- <Tab> is used to navigate between the placeholders.
        ['<C-l>'] = cmp.mapping(function()
          if luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
          end
        end, { 'i', 's' }),
        ['<C-h>'] = cmp.mapping(function()
          if luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
          end
        end, { 'i', 's' }),
      },
      sources = {
        { name = 'luasnip', priority = 1300 },
        {
          name = 'copilot',
          priority = 1200,
        },
        { name = 'nvim_lsp', priority = 900 },
        { name = 'path', priority = 800 },
        {
          name = 'lazydev',
          priority = 700,
          -- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
          group_index = 0,
        },
      },
    }
  end,
}
