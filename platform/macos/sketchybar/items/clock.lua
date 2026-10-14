local constants = require("constants")
local colors = require("config.colors")
local style = require("config.styles").get()

-- Right spacer for container padding
sbar.add("item", "right_container_spacer", {
	position = "right",
	width = 4,
	background = { drawing = false },
})

local clock = sbar.add("item", constants.items.CLOCK, {
	position = "right",
	update_freq = 30,
	icon = { padding_left = 0, padding_right = 0 },
	padding_left = 0,
})

-- Right cluster pill (clock; battery joins unless the style gives it its own pill)
local members = { constants.items.CLOCK, "right_container_spacer" }
if not style.battery_own_pill then
	table.insert(members, 1, "battery")
end

sbar.add("bracket", "right_container", members, {
	background = {
		color = style.bracket.color,
		corner_radius = style.bracket.corner_radius,
		height = style.bracket.height,
	},
})

clock:subscribe({ "forced", "routine", "system_woke" }, function()
	---@diagnostic disable-next-line: param-type-mismatch
	local day = string.sub(os.date("%a"), 1, 1)

	clock:set({
		label = {
			string = day .. os.date("%m-%d") .. style.clock_sep .. os.date("%H:%M"),
			color = colors.white,
			padding_left = 8,
			padding_right = 8,
		},
		background = {
			color = 0x00000000,
		},
	})
end)
