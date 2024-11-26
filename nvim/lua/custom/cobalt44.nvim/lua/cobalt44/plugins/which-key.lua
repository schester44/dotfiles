local colors = require("cobalt44.utils").colors
local styles = require("cobalt44.utils").styles
local Group = require("cobalt44.utils").Group

Group.new("WhichKey", colors.dark_pink, nil, nil)
Group.new("WhichKeyDesc", colors.yellow, nil, nil)
Group.new("WhichKeyFloat", colors.blue, nil, nil)
Group.new("WhichKeyGroup", colors.blue, nil, styles.italic)
Group.new("WhichKeySeparator", colors.green, nil, nil)
Group.new("WhichKeyValue", colors.cursor_hover, nil, nil)
