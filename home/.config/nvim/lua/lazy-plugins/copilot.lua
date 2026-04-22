return {
  {
    'zbirenbaum/copilot.lua',
    event = 'InsertEnter',
    cond = not vim.g.vscode,
    config = function()
      local palette = require 'grapelean.palette'

      vim.api.nvim_set_hl(0, 'CopilotSuggestion', { fg = palette.gray, bg = nil })
      vim.api.nvim_set_hl(0, 'CopilotAnnotation', { fg = palette.gray, bg = nil })

      require('copilot').setup {
        suggestion = { enabled = true, auto_trigger = true },
        panel = { enabled = true, keymap = {
          open = '<M-0>',
        } },
      }

      -- Copilot's LSP registers workspace/didChangeWatchedFiles, which causes
      -- neovim to create recursive FSEvents watchers on the entire workspace.
      -- In large repos (e.g. 489 dirs), this opens ~4,800+ directory FDs.
      -- Copilot doesn't need file watching for completions, so disable it.
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == 'copilot' then
            client.capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false
          end
        end,
      })
    end,
  },
}
