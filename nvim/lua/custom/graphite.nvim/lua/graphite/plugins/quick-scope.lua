local Group = require("graphite/utils").Group
local colors = require("graphite/utils").colors

Group.new("QuickScopePrimary", colors.pink, colors.black, nil)
Group.new("QuickScopeSecondary", colors.red, colors.black, nil)
