local colors = require('cobalt44.utils').colors
local styles = require('cobalt44.utils').styles
local Group = require('cobalt44.utils').Group

-- diagnostics

Group.new('DiagnosticError', colors.muted_red, nil, nil)
Group.new('DiagnosticHint', colors.light_pink, nil, nil)
Group.new('DiagnosticInfo', colors.light_blue, nil, nil)
Group.new('DiagnosticWarn', colors.light_yellow, nil, nil)
Group.new('DiagnosticUnnecessary', nil, nil, nil)

Group.new('DiagnosticLineError', nil, nil, nil)
Group.new('DiagnosticLineHint', nil, nil, nil)
Group.new('DiagnosticLineInfo', nil, nil, nil)
Group.new('DiagnosticLineWarn', nil, nil, nil)

Group.new('DiagnosticUnderlineError', nil, nil, styles.undercurl, colors.muted_red)
Group.new('DiagnosticUnderlineHint', nil, nil, styles.undercurl, colors.light_pink)
Group.new('DiagnosticUnderlineInfo', nil, nil, styles.undercurl, colors.light_blue)
Group.new('DiagnosticUnderlineWarn', nil, nil, styles.undercurl, colors.light_yellow)

Group.new('LspDiagnosticsDefaultError', colors.red:light(), nil, nil)
Group.new('LspDiagnosticsDefaultHint', colors.light_pink, nil, nil)
Group.new('LspDiagnosticsDefaultInformation', colors.blue, nil, nil)
Group.new('LspDiagnosticsDefaultWarning', colors.light_yellow, nil, nil)
Group.new('LspDiagnosticsError', colors.red:light(), nil, nil)
Group.new('LspDiagnosticsErrorUnderline', colors.red:light(), nil, styles.underline)
Group.new('LspDiagnosticsHint', colors.light_pink, nil, nil)
Group.new('LspDiagnosticsHintUnderline', colors.light_pink, nil, styles.underline)
Group.new('LspDiagnosticsInformation', colors.blue, nil, nil)
Group.new('LspDiagnosticsInformationUnderline', colors.blue, nil, styles.underline)
Group.new('LspDiagnosticsVirtualTextError', colors.red:light(), nil, nil)
Group.new('LspDiagnosticsVirtualTextHint', colors.light_pink, nil, nil)
Group.new('LspDiagnosticsVirtualTextInformation', colors.blue, nil, nil)
Group.new('LspDiagnosticsVirtualTextWarning', colors.light_yellow, nil, nil)
Group.new('LspDiagnosticsWarning', colors.light_yellow, nil, nil)
Group.new('LspDiagnosticsWarningUnderline', colors.light_yellow, nil, styles.underline)
--
-- codelens
Group.new('LspCodeLens', colors.dark_grey, nil, nil)

-- These control the appearance of code backgrounds when cursor is on a symbol.
Group.new('LspReferenceRead', nil, colors.cobalt_bg_lighter, nil)
Group.new('LspReferenceText', nil, colors.cobalt_bg_lighter, nil)
Group.new('LspReferenceWrite', nil, colors.cobalt_bg_lighter, nil)

-- normal
Group.new('LspFloatWinNormal', colors.yellow, colors.cobalt_bg_dark, nil)
Group.new('LspSignatureActiveParameter', colors.light_blue, nil, nil)

-- info window
Group.new('LspInfoBorder', colors.blue, nil, nil)

-- inlay hints
Group.new('LspInlayHint', colors.dim_blue, nil, nil)

--------------------------------------------------------------------------------
--  nvim-0.9 changes
--------------------------------------------------------------------------------
local links = {
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
for newgroup, oldgroup in pairs(links) do
  vim.api.nvim_set_hl(0, newgroup, {
    link = oldgroup,
    default = true,
  })
end
