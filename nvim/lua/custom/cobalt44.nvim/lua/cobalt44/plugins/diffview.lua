local colors = require('cobalt44.utils').colors
local Group = require('cobalt44.utils').Group

Group.new('DiffViewDiffAdd', nil, colors.darkest_green, nil)
Group.new('DiffViewDiffDelete', colors.muted_red, colors.cobalt_bg, nil)
Group.new('DiffViewDiffChange', nil, colors.cobalt_bg_light, nil)
Group.new('DiffViewDiffAddAsDelete', nil, colors.light_red_bg, nil)
Group.new('DiffViewDiffText', nil, colors.darkest_green, nil)

Group.new('DiffAdd', nil, colors.darkest_green, nil)
Group.new('DiffDelete', colors.muted_red, colors.cobalt_bg, nil)
Group.new('DiffChange', nil, colors.cobalt_bg_light, nil)
Group.new('DiffAddAsDelete', nil, colors.light_red_bg, nil)
Group.new('DiffText', nil, colors.darkest_green, nil)
