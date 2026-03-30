local hl  = require('grapelean.utils').hl
local pal = require 'grapelean.palette'
local p   = pal.palette
local s   = pal.semantic

-- Mini Notify
hl('MiniNotifyNormal',      { fg = s.fg,      bg = s.bg_float })
hl('MiniNotifyBorder',      { fg = s.bg_float, bg = s.bg_float })
hl('MiniNotifyTitle',       { fg = p.purple,  bg = s.bg_float })
hl('MiniNotifyLspProgress', { fg = p.gray_light, bg = s.bg_float })
