local colors = require("graphite.utils").colors
local styles = require("graphite.utils").styles
local Group = require("graphite.utils").Group

Group.new("jsonBoolean", colors.dark_pink, nil, styles.italic)
Group.new("jsonEscape", colors.yellow, nil, nil)
Group.new("jsonKeyword", colors.yellow, nil, nil)
Group.new("jsonNull", colors.dark_pink, nil, styles.italic)
