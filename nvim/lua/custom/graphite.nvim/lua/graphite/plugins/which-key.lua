local colors = require('graphite.utils').colors
local Group = require('graphite.utils').Group

Group.new('whichkey', colors.dark_pink, nil, nil)
Group.new('WhichKeyTitle', colors.light_pink, nil, nil)
Group.new('WhichKeyDesc', colors.yellow, nil, nil)
Group.new('WhichKeyFloat', colors.blue, nil, nil)
Group.new('WhichKeyGroup', colors.lighter_grey, nil, nil)
Group.new('WhichKeySeparator', colors.keyword, nil, nil)
Group.new('WhichKeyValue', colors.cursor_hover, nil, nil)
