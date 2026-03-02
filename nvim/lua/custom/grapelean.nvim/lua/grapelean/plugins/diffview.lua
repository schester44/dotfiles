local colors = require('grapelean.utils').colors
local Group = require('grapelean.utils').Group

Group.new('DiffViewDiffAdd', nil, colors.green_dark, nil)
Group.new('DiffViewDiffDelete', colors.red_muted, colors.bg, nil)
Group.new('DiffViewDiffChange', nil, colors.bg_light, nil)
Group.new('DiffViewDiffAddAsDelete', nil, colors.red_light_bg, nil)
Group.new('DiffViewDiffText', nil, colors.green_dark, nil)

Group.new('DiffAdd', nil, colors.green_dark, nil)
Group.new('DiffDelete', colors.red_muted, colors.bg, nil)
Group.new('DiffChange', nil, colors.bg_light, nil)
Group.new('DiffAddAsDelete', nil, colors.red_light_bg, nil)
Group.new('DiffText', nil, colors.green_dark, nil)
