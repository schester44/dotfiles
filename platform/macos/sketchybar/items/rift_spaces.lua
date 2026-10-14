local colors = require("config.colors")
local icons = require("config.icons")
local constants = require("constants")

-- Port of aerospace_spaces.lua for rift (rift-cli + jq)

local QUERY = "rift-cli query workspaces"

-- Add app icons and hide if empty + unfocused
local function add_windows(space, space_name, is_focused)
	local cmd = QUERY .. " | jq -r '.[] | select(.name == \"" .. space_name .. "\") | .windows[].app_name'"

	sbar.exec(cmd, function(windows)
		local icon_line = ""

		for app in windows:gmatch("[^\r\n]+") do
			local icon = icons[app] or icons["Default"]
			icon_line = icon_line .. " " .. icon
		end

		local label_text = icon_line == "" and "—" or icon_line
		local padding = icon_line == "" and 8 or 12

		sbar.animate("tanh", 10, function()
			space:set({
				label = {
					string = label_text,
					padding_right = padding,
				},
			})
		end)

		local should_draw = icon_line ~= "" or is_focused

		space:set({
			drawing = should_draw,
		})
	end)
end

local space_names = {}

-- "name|is_active" per line, in index order
sbar.exec(QUERY .. " | jq -r '.[] | \"\\(.name)|\\(.is_active)\"'", function(output)
	local workspaces = {}
	for line in output:gmatch("[^\r\n]+") do
		local name, active = line:match("^(.-)|(.+)$")
		if name then
			table.insert(workspaces, { name = name, active = active == "true" })
		end
	end

	for i, ws in ipairs(workspaces) do
		local space_name = ws.name
		local index = i - 1 -- rift workspace indices are zero-based
		table.insert(space_names, "space." .. space_name)
		local is_first = i == 1
		local is_last = i == #workspaces

		local space = sbar.add("item", "space." .. space_name, {
			icon = {
				string = space_name,
				color = colors.white,
				highlight_color = colors.white,
				highlight = ws.active,
				padding_left = 12,
				padding_right = 0,
			},
			label = {
				font = "sketchybar-app-font:Regular:14.0",
				string = "",
				color = 0xbbffffff,
				highlight_color = colors.white,
				highlight = ws.active,
				y_offset = -1,
				padding_right = is_last and 0 or 14,
			},
			background = {
				color = ws.active and 0x60967EFB or 0x00000000,
				corner_radius = 10,
				height = 22,
			},
			click_script = "rift-cli execute workspace switch " .. index,
			padding_left = is_first and 4 or 2,
			padding_right = is_last and 4 or 2,
			drawing = false, -- hide by default until checked
			updates = true,
		})

		add_windows(space, space_name, ws.active)

		space:subscribe(constants.events.AEROSPACE_WORKSPACE_CHANGED, function(env)
			local selected = env.FOCUSED_WORKSPACE == space_name

			space:set({
				icon = { highlight = selected },
				label = { highlight = selected },
				background = { color = selected and 0x60967EFB or 0x00000000 },
			})

			-- rift's event doesn't carry PREV_WORKSPACE, so refresh every space
			add_windows(space, space_name, selected)
		end)

		space:subscribe(constants.events.RIFT_WINDOWS_CHANGED, function()
			add_windows(space, space_name)
		end)

		space:subscribe("mouse.clicked", function()
			sbar.animate("tanh", 8, function()
				space:set({
					background = { shadow = { distance = 0 } },
					y_offset = -4,
					padding_left = 10,
					padding_right = 0,
				})
				space:set({
					background = { shadow = { distance = 4 } },
					y_offset = 0,
					padding_left = 4,
					padding_right = 4,
				})
			end)
		end)
	end

	-- Add bracket around all spaces for pill-shaped container
	sbar.add("bracket", "spaces_bracket", space_names, {
		background = {
			color = 0x20ffffff,
			corner_radius = 12,
			height = 28,
		},
	})
end)
