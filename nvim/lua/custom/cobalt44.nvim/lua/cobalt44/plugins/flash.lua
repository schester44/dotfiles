local utils = require("cobalt44.utils")

local Group, colors, styles = utils.Group, utils.colors, utils.styles

Group.new("FlashBackdrop", colors.light_grey, colors.bg, styles.italic)
Group.new("FlashMatch", colors.black, colors.yellow, nil)
Group.new("FlashCurrent", colors.black, colors.yellow, nil)
Group.new("FlashLabel", colors.white, colors.pink, nil)
