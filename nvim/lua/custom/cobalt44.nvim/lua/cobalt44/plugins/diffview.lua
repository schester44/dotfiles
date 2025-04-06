local colors = require('cobalt44.utils').colors
local Group = require('cobalt44.utils').Group

Group.new('DiffViewDiffAdd', nil, colors.darkest_green, nil)
Group.new('DiffViewDiffDelete', colors.cobalt_bg_light, colors.cobalt_bg, nil)

-- Group.new("DiffviewDiffAddAsDelete", colors.red, nil, nil)
-- Group.new("DiffviewDiffDelete", colors.red, nil, nil)
-- Group.new("DiffviewStatusIgnored", colors.white, nil, nil)
