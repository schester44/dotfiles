local colors = require("graphite.utils").colors
local Group = require("graphite.utils").Group
local styles = require("graphite.utils").styles

Group.new("MarkSignHL", colors.dark_pink, nil, styles.italic)
Group.new("MarkSignNumHL", colors.light_blue, nil, nil)
Group.new("MarkVirtTextHL", colors.light_grey:dark(), nil, nil)
