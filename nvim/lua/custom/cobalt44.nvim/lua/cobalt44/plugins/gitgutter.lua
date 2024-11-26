local colors = require("cobalt44.utils").colors
local Group = require("cobalt44.utils").Group

Group.new("GitGutterAdd", colors.green, nil, nil)
Group.new("GitGutterChange", colors.yellow, nil, nil)
Group.new("GitGutterDelete", colors.red, nil, nil)
