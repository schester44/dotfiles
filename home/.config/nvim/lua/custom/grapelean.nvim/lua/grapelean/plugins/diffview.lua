local hl  = require('grapelean.utils').hl
local pal = require 'grapelean.palette'
local p   = pal.palette

hl('DiffViewDiffAdd',        { bg = p.green_bg })
hl('DiffViewDiffDelete',     { fg = p.red_muted, bg = p.bg })
hl('DiffViewDiffChange',     { bg = p.bg_light })
hl('DiffViewDiffAddAsDelete',{ bg = p.red_light_bg })
hl('DiffViewDiffText',       { bg = p.green_bg_emphasis })

hl('DiffAdd',        { bg = p.green_bg })
hl('DiffDelete',     { fg = p.red_muted, bg = p.bg })
hl('DiffChange',     { bg = p.bg_light })
hl('DiffAddAsDelete',{ bg = p.red_light_bg })
hl('DiffText',       { bg = p.green_bg_emphasis })
