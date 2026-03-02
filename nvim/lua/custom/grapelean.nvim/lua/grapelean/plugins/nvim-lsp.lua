local colors = require('grapelean.utils').colors
local styles = require('grapelean.utils').styles
local Group = require('grapelean.utils').Group

-- diagnostics

Group.new('DiagnosticError', colors.red_muted, nil, nil)
Group.new('DiagnosticHint', colors.pink_light, nil, nil)
Group.new('DiagnosticInfo', colors.blue_light, nil, nil)
Group.new('DiagnosticWarn', colors.yellow_light, nil, nil)
Group.new('DiagnosticUnnecessary', nil, nil, nil)

Group.new('DiagnosticLineError', nil, nil, nil)
Group.new('DiagnosticLineHint', nil, nil, nil)
Group.new('DiagnosticLineInfo', nil, nil, nil)
Group.new('DiagnosticLineWarn', nil, nil, nil)

Group.new('DiagnosticUnderlineError', nil, nil, styles.undercurl, colors.red_muted)
Group.new('DiagnosticUnderlineHint', nil, nil, styles.undercurl, colors.pink_light)
Group.new('DiagnosticUnderlineInfo', nil, nil, styles.undercurl, colors.blue_light)
Group.new('DiagnosticUnderlineWarn', nil, nil, styles.undercurl, colors.yellow_light)

Group.new('LspDiagnosticsDefaultError', colors.red:light(), nil, nil)
Group.new('LspDiagnosticsDefaultHint', colors.pink_light, nil, nil)
Group.new('LspDiagnosticsDefaultInformation', colors.blue, nil, nil)
Group.new('LspDiagnosticsDefaultWarning', colors.yellow_light, nil, nil)
Group.new('LspDiagnosticsError', colors.red:light(), nil, nil)
Group.new('LspDiagnosticsErrorUnderline', colors.red:light(), nil, styles.underline)
Group.new('LspDiagnosticsHint', colors.pink_light, nil, nil)
Group.new('LspDiagnosticsHintUnderline', colors.pink_light, nil, styles.underline)
Group.new('LspDiagnosticsInformation', colors.blue, nil, nil)
Group.new('LspDiagnosticsInformationUnderline', colors.blue, nil, styles.underline)
Group.new('LspDiagnosticsVirtualTextError', colors.red:light(), nil, nil)
Group.new('LspDiagnosticsVirtualTextHint', colors.pink_light, nil, nil)
Group.new('LspDiagnosticsVirtualTextInformation', colors.blue, nil, nil)
Group.new('LspDiagnosticsVirtualTextWarning', colors.yellow_light, nil, nil)
Group.new('LspDiagnosticsWarning', colors.yellow_light, nil, nil)
Group.new('LspDiagnosticsWarningUnderline', colors.yellow_light, nil, styles.underline)
--
-- codelens
Group.new('LspCodeLens', colors.gray_muted, nil, nil)

local function link(group, target)
  vim.api.nvim_set_hl(0, group, { link = target, default = true })
end

-- These control the appearance of code backgrounds when cursor is on a symbol.
Group.new('LspReferenceRead', nil, colors.bg_lighter, nil)
Group.new('LspReferenceText', nil, colors.bg, nil)
Group.new('LspReferenceWrite', colors.yellow_light, colors.bg_lighter, nil)

-- normal
Group.new('LspFloatWinNormal', colors.yellow, colors.bg_dark, nil)
Group.new('LspSignatureActiveParameter', colors.blue_light, nil, nil)

-- info window
Group.new('LspInfoBorder', colors.blue, nil, nil)

-- inlay hints
Group.new('LspInlayHint', colors.keyword, nil, nil)

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
