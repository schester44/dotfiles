local colors = require("config.colors")
local config = require("config.config")

sbar.bar({
	height = config.dimensions.bar.height,
	color = colors.transparent,
	corner_radius = 25,
	y_offset = 4,
	padding_right = config.dimensions.bar.x_padding,
	padding_left = config.dimensions.bar.x_padding,
	margin = 12,
	blur_radius = 0,
	topmost = "window",
})
