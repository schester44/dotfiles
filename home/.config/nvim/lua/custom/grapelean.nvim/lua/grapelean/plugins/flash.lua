local hl  = require('grapelean.utils').hl
local pal = require 'grapelean.palette'
local p   = pal.palette

hl('FlashBackdrop', { fg = p.gray_light, bg = p.bg, italic = true })
hl('FlashMatch',    { fg = p.black, bg = p.yellow })
hl('FlashCurrent',  { fg = p.black, bg = p.yellow })
hl('FlashLabel',    { fg = p.white, bg = p.pink })
