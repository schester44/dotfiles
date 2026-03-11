local colors = require("config.colors")
local icons = require("config.icons")

-- -- Add app icons and hide if empty + unfocused
local function add_windows(space, space_name, is_focused)
	sbar.exec("aerospace list-windows --format %{app-name} --workspace " .. space_name, function(windows)
		local icon_line = ""

		for app in windows:gmatch("[^\r\n]+") do
			local icon = icons[app] or icons["Default"]
			icon_line = icon_line .. " " .. icon

			-- Log app name to file
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

sbar.exec("aerospace list-workspaces --all", function(output)
	-- Collect all workspace names first
	local workspaces = {}
	for space_name in output:gmatch("[^\r\n]+") do
		table.insert(workspaces, space_name)
	end

	for i, space_name in ipairs(workspaces) do
		table.insert(space_names, "space." .. space_name)
		local is_first = i == 1
		local is_last = i == #workspaces

		local space = sbar.add("item", "space." .. space_name, {
			icon = {
				string = space_name,
				color = colors.white,
				highlight_color = colors.white,
				padding_left = 12,
				padding_right = 0,
			},
			label = {
				font = "sketchybar-app-font:Regular:14.0",
				string = "",
				color = 0xbbffffff,
				highlight_color = colors.white,
				y_offset = -1,
				padding_right = is_last and 0 or 14,
			},
			background = {
				color = 0x00000000,
				corner_radius = 10,
				height = 22,
			},
			click_script = "aerospace workspace " .. space_name,
			padding_left = is_first and 4 or 2,
			padding_right = is_last and 4 or 2,
			drawing = false, -- hide by default until checked
			updates = true,
		})

		add_windows(space, space_name)

		local constants = require("constants")

		space:subscribe(constants.events.AEROSPACE_WORKSPACE_CHANGED, function(env)
			local selected = env.FOCUSED_WORKSPACE == space_name
			local prev_selected = env.PREV_WORKSPACE == space_name

			space:set({
				icon = { highlight = selected },
				label = { highlight = selected },
				background = { color = selected and 0x60967EFB or 0x00000000 },
			})

			space:set({ drawing = selected or space:query().label.value ~= "—" })

			-- update the window icons if this space was selected or was previously selected
			if selected or prev_selected then
				add_windows(space, space_name, selected)
			end
		end)

		space:subscribe("space_windows_change", function()
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
