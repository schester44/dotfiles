local hl  = require('grapelean.utils').hl
local pal = require 'grapelean.palette'
local p   = pal.palette
local s   = pal.semantic
local lighten = require('grapelean.color').lighten

--- REF: https://neovim.io/doc/user/treesitter.html#_treesitter-trees

--------------------------------------------------------------------------------
--  misc
--------------------------------------------------------------------------------
hl('@annotation', { fg = p.gray, italic = true })
hl('@error',      { fg = s.error })
hl('@operator',   { fg = s.operator })
hl('@structure',  { fg = p.gray, italic = true })

--------------------------------------------------------------------------------
--  literals
--------------------------------------------------------------------------------
hl('@string',         { fg = s.string })
hl('@string.escape',  { fg = s.escape })
hl('@string.regex',   { fg = s.escape })
hl('@string.special', { fg = s.escape, italic = true })

hl('@character',         { fg = s.string })
hl('@character.special', { fg = s.escape })

hl('@number',  { fg = s.number })
hl('@float',   { fg = s.number })
hl('@boolean', { fg = s.boolean })

--------------------------------------------------------------------------------
--  functions
--------------------------------------------------------------------------------
hl('@function',         { fg = s.func })
hl('@function.call',    { fg = s.func })
hl('@function.builtin', { fg = s.builtin_function })
hl('@function.macro',   { fg = s.func })

hl('@method',      { fg = s.func })
hl('@method.call', { fg = s.func })

hl('@constructor',          { fg = s.constructor })
hl('@parameter',            { fg = s.parameter })
hl('@parameter.reference',  { fg = s.parameter })

--------------------------------------------------------------------------------
--  keywords
--------------------------------------------------------------------------------
hl('@keyword',              { fg = s.keyword })
hl('@keyword.import',       { fg = s.include })
hl('@keyword.function',     { fg = s.keyword_function })
hl('@keyword.operator',     { fg = s.keyword_operator })
hl('@keyword.return',       { fg = s.keyword_return })
hl('@keyword.coroutine',    { fg = s.keyword_coroutine })
hl('@keyword.exception',    { fg = s.exception })
hl('@keyword.conditional',  { fg = s.conditional })

hl('@conditional', { fg = s.conditional })
hl('@repeat',      { fg = s.loop })
hl('@debug',       { fg = p.gray })
hl('@label',       { fg = s.label })
hl('@include',     { fg = s.include })
hl('@exception',   { fg = s.exception })

hl('@lsp.type.type',  { fg = s.type })
hl('@lsp.type.enum',  { fg = s.type })
hl('@lsp.type.class', { fg = s.type })

--------------------------------------------------------------------------------
--  types
--------------------------------------------------------------------------------
hl('@type',         { fg = s.fg })
hl('@type.builtin', { fg = s.builtin_type })

hl('@attribute', { fg = p.gray, italic = true })
hl('@field',     { fg = s.property })
hl('@property',  { fg = s.property })

--------------------------------------------------------------------------------
--  identifiers
--------------------------------------------------------------------------------
hl('@variable',         { fg = s.variable })
hl('@variable.builtin', { fg = s.variable })

hl('@constant',         { fg = s.fg })
hl('@constant.builtin', { fg = s.builtin_constant, italic = true })
hl('@constant.macro',   { fg = s.escape })

hl('@namespace', { fg = s.module })
hl('@symbol',    { fg = s.variable })
hl('@module',    { fg = s.module })

--------------------------------------------------------------------------------
--  punctuations
--------------------------------------------------------------------------------
hl('@punctuation.bracket',   { fg = s.fg })
hl('@punctuation.delimiter', { fg = s.operator })
hl('@punctuation.special',   { fg = s.operator })

--------------------------------------------------------------------------------
--  tags
--------------------------------------------------------------------------------
hl('@tag',           { fg = s.tag })
hl('@tag.builtin',   { fg = s.tag_builtin })
hl('@tag.attribute', { fg = s.tag_attribute, italic = true })
hl('@tag.delimiter', { fg = s.tag_delimiter })

--------------------------------------------------------------------------------
--  text
--------------------------------------------------------------------------------
hl('@text',            { fg = s.fg })
hl('@text.strong',     { fg = s.fg, bold = true })
hl('@text.strike',     { fg = s.fg, strikethrough = true })
hl('@text.emphasis',   { fg = s.fg, italic = true })
hl('@text.underline',  { fg = s.fg, underline = true })
hl('@text.uri',        { fg = p.blue_light, underline = true })
hl('@text.todo',       { fg = s.accent, bold = true })
hl('@text.note',       { fg = p.green_muted, bold = true })
hl('@text.warning',    { fg = s.warning, bold = true })
hl('@text.danger',     { fg = lighten(p.red), bold = true })
hl('@text.diff.add',   { fg = s.added })
hl('@text.diff.delete',{ fg = s.removed })

-- markdown
hl('@text.title',   { fg = p.pink, bold = true })
hl('@text.title.1', { fg = p.yellow, bold = true })
hl('@text.title.2', { fg = p.pink, bold = true })
hl('@text.literal', { fg = s.string })
hl('@text.reference',{ fg = p.blue })

--------------------------------------------------------------------------------
--  treesitter-context
--------------------------------------------------------------------------------
hl('TreesitterContext',            { bg = p.bg_muted })
hl('TreesitterContextLineNumber',  { fg = p.gray, bg = p.bg_muted })
hl('TreesitterContextSeparator',   { bg = p.bg_muted })
hl('TreesitterContextBottom',      { bg = p.bg_muted })
