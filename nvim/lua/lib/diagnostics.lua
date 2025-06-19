local icons = require 'lib.icons'
local diag_icons = icons.diagnostics

local S = vim.diagnostic.severity

local lsp_signs = {
  [S.ERROR] = { name = 'Error', sym = diag_icons.error },
  [S.WARN] = { name = 'Warn', sym = diag_icons.warn },
  [S.INFO] = { name = 'Info', sym = diag_icons.info },
  [S.HINT] = { name = 'Hint', sym = diag_icons.hint },
}

local M = {
  linehl = {
    [vim.diagnostic.severity.ERROR] = 'DiagnosticLineError',
    [vim.diagnostic.severity.WARN] = 'DiagnosticLineWarn',
    [vim.diagnostic.severity.INFO] = 'DiagnosticLineInfo',
    [vim.diagnostic.severity.HINT] = 'DiagnosticLineHint',
  },
  texthl = {
    [vim.diagnostic.severity.ERROR] = 'DiagnosticError',
    [vim.diagnostic.severity.WARN] = 'DiagnosticWarn',
    [vim.diagnostic.severity.INFO] = 'DiagnosticInfo',
    [vim.diagnostic.severity.HINT] = 'DiagnosticHint',
  },
  text = {
    [vim.diagnostic.severity.ERROR] = diag_icons.error,
    [vim.diagnostic.severity.WARN] = diag_icons.warn,
    [vim.diagnostic.severity.INFO] = diag_icons.info,
    [vim.diagnostic.severity.HINT] = diag_icons.hint,
  },
  lsp_signs = lsp_signs,
}

return M
