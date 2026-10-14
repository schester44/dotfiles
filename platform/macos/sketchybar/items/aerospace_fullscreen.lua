local constants = require("constants")

local logger = require("utils.logger")

local mode = sbar.add("item", constants.items.AEROSPACE_FULLSCREEN, {
	width = 0,
})

local utils = {
	borders = {
		change_color = function(color, width)
			local handle = io.popen(
				"borders style=round hidpi=true width="
					.. width
					.. " active_color="
					.. color
					.. " inactive_color=0x00414550"
			)

			if not handle then
				return
			end

			handle:close()
		end,
	},

	get_focused_workspace = function()
		local handle = io.popen("rift-cli query workspaces | jq -r '.[] | select(.is_active) | .name'")

		if not handle then
			logger.log("Failed to execute rift-cli")
			return
		end

		local result = handle:read("*a")
		handle:close()

		return result:match("^%s*(.-)%s*$")
	end,
}

local render = {
	fullscreen = function()
		return utils.borders.change_color("0xfff0c674", "12.0")
	end,
	windowed = function()
		return utils.borders.change_color("0xAA00AAFF", "8.0")
	end,
}

local screen_fullscreen_map = {}
local focused_workspace = utils.get_focused_workspace()

local function init_on_load()
	-- rift doesn't expose per-window fullscreen state; assume windowed on load.
	-- State is tracked via the FULLSCREEN trigger (Alt+Enter) from then on.
	if focused_workspace then
		screen_fullscreen_map[focused_workspace] = false
		render.windowed()
	end
end

init_on_load()

mode:subscribe(constants.events.FULLSCREEN, function()
	if not focused_workspace then
		return
	end

	local full_screen = screen_fullscreen_map[focused_workspace] or false

	if full_screen then
		full_screen = false
		render.windowed()
	else
		full_screen = true
		render.fullscreen()
	end

	screen_fullscreen_map[focused_workspace] = full_screen
end)

mode:subscribe(constants.events.AEROSPACE_WORKSPACE_CHANGED, function(env)
	focused_workspace = env.FOCUSED_WORKSPACE

	local is_fullscreen = screen_fullscreen_map[focused_workspace] or false

	if is_fullscreen then
		render.fullscreen()
	else
		render.windowed()
	end
end)
