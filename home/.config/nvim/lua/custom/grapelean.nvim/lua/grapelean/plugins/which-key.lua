local hl  = require('grapelean.utils').hl
local pal = require 'grapelean.palette'
local p   = pal.palette
local s   = pal.semantic

hl('whichkey',        { fg = p.pink })
hl('WhichKeyTitle',   { fg = p.pink_light })
hl('WhichKeyDesc',    { fg = p.yellow })
hl('WhichKeyFloat',   { fg = p.blue })
hl('WhichKeyGroup',   { fg = p.gray_light })
hl('WhichKeySeparator',{ fg = s.keyword })
hl('WhichKeyValue',   { fg = s.bg_selection })
