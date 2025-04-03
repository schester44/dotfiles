local M = {}

local function is_vim(pane)
	-- this is set by the plugin, and unset on ExitPre in Neovim
	return pane:get_user_vars().IS_NVIM == "true"
end

local direction_keys = {
	Left = "h",
	Down = "j",
	Up = "k",
	Right = "l",
	h = "Left",
	j = "Down",
	k = "Up",
	l = "Right",
}

local function split_nav(resize_or_move, key)
	local w = require("wezterm")

	return {
		key = key,
		mods = resize_or_move == "resize" and "META" or "CTRL",
		action = w.action_callback(function(win, pane)
			if is_vim(pane) then
				-- pass the keys through to vim/nvim
				-- FIXME: panes aren't resized in neovim using META
				win:perform_action({
					SendKey = { key = key, mods = resize_or_move == "resize" and "META" or "CTRL" },
				}, pane)
			else
				if resize_or_move == "resize" then
					win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
				else
					win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
				end
			end
		end),
	}
end

M.apply = function(config)
	local wezterm = require("wezterm")
	local act = wezterm.action

	config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

	config.key_tables = {
		resize_pane = {
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
		},
	}

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
		-- Create a new workspace with a random name and switch to it
		{
			key = "n",
			mods = "LEADER",
			action = act.PromptInputLine({
				description = wezterm.format({
					{ Attribute = { Intensity = "Bold" } },
					{ Foreground = { AnsiColor = "Fuchsia" } },
					{ Text = "Enter name for new workspace" },
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
					{ Foreground = { AnsiColor = "Blue" } },
					{ Text = "New tab name:" },
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
					{ Foreground = { AnsiColor = "Blue" } },
					{ Text = "New workspace name:" },
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
