local colors = require('grapelean.utils').colors
local Group = require('grapelean.utils').Group

Group.new('BlinkCmpMenuBorder', colors.bg, colors.bg_dark, nil)
Group.new('BlinkCmpDocBorder', colors.bg, colors.bg_dark, nil)
Group.new('BlinkCmpLabelDescription', colors.keyword, nil, nil)
Group.new('BlinkCmpSource', colors.bg_light, nil, nil)

Group.new('BlinkCmpKindBuffer', colors.bg_dark, nil, nil)
Group.new('BlinkCmpKindLSP', colors.pink_light, nil, nil)

Group.new('BlinkCmpKindFunction', colors.pink_light, nil, nil)
Group.new('BlinkCmpKindVariable', colors.green_light, nil, nil)
Group.new('BlinkCmpKindClass', colors.yellow_light, nil, nil)
Group.new('BlinkCmpKindModule', colors.pink_light, nil, nil)
Group.new('BlinkCmpKindInterface', colors.yellow_light, nil, nil)
Group.new('BlinkCmpKindKeyword', colors.pink, nil, nil)
Group.new('BlinkCmpKindEnum', colors.green, nil, nil)
Group.new('BlinkCmpKindStruct', colors.green, nil, nil)
Group.new('BlinkCmpKindProperty', colors.green_light, nil, nil)
Group.new('BlinkCmpKindSnippet', colors.purple, nil, nil)
Group.new('BlinkCmpKindField', colors.blue_light, nil, nil)
Group.new('BlinkCmpKindFile', colors.gray_light, nil, nil)
Group.new('BlinkCmpKindText', colors.white, nil, nil)
