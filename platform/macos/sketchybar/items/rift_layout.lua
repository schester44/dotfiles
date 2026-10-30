local constants = require("constants")

-- Minimal indicator for the active workspace's rift layout mode.
-- Sits after the spaces pill; dim, small, just there when you need it.

local short_names = {
	traditional = "tile",
	bsp = "bsp",
	master_stack = "mstr",
	scrolling = "scrl",
	stack = "stck",
	floating = "flt",
}

local layout = sbar.add("item", "rift_layout", {
	position = "left",
	icon = { drawing = false },
	label = {
		string = "",
		font = { size = 11.0 },
		color = 0x66ffffff,
		padding_left = 8,
		padding_right = 8,
	},
	background = { drawing = false },
	updates = true,
})

local function refresh()
	sbar.exec("rift-cli query workspaces | jq -r '.[] | select(.is_active) | .layout_mode'", function(mode)
		mode = mode:match("^%s*(.-)%s*$")
		layout:set({ label = { string = short_names[mode] or mode } })
	end)
end

refresh()

layout:subscribe(constants.events.RIFT_LAYOUT_CHANGED, refresh)
layout:subscribe(constants.events.WORKSPACE_CHANGED, refresh)
