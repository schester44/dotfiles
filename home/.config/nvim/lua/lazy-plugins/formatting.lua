return {
  'stevearc/conform.nvim',
  cond = not vim.g.vscode,
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      'grf',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = 'Format file or range',
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- Disable "format_on_save lsp_fallback" for languages that don't
      -- have a well standardized coding style. You can add additional
      -- languages here or re-enable it for the disabled ones.
      local disable_filetypes = { c = true, cpp = true }
      local lsp_format_opt
      if disable_filetypes[vim.bo[bufnr].filetype] then
        lsp_format_opt = 'never'
      else
        lsp_format_opt = 'fallback'
      end
      return {
        timeout_ms = 500,
        lsp_format = lsp_format_opt,
      }
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
      javascript = { 'oxfmt', 'prettier', stop_after_first = true },
      typescript = { 'oxfmt', 'prettier', stop_after_first = true },
      javascriptreact = { 'oxfmt', 'prettier', stop_after_first = true },
      typescriptreact = { 'oxfmt', 'prettier', stop_after_first = true },
      css = { 'prettier' },
      html = { 'prettier' },
      json = { 'oxfmt', 'prettier', stop_after_first = true },
      yaml = { 'prettier' },
      markdown = { 'prettier' },
      graphql = { 'prettier' },
    },
    formatters = {
      oxfmt = {
        command = 'npx',
        args = { 'oxfmt', '--stdin-filepath', '$FILENAME' },
        stdin = true,
        -- Only available when .oxfmtrc.json exists in the project
        condition = function(_, ctx)
          return vim.fs.find('.oxfmtrc.json', { path = ctx.dirname, upward = true })[1] ~= nil
        end,
      },
    },
  },
}
