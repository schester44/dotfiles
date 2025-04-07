local colors = require('cobalt44.utils').colors
local Group = require('cobalt44.utils').Group

Group.new('DiffViewDiffAdd', nil, colors.darkest_green, nil)
Group.new('DiffViewDiffDelete', colors.dim_blue, colors.cobalt_bg, nil)
Group.new('DiffViewDiffChange', nil, colors.light_green_bg, nil)
Group.new('DiffViewDiffAddAsDelete', nil, colors.light_red_bg, nil)
Group.new('DiffViewDiffText', nil, colors.darkest_green, nil)
