local colors = require("graphite.utils").colors
local Group = require("graphite.utils").Group

Group.new("htmlArg", colors.yellow, nil, nil)
Group.new("htmlEndTag", colors.white, nil, nil)
Group.new("htmlSpecialTagName", colors.light_blue, nil, nil)
Group.new("htmlTag", colors.white, nil, nil)
Group.new("htmlTagName", colors.light_blue, nil, nil)
