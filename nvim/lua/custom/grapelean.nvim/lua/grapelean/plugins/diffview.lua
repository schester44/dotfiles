local colors = require('grapelean.utils').colors
local Group = require('grapelean.utils').Group

Group.new('DiffViewDiffAdd', nil, colors.green_dark, nil)
Group.new('DiffViewDiffDelete', colors.muted_red, colors.cobalt_bg, nil)
Group.new('DiffViewDiffChange', nil, colors.cobalt_bg_light, nil)
Group.new('DiffViewDiffAddAsDelete', nil, colors.light_red_bg, nil)
Group.new('DiffViewDiffText', nil, colors.green_dark, nil)

Group.new('DiffAdd', nil, colors.green_dark, nil)
Group.new('DiffDelete', colors.muted_red, colors.cobalt_bg, nil)
Group.new('DiffChange', nil, colors.cobalt_bg_light, nil)
Group.new('DiffAddAsDelete', nil, colors.light_red_bg, nil)
Group.new('DiffText', nil, colors.green_dark, nil)
