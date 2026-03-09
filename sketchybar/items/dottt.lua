local constants = require("constants")

sbar.add("alias", constants.items.DOTTT, {
	position = "right",
	update_freq = 1,
	label = { padding_left = 0, padding_right = 0 },
	icon = { padding_left = 0, padding_right = 0 },
	background = {
		color = 0x20ffffff,
		corner_radius = 6,
		height = 20,
	},
})
