local colors = require("grapelean.utils").colors
local Group = require("grapelean.utils").Group
local styles = require("grapelean.utils").styles

Group.new("MarkSignHL", colors.pink, nil, styles.italic)
Group.new("MarkSignNumHL", colors.blue_light, nil, nil)
Group.new("MarkVirtTextHL", colors.gray_light:dark(), nil, nil)
