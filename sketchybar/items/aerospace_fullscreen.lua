local constants = require("constants")
local colors = require("config.colors")

local mode = sbar.add("item", constants.items.AEROSPACE_FULLSCREEN, {
	width = 0,
})

local is_fullscreen = false

local function change_border_color(color, width)
	local handle = io.popen(
		"borders style=round hidpi=true width=" .. width .. " active_color=" .. color .. " inactive_color=0x00414550"
	)

	if not handle then
		return
	end

	handle:close()
end

mode:subscribe(constants.events.FULLSCREEN, function(env)
	if is_fullscreen then
		is_fullscreen = false
		change_border_color("0xAA00AAFF", "8.0")
	else
		is_fullscreen = true
		change_border_color("0xfff0c674", "12.0")
	end
end)
