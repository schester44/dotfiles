local config = require("config.config")
local colors = require("config.colors")

-- Equivalent to the --default domain
sbar.default({
	updates = "when_shown",
	icon = {
		font = {
			family = config.icon_font.family,
			style = "Bold",
			size = 14.0,
		},
		color = colors.white,
		padding_left = 4,
		padding_right = 4,
	},
	label = {
		font = {
			family = config.label_font.family,
			style = "Bold",
			size = 13.0,
		},
		color = colors.white,
		padding_left = 4,
		padding_right = 4,
	},
	background = {
		height = 24,
		corner_radius = 7,
		border_width = 2,
	},
	padding_left = 0,
	padding_right = 0,
})
