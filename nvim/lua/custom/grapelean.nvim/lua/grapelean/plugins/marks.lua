local colors = require("grapelean.utils").colors
local Group = require("grapelean.utils").Group
local styles = require("grapelean.utils").styles

Group.new("MarkSignHL", colors.dark_pink, nil, styles.italic)
Group.new("MarkSignNumHL", colors.light_blue, nil, nil)
Group.new("MarkVirtTextHL", colors.light_grey:dark(), nil, nil)
