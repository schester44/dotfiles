local constants = require("constants")
local colors = require("config.colors")

local clock = sbar.add("item", constants.items.CLOCK, {
	position = "right",
	-- TODO, 1 what? only need to update every minute
	update_freq = 1,
	icon = { padding_left = 0, padding_right = 0 },
})

clock:subscribe({ "forced", "routine", "system_woke" }, function()
	---@diagnostic disable-next-line: param-type-mismatch
	local day = string.sub(os.date("%a"), 1, 1)

	clock:set({
		label = {
			string = day .. os.date("%m-%d|%H:%M"),
			padding_left = 12,
			padding_right = 12,
		},
		background = {
			color = colors.bg1,
		},
	})
end)
