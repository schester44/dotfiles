local style = require("config.styles").get()

sbar.bar({
	height = style.bar.height,
	color = style.bar.color,
	corner_radius = 0,
	y_offset = style.bar.y_offset,
	padding_right = style.bar.x_padding,
	padding_left = style.bar.x_padding,
	margin = style.bar.margin,
	blur_radius = style.bar.blur_radius,
	topmost = "window",
})
