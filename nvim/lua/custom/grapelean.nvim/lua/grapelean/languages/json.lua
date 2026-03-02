local colors = require("grapelean.utils").colors
local styles = require("grapelean.utils").styles
local Group = require("grapelean.utils").Group

Group.new("jsonBoolean", colors.pink, nil, styles.italic)
Group.new("jsonEscape", colors.yellow, nil, nil)
Group.new("jsonKeyword", colors.yellow, nil, nil)
Group.new("jsonNull", colors.pink, nil, styles.italic)
