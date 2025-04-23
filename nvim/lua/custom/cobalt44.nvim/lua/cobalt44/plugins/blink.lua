local colors = require('cobalt44.utils').colors
local Group = require('cobalt44.utils').Group

Group.new('BlinkCmpMenuBorder', colors.cobalt_bg, colors.cobalt_bg_dark, nil)
Group.new('BlinkCmpDocBorder', colors.cobalt_bg, colors.cobalt_bg_dark, nil)
Group.new('BlinkCmpLabelDescription', colors.dim_blue, nil, nil)
Group.new('BlinkCmpSource', colors.cobalt_bg_light, nil, nil)

Group.new('BlinkCmpKindBuffer', colors.cobalt_bg_dark, nil, nil)
Group.new('BlinkCmpKindLSP', colors.light_pink, nil, nil)

Group.new('BlinkCmpKindFunction', colors.light_pink, nil, nil)
Group.new('BlinkCmpKindVariable', colors.light_blue_green, nil, nil)
Group.new('BlinkCmpKindClass', colors.light_yellow, nil, nil)
Group.new('BlinkCmpKindModule', colors.light_pink, nil, nil)
Group.new('BlinkCmpKindInterface', colors.light_orange, nil, nil)
Group.new('BlinkCmpKindKeyword', colors.dark_pink, nil, nil)
Group.new('BlinkCmpKindEnum', colors.light_green, nil, nil)
Group.new('BlinkCmpKindStruct', colors.light_green, nil, nil)
Group.new('BlinkCmpKindProperty', colors.light_blue_green, nil, nil)
Group.new('BlinkCmpKindSnippet', colors.purple, nil, nil)
Group.new('BlinkCmpKindField', colors.light_blue, nil, nil)
Group.new('BlinkCmpKindFile', colors.light_grey, nil, nil)
