local colors = require("graphite.utils").colors
local Group = require("graphite.utils").Group
local styles = require("graphite.utils").styles

Group.new("FidgetTask", colors.blue, colors.cobalt_bg, nil)
Group.new("FidgetTitle", colors.yellow, colors.cobalt_bg, styles.bold)
