local hl  = require('grapelean.utils').hl
local pal = require 'grapelean.palette'
local p   = pal.palette
local s   = pal.semantic

hl('BlinkCmpMenu',             { fg = s.fg,        bg = s.bg_float })
hl('BlinkCmpMenuBorder',       { fg = s.bg_float,  bg = s.bg_float })
hl('BlinkCmpDoc',              { fg = s.fg,        bg = s.bg_float })
hl('BlinkCmpDocBorder',        { fg = s.bg_float,  bg = s.bg_float })
hl('BlinkCmpLabelDescription', { fg = s.keyword })
hl('BlinkCmpSource',           { fg = p.bg_light })

hl('BlinkCmpKindBuffer',    { fg = p.bg_dark })
hl('BlinkCmpKindLSP',       { fg = p.pink_light })

hl('BlinkCmpKindFunction',  { fg = p.pink_light })
hl('BlinkCmpKindVariable',  { fg = p.green_light })
hl('BlinkCmpKindClass',     { fg = p.yellow_light })
hl('BlinkCmpKindModule',    { fg = p.pink_light })
hl('BlinkCmpKindInterface', { fg = p.yellow_light })
hl('BlinkCmpKindKeyword',   { fg = p.pink })
hl('BlinkCmpKindEnum',      { fg = p.green })
hl('BlinkCmpKindStruct',    { fg = p.green })
hl('BlinkCmpKindProperty',  { fg = p.green_light })
hl('BlinkCmpKindSnippet',   { fg = p.purple })
hl('BlinkCmpKindField',     { fg = p.blue_light })
hl('BlinkCmpKindFile',      { fg = p.gray_light })
hl('BlinkCmpKindText',      { fg = p.white })
