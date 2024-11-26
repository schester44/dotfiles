local colors = require("cobalt44.utils").colors
local Group = require("cobalt44.utils").Group
local styles = require("cobalt44.utils").styles

Group.new("MarkSignHL", colors.dark_pink, nil, styles.italic)
Group.new("MarkSignNumHL", colors.light_blue, nil, nil)
Group.new("MarkVirtTextHL", colors.light_grey:dark(), nil, nil)
