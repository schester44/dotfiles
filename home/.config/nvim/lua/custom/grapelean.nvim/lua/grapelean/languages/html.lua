local hl  = require('grapelean.utils').hl
local pal = require 'grapelean.palette'
local p   = pal.palette
local s   = pal.semantic

hl('htmlArg',           { fg = s.tag_attribute })
hl('htmlEndTag',        { fg = s.tag_delimiter })
hl('htmlSpecialTagName',{ fg = p.blue_light })
hl('htmlTag',           { fg = s.tag_delimiter })
hl('htmlTagName',       { fg = p.blue_light })
