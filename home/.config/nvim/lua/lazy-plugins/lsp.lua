---@diagnostic disable: unused-local
return {

  {
    'Sebastian-Nielsen/better-type-hover',
    config = function()
      require('better-type-hover').setup {
        openTypeDocKeymap = 'gK',
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

          map('grd', vim.lsp.buf.definition, 'Goto Definition')
          map('gk', vim.lsp.buf.hover, 'LSP Hover')
          -- these have been remapped under `gr` default prefix
          -- map('gr', vim.lsp.buf.references, 'Goto References')
          -- map('<leader>cr', vim.lsp.buf.rename, 'Code Rename')
          -- map('<leader>ca', vim.lsp.buf.code_action, 'Code Action', { 'n', 'x' })

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)

          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
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
          'copilot',
          'tsgo',
          'oxlint',
          'oxfmt',
        },
      }

      -- oxc (oxlint) — only activate when .oxlintrc.json exists
      vim.lsp.config('oxc', {
        cmd = { 'oxlint', '--lsp' },
        filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
        root_markers = { '.oxlintrc.json' },
        flags = {
          debounce_text_changes = 500,
        },
      })

      -- eslint — only activate when eslint config exists (and no .oxlintrc.json)
      vim.lsp.config('eslint', {
        flags = {
          debounce_text_changes = 500,
        },
        on_attach = function(client, bufnr)
          vim.api.nvim_create_autocmd('BufWritePre', {
            buffer = bufnr,
            callback = function()
              local clients = vim.lsp.get_clients { bufnr = bufnr, name = 'eslint' }
              if #clients == 0 then
                return
              end
              clients[1]:request_sync('workspace/executeCommand', {
                command = 'eslint.applyAllFixes',
                arguments = {
                  {
                    uri = vim.uri_from_bufnr(bufnr),
                    version = vim.lsp.util.buf_versions[bufnr],
                  },
                },
              }, 1000, bufnr)
            end,
          })
        end,
      })

      -- Enable both — each will only attach if its root_markers are found
      vim.lsp.enable 'oxc'
      vim.lsp.enable 'eslint'
      vim.lsp.enable 'tsgo'
      vim.lsp.enable 'prismals'
    end,
  },
}
