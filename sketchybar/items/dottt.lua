local constants = require("constants")

sbar.add("alias", constants.items.DOTTT, {
	position = "right",
	update_freq = 1,
	label = { padding_left = 0, padding_right = 0 },
	icon = { padding_left = 0, padding_right = 0 },
	padding_left = 6,
	background = {
		color = 0x00000000,
	},
})

-- Add bracket around dottt and clock
sbar.add("bracket", "right_container", {
	constants.items.DOTTT,
	constants.items.CLOCK,
	"right_container_spacer",
}, {
	background = {
		color = 0x20ffffff,
		corner_radius = 12,
		height = 28,
	},
})
