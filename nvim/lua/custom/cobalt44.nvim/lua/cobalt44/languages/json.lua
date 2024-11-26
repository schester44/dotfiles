local colors = require("cobalt44.utils").colors
local styles = require("cobalt44.utils").styles
local Group = require("cobalt44.utils").Group

Group.new("jsonBoolean", colors.dark_pink, nil, styles.italic)
Group.new("jsonEscape", colors.yellow, nil, nil)
Group.new("jsonKeyword", colors.yellow, nil, nil)
Group.new("jsonNull", colors.dark_pink, nil, styles.italic)
