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

          -- Additional useful LSP keymaps
          map('<leader>ci', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }, { bufnr = event.buf })
          end, 'Toggle Inlay Hints')

          map('<leader>cR', function()
            Snacks.picker.lsp_references()
          end, 'Code References')

          map('<leader>cs', function()
            Snacks.picker.lsp_document_symbols()
          end, 'Code Symbols (Document)')

          map('<leader>cS', function()
            Snacks.picker.lsp_workspace_symbols()
          end, 'Code Symbols (Workspace)')

          map('<leader>cc', function()
            vim.lsp.codelens.run()
          end, 'Code Lens')

          map('<leader>cC', function()
            vim.lsp.codelens.refresh()
          end, 'Code Lens Refresh')

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
          'rust_analyzer',
          'gopls',
          'cssls',
          'html',
          'emmet_ls',
        },
        handlers = {
          -- Default handler
          function(server_name)
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = vim.tbl_deep_extend('force', capabilities, require('blink.cmp').get_lsp_capabilities())
            
            require('lspconfig')[server_name].setup {
              capabilities = capabilities,
            }
          end,
          
          -- Specialized handlers
          ['lua_ls'] = function()
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = vim.tbl_deep_extend('force', capabilities, require('blink.cmp').get_lsp_capabilities())
            
            require('lspconfig').lua_ls.setup {
              capabilities = capabilities,
              settings = {
                Lua = {
                  completion = {
                    callSnippet = 'Replace',
                  },
                  diagnostics = {
                    globals = { 'vim' },
                  },
                  workspace = {
                    library = {
                      [vim.fn.expand '$VIMRUNTIME/lua'] = true,
                      [vim.fn.stdpath 'config' .. '/lua'] = true,
                    },
                  },
                },
              },
            }
          end,
          
          ['vtsls'] = function()
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = vim.tbl_deep_extend('force', capabilities, require('blink.cmp').get_lsp_capabilities())
            
            require('lspconfig').vtsls.setup {
              capabilities = capabilities,
              settings = {
                complete_function_calls = true,
                vtsls = {
                  enableMoveToFileCodeAction = true,
                  autoUseWorkspaceTsdk = true,
                  experimental = {
                    completion = {
                      enableServerSideFuzzyMatch = true,
                    },
                  },
                },
                typescript = {
                  updateImportsOnFileMove = { enabled = 'always' },
                  suggest = {
                    completeFunctionCalls = true,
                  },
                  inlayHints = {
                    enumMemberValues = { enabled = true },
                    functionLikeReturnTypes = { enabled = true },
                    parameterNames = { enabled = 'literals' },
                    parameterTypes = { enabled = true },
                    propertyDeclarationTypes = { enabled = true },
                    variableTypes = { enabled = false },
                  },
                },
              },
            }
          end,
          
          ['emmet_ls'] = function()
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = vim.tbl_deep_extend('force', capabilities, require('blink.cmp').get_lsp_capabilities())
            
            require('lspconfig').emmet_ls.setup {
              capabilities = capabilities,
              filetypes = { 'html', 'typescriptreact', 'javascriptreact', 'css', 'sass', 'scss', 'less' },
            }
          end,
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
