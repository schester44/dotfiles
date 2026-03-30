local hl = require('grapelean.utils').hl
local pal = require 'grapelean.palette'
local p = pal.palette
local s = pal.semantic
local lighten = require('grapelean.color').lighten

-- diagnostics
hl('DiagnosticError', { fg = s.error })
hl('DiagnosticHint', { fg = s.hint })
hl('DiagnosticInfo', { fg = s.info })
hl('DiagnosticWarn', { fg = s.warning })
hl('DiagnosticUnnecessary', {})

hl('DiagnosticLineError', {})
hl('DiagnosticLineHint', {})
hl('DiagnosticLineInfo', {})
hl('DiagnosticLineWarn', {})

hl('DiagnosticUnderlineError', { undercurl = true, sp = s.error })
hl('DiagnosticUnderlineHint', { undercurl = true, sp = s.hint })
hl('DiagnosticUnderlineInfo', { undercurl = true, sp = s.info })
hl('DiagnosticUnderlineWarn', { undercurl = true, sp = s.warning })

hl('LspDiagnosticsDefaultError', { fg = lighten(p.red) })
hl('LspDiagnosticsDefaultHint', { fg = s.hint })
hl('LspDiagnosticsDefaultInformation', { fg = p.blue })
hl('LspDiagnosticsDefaultWarning', { fg = s.warning })
hl('LspDiagnosticsError', { fg = lighten(p.red) })
hl('LspDiagnosticsErrorUnderline', { fg = lighten(p.red), underline = true })
hl('LspDiagnosticsHint', { fg = s.hint })
hl('LspDiagnosticsHintUnderline', { fg = s.hint, underline = true })
hl('LspDiagnosticsInformation', { fg = p.blue })
hl('LspDiagnosticsInformationUnderline', { fg = p.blue, underline = true })
hl('LspDiagnosticsVirtualTextError', { fg = lighten(p.red) })
hl('LspDiagnosticsVirtualTextHint', { fg = s.hint })
hl('LspDiagnosticsVirtualTextInformation', { fg = p.blue })
hl('LspDiagnosticsVirtualTextWarning', { fg = s.warning })
hl('LspDiagnosticsWarning', { fg = s.warning })
hl('LspDiagnosticsWarningUnderline', { fg = s.warning, underline = true })

-- codelens
hl('LspCodeLens', { fg = s.comment })

-- These control the appearance of code backgrounds when cursor is on a symbol.
-- NOTE: LspReferenceText uses p.bg_muted (not p.bg) for visibility.
hl('LspReferenceRead', { bg = p.bg_lighter })
hl('LspReferenceText', { bg = p.bg_muted })
hl('LspReferenceWrite', { fg = s.warning, bg = p.bg_lighter })

-- normal
hl('LspFloatWinNormal', { fg = p.yellow, bg = s.bg_float })
hl('LspSignatureActiveParameter', { fg = s.info })

-- info window
hl('LspInfoBorder', { fg = p.blue })

-- inlay hints
hl('LspInlayHint', { fg = s.keyword })

--------------------------------------------------------------------------------
--  nvim-0.9 changes
--------------------------------------------------------------------------------
local lsp_links = {
  ['@lsp.type.namespace'] = '@namespace',
  ['@lsp.type.type'] = '@type',
  ['@lsp.type.class'] = '@type',
  ['@lsp.type.enum'] = '@type',
  ['@lsp.type.interface'] = '@type',
  ['@lsp.type.struct'] = '@structure',
  ['@lsp.type.parameter'] = '@parameter',
  ['@lsp.type.variable'] = '@variable',
  ['@lsp.type.property'] = '@property',
  ['@lsp.type.enumMember'] = '@constant',
  ['@lsp.type.function'] = '@function',
  ['@lsp.type.method'] = '@method',
  ['@lsp.type.macro'] = '@macro',
  ['@lsp.type.decorator'] = '@function',
}
for newgroup, oldgroup in pairs(lsp_links) do
  vim.api.nvim_set_hl(0, newgroup, { link = oldgroup, default = true })
end
