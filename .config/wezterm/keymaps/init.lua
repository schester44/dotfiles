local M = {}
local theme = require("theme").theme

function M.apply(config)
	local wezterm = require("wezterm")
	local act = wezterm.action
	local split_nav = require("keymaps.utils").split_nav

	local resize_mode = require("keymaps.resize")

	config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

	resize_mode.apply(config, "resize_pane")

	config.keys = {
		-- activate resize pane
		{
			key = "r",
			mods = "LEADER",
			action = act.ActivateKeyTable({
				name = "resize_pane",
				one_shot = false,
			}),
		},
		{ key = "d", mods = "LEADER", action = wezterm.action.ShowDebugOverlay },
		-- Create a new workspace with a random name and switch to it
		{
			key = "n",
			mods = "LEADER",
			action = act.PromptInputLine({
				description = wezterm.format({
					{ Attribute = { Intensity = "Bold" } },
					{ Foreground = { Color = theme.alert } },
					{ Text = " Enter name for new workspace" },
				}),
				action = wezterm.action_callback(function(window, pane, line)
					if line then
						window:perform_action(
							act.SwitchToWorkspace({
								name = line,
							}),
							pane
						)
					end
				end),
			}),
		},
		{
			key = "k",
			mods = "CMD",
			action = act.ShowLauncherArgs({
				flags = "FUZZY|WORKSPACES",
			}),
		},
		-- splitting
		{
			key = "s",
			mods = "LEADER",
			action = wezterm.action({
				SplitVertical = {
					domain = "CurrentPaneDomain",
				},
			}),
		},
		{
			key = "v",
			mods = "LEADER",
			action = act({ SplitHorizontal = { domain = "CurrentPaneDomain" } }),
		},
		-- activate copy mode or vim mode
		{
			key = "y",
			mods = "LEADER",
			action = wezterm.action.ActivateCopyMode,
		},

		-- rename tab
		{
			key = "/",
			mods = "LEADER",
			action = act.PromptInputLine({
				description = wezterm.format({
					{ Attribute = { Intensity = "Bold" } },
					{ Foreground = { Color = theme.alert } },
					{ Text = " New tab name:" },
				}),
				action = wezterm.action_callback(function(window, pane, line)
					if line then
						window:active_tab():set_title(line)
					end
				end),
			}),
		},
		-- close current pane with cmd+q
		{
			key = "q",
			mods = "CMD",
			action = wezterm.action.CloseCurrentPane({ confirm = true }),
		},
		-- close current tab with leader+q
		{
			key = "q",
			mods = "LEADER",
			action = wezterm.action.CloseCurrentTab({ confirm = true }),
		},
		-- prevent closing with cmd+w
		{
			key = "w",
			mods = "CMD",
			action = wezterm.action.Nop,
		},
		-- rename workspace
		{
			key = "$",
			mods = "LEADER",
			action = act.PromptInputLine({
				description = wezterm.format({
					{ Attribute = { Intensity = "Bold" } },
					{ Foreground = { Color = theme.alert } },
					{ Text = " Rename workspace name:" },
				}),
				action = wezterm.action_callback(function(window, pane, line)
					if line then
						wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
					end
				end),
			}),
		},
		-- prev/next tab
		{
			key = "[",
			mods = "LEADER",
			action = act.ActivateTabRelative(-1),
		},

		{
			key = "]",
			mods = "LEADER",
			action = act.ActivateTabRelative(1),
		},
		-- move between split panes
		split_nav("move", "h"),
		split_nav("move", "j"),
		split_nav("move", "k"),
		split_nav("move", "l"),
		-- resize panes
		split_nav("resize", "h"),
		split_nav("resize", "j"),
		split_nav("resize", "k"),
		split_nav("resize", "l"),
		-- resizing (full screen)
		{
			mods = "LEADER",
			key = "Enter",
			action = wezterm.action.TogglePaneZoomState,
		},
	}

	for i = 1, 8 do
		-- CTRL+CMD + number to move tab to that position
		table.insert(config.keys, {
			key = tostring(i),
			mods = "CTRL|CMD",
			action = wezterm.action.MoveTab(i - 1),
		})
	end

	return config
end

return M
