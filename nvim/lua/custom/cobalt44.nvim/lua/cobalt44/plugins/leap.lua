local colors = require("cobalt44.utils").colors
local styles = require("cobalt44.utils").styles
local Group = require("cobalt44.utils").Group

Group.new("LeapBackdrop", colors.dark_grey, nil, nil)
Group.new("LeapLabelPrimary", colors.pink, nil, styles.italic)
Group.new("LeapLabelSecondary", colors.red, nil, styles.underline)
Group.new("LeapMatch", colors.dark_pink, nil, nil)
