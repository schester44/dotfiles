local hl  = require('grapelean.utils').hl
local pal = require 'grapelean.palette'
local p   = pal.palette
local s   = pal.semantic

hl('AvantePromptInput', { bg = s.bg_float })
hl('AvanteInlineHint',  { fg = s.keyword, italic = true })
