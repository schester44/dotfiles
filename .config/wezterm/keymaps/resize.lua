local M = {}

function M.apply(config, name)
	local act = require("wezterm").action

	config.key_tables = config.key_tables or {}

	config.key_tables[name] = {
		{
			key = "h",
			action = act.AdjustPaneSize({ "Left", 2 }),
		},
		{
			key = "j",
			action = act.AdjustPaneSize({ "Down", 2 }),
		},
		{
			key = "k",
			action = act.AdjustPaneSize({ "Up", 2 }),
		},
		{
			key = "l",
			action = act.AdjustPaneSize({ "Right", 2 }),
		},
		{
			key = "Escape",
			action = "PopKeyTable",
		},
	}

	return config
end

return M
