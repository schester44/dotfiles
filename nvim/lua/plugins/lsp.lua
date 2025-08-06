---@diagnostic disable: unused-local
return {
  {
    'Sebastian-Nielsen/better-type-hover',
    config = function()
      require('better-type-hover').setup {
        openTypeDocKeymap = 'gk',
      }
    end,
  },
  { 'Bilal2453/luvit-meta', lazy = true, cond = not vim.g.vscode },
  {
    'neovim/nvim-lspconfig',
    cond = not vim.g.vscode,
    dependencies = {
      { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
      'williamboman/mason-lspconfig.nvim',
      'saghen/blink.cmp',
      {
        'j-hui/fidget.nvim',
        config = function()
          require('fidget').setup {
            notification = { window = { winblend = 0, relative = 'editor' } },
          }
        end,
      },
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = desc })
          end

          --  To jump back, press <C-t>.
          map('gd', function()
            Snacks.picker.lsp_definitions()
          end, 'Goto Definition')

          map('gD', vim.lsp.buf.declaration, 'Goto Declaration')

          -- Find references for the word under your cursor.
          map('gr', function()
            Snacks.picker.lsp_references()
          end, 'Goto References')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gI', function()
            Snacks.picker.lsp_implementations()
          end, 'Goto Implementation')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('gt', function()
            Snacks.picker.lsp_type_definitions()
          end, 'Goto Type Definition')

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('<leader>cr', vim.lsp.buf.rename, 'Code Rename')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('<leader>ca', vim.lsp.buf.code_action, 'Code Action', { 'n', 'x' })

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)

          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end
        end,
      })

      require('mason').setup()

      ---@diagnostic disable-next-line: missing-fields
      require('mason-lspconfig').setup {

        ensure_installed = {
          'lua_ls',
          'eslint',
          'jsonls',
          'bashls',
          'prismals',
          'pylsp',
          'tailwindcss',
          'yamlls',
          'vtsls',
        },
      }

      local base_on_attach = vim.lsp.config.eslint.on_attach

      vim.lsp.config('eslint', {
        flags = {
          debounce_text_changes = 500,
        },
        on_attach = function(client, bufnr)
          if not base_on_attach then
            return
          end

          base_on_attach(client, bufnr)

          vim.api.nvim_create_autocmd('BufWritePre', {
            buffer = bufnr,
            command = 'LspEslintFixAll',
          })
        end,
      })

      vim.lsp.enable 'eslint'
    end,
  },
}
