-- TODO: any changes here should execute stankybay reload

local workspace_ids = { 1, 2, 3, 4, 5, "P", "S" }
local output_file = "output_aerospace.toml"

local function sketchybar_trigger(event, params)
	local cmd = "exec-and-forget sketchybar --trigger " .. event
	if params then
		for key, value in pairs(params) do
			cmd = cmd .. string.format(" %s=%s", key, value)
		end
	end
	return cmd
end

local function mode(v)
	return "mode " .. v
end

-- Define TOML structure using Lua tables
local toml_data = {
	start_at_login = true,
	after_startup_command = { sketchybar_trigger("sketchybar") },
	exec_on_workspace_change = {
		sketchybar_trigger("aerospace_workspace_changed", { FOCUSED_WORKSPACE = "$AEROSPACE_FOCUSED_WORKSPACE" }),
	},
	gaps = {
		--- [[gaps]]
		--- inner.horizontal = 8
		inner = { horizontal = 8, vertical = 8 },
		outer = {
			left = 12,
			right = 12,
			bottom = 12,
			top = { { ["monitor.'^built-in retina display$'"] = 10 }, 40 },
		},
	},
	-- [[mode.main.binding]]
	-- add specific logic for mode and on_window_detected instead of trying to have a generic serializer
	mode = {
		main = {
			binding = {
				["alt-tab"] = "workspace-back-and-forth",
				["alt-shift-semicolon"] = {
					mode("service"),
					sketchybar_trigger("send_mode", { MESSAGE = "SERVICE", HOLD = "true" }),
				},
				["ctrl-space"] = {
					mode("alt"),
					sketchybar_trigger("send_mode", { MESSAGE = "ALT", HOLD = "true" }),
				},
			},
		},
		alt = {
			binding = {
				esc = { mode("main"), sketchybar_trigger("hide_mode") },
				space = { mode("main"), sketchybar_trigger("hide_mode") },
				["ctrl-space"] = { mode("main"), sketchybar_trigger("hide_mode") },
				r = {
					"reload-config",
					sketchybar_trigger("hide_mode"),
					sketchybar_trigger("reload"),
					mode("main"),
				},
				slash = "layout tiles horizontal vertical",
				comma = "layout accordion horizontal vertical",
				h = "focus --boundaries-action stop left",
				j = "focus --boundaries-action stop down",
				k = "focus --boundaries-action stop up",
				l = "focus --boundaries-action stop right",
				["shift-h"] = "move left",
				["shift-j"] = "move down",
				["shift-k"] = "move up",
				["shift-l"] = "move right",
			},
		},
	},
	on_window_detected = {
		{
			if_app_id = "com.google.Chrome",
			if_window_title_regex_substring = "^about:blank - (?!Google Chrome).*$",
			run = { "layout floating" },
		},
		{ if_app_id = "com.dottt.app", run = { "layout floating" } },
		{ if_app_id = "com.github.wez.terminal", run = "move-node-to-workspace W" },
	},
}

-- TODO move this stuff to live inside of the modes.bindings
-- Dynamically add workspace bindings
for _, id in ipairs(workspace_ids) do
	toml_data.mode.main.binding["alt-" .. id] = "workspace " .. id
	toml_data.mode.main.binding["alt-shift-" .. id] = "move-node-to-workspace " .. id
	toml_data.mode.alt.binding[id] = "workspace " .. id
	toml_data.mode.alt.binding["shift-" .. id] = "move-node-to-workspace " .. id
end

-- Add static workspace mappings
local additional_workspaces = { P = "Personal", S = "Slack" }
for key, _ in pairs(additional_workspaces) do
	toml_data.mode.main.binding["alt-" .. key] = "workspace " .. key
	toml_data.mode.main.binding["alt-shift-" .. key] = "move-node-to-workspace " .. key
	toml_data.mode.alt.binding[key] = "workspace " .. key
	toml_data.mode.alt.binding["shift-" .. key] = "move-node-to-workspace " .. key
end

-- Function to serialize a Lua table to TOML format (correctly handles arrays & inline tables)
local function serialize_toml(t, indent)
	indent = indent or ""
	local lines = {}

	for key, value in pairs(t) do
		local formatted_key = tostring(key)

		if type(value) == "table" then
			if #value > 0 then
				-- Handle arrays correctly (including nested tables)
				local array_items = {}
				for _, v in ipairs(value) do
					if type(v) == "string" then
						table.insert(array_items, '"' .. v .. '"')
					elseif type(v) == "number" then
						table.insert(array_items, tostring(v))
					elseif type(v) == "table" then
						-- Handle inline tables inside arrays
						local nested_lines = {}
						for k, sub_v in pairs(v) do
							if type(sub_v) == "table" then
								for x, y in pairs(sub_v) do
									print(x, y)
									table.insert(nested_lines, x .. " = " .. y)
								end
							else
								table.insert(nested_lines, k .. " = " .. sub_v)
							end
						end
						table.insert(array_items, "{ " .. table.concat(nested_lines, ", ") .. " }")
					else
						error("Unsupported array element type: " .. type(v))
					end
				end
				table.insert(lines, indent .. formatted_key .. " = [" .. table.concat(array_items, ", ") .. "]")
			else
				-- Handle nested tables as TOML sections
				table.insert(lines, indent .. "[" .. formatted_key .. "]")
				table.insert(lines, serialize_toml(value, indent .. "    "))
			end
		else
			-- Handle normal key-value pairs
			local formatted_value = type(value) == "string" and ('"' .. value .. '"') or tostring(value)
			table.insert(lines, indent .. formatted_key .. " = " .. formatted_value)
		end
	end

	return table.concat(lines, "\n")
end

-- Write the TOML file
local file = io.open(output_file, "w")
if not file then
	error("Failed to open " .. output_file .. " for writing.")
end

file:write(serialize_toml(toml_data))
file:close()

print("TOML configuration generated successfully in " .. output_file)

