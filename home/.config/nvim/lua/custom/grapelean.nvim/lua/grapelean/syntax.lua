local hl  = require('grapelean.utils').hl
local pal = require 'grapelean.palette'
local p   = pal.palette
local s   = pal.semantic

hl('Type',           { fg = s.type })
hl('StorageClass',   { fg = s.keyword })
hl('Structure',      { fg = s.keyword })

-- Comment controls copilot suggestions
hl('Comment',        { fg = s.comment, italic = true })

hl('Conditional',    { fg = s.conditional })
hl('Constant',       { fg = s.fg })
hl('Character',      { fg = s.string })
hl('Number',         { fg = s.number })
hl('Boolean',        { fg = s.boolean })
hl('Float',          { fg = s.number })
hl('Function',       { fg = s.func })
hl('Identifier',     { fg = s.fg })
hl('Statement',      { fg = s.keyword })
hl('Keyword',        { fg = s.keyword })
hl('Label',          { fg = s.label })
hl('Operator',       { fg = p.gray })
hl('Exception',      { fg = s.exception })
hl('PreProc',        { fg = s.keyword })
hl('Include',        { fg = s.include })
hl('Define',         { fg = s.keyword })
hl('Macro',          { fg = s.macro })
hl('Typedef',        { fg = s.type })
hl('PreCondit',      { fg = s.keyword })
hl('Repeat',         { fg = s.loop })
hl('String',         { fg = s.string })
hl('Special',        { fg = s.special })
hl('SpecialChar',    { fg = s.special })
hl('Tag',            { fg = s.special })
hl('Delimiter',      { fg = s.delimiter })
hl('SpecialComment', { fg = s.keyword })
hl('Debug',          { fg = p.gray, italic = true })
hl('Underlined',     { fg = p.blue, underline = true })
hl('Ignore',         { fg = p.gray_muted, italic = true })
hl('Error',          { fg = s.error })
hl('Todo',           { fg = p.yellow_light, bold = true })
