local hl  = require('grapelean.utils').hl
local pal = require 'grapelean.palette'
local p   = pal.palette

hl('jsonBoolean', { fg = p.pink, italic = true })
hl('jsonEscape',  { fg = p.yellow })
hl('jsonKeyword', { fg = p.yellow })
hl('jsonNull',    { fg = p.pink, italic = true })
