local colors = require("grapelean.utils").colors
local Group = require("grapelean.utils").Group
local styles = require("grapelean.utils").styles

Group.new("FidgetTask", colors.blue, colors.bg, nil)
Group.new("FidgetTitle", colors.yellow, colors.bg, styles.bold)
