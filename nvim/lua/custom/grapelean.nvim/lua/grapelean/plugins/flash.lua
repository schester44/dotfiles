local utils = require("grapelean.utils")

local Group, colors, styles = utils.Group, utils.colors, utils.styles

Group.new("FlashBackdrop", colors.gray_light, colors.bg, styles.italic)
Group.new("FlashMatch", colors.black, colors.yellow, nil)
Group.new("FlashCurrent", colors.black, colors.yellow, nil)
Group.new("FlashLabel", colors.white, colors.pink, nil)
