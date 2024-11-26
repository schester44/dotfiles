local colors = require("cobalt44.utils").colors
local Group = require("cobalt44.utils").Group
local styles = require("cobalt44.utils").styles

Group.new("LirDir", colors.blue, nil, styles.bold)
Group.new("LirEmptyDirText", colors.light_grey, nil, nil)
Group.new("LirFloatBorder", colors.blue, nil, styles.bold)
Group.new("LirFloatCurdirWindowDirName", colors.blue, nil, styles.italic)
Group.new("LirFloatCurdirWindowNormal", colors.white, colors.cursor_hover, nil)
Group.new("LirFloatNormal", colors.white, nil, nil)
Group.new("LirSymLink", colors.pink, nil, nil)
