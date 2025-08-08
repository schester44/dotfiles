local colors = require("config.colors")
local icons = require("config.icons")

local log = function(x)
	local log_file = io.open(os.getenv("HOME") .. "/.cache/sketchybar/app_log.txt", "a")

	if log_file then
		log_file:write(os.date("%Y-%m-%d %H:%M:%S") .. " - ", x, "\n")

		log_file:close()
	end
end

-- Check if this workspace is currently focused
local function is_focused_workspace(space_name, callback)
	sbar.exec("aerospace list-workspaces --focused", function(focused)
		local current = focused:match("^%s*(.-)%s*$")
		callback(current == space_name)
	end)
end

-- -- Add app icons and hide if empty + unfocused
local function add_windows(space, space_name)
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

		is_focused_workspace(space_name, function(is_focused)
			local should_draw = icon_line ~= "" or is_focused
			space:set({ drawing = should_draw })
		end)
	end)
end

local highlights = {
	["1"] = colors.yellow,
	["2"] = colors.green,
	["3"] = colors.blue,
	["4"] = colors.bg1,
	["5"] = colors.purple,
	["P"] = colors.light_blue,
}

sbar.exec("aerospace list-workspaces --all", function(output)
	for space_name in output:gmatch("[^\r\n]+") do
		local is_first = space_name == "1"

		local space = sbar.add("item", "space." .. space_name, {
			icon = {
				string = space_name,
				color = colors.bg2,
				highlight_color = colors.white,
				padding_left = 8,
			},
			label = {
				font = "sketchybar-app-font:Regular:14.0",
				string = "",
				color = colors.white,
				highlight_color = highlights[space_name] or colors.yellow,
				y_offset = -1,
			},
			background = {
				color = colors.bg1,
			},
			click_script = "aerospace workspace " .. space_name,
			padding_left = is_first and 0 or 4,
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
			})

			space:set({ drawing = selected or space:query().label.value ~= "—" })

			-- update the window icons if this space was selected or was previously selected
			if selected or prev_selected then
				add_windows(space, space_name)
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
end)
