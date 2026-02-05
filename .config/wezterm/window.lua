local M = {}

local theme = require("theme").theme

M.apply = function(config)
	local wezterm = require("wezterm")

	config.window_decorations = "RESIZE"

	config.window_padding = {
		left = 30,
		right = 30,
		top = 30,
		bottom = 25,
	}

	config.tab_max_width = 64
	config.use_fancy_tab_bar = false
	config.hide_tab_bar_if_only_one_tab = false
	config.tab_bar_at_bottom = true
	config.show_new_tab_button_in_tab_bar = false

	config.status_update_interval = 1000

	local active_key_maps = {
		resize_pane = "Resize Pane",
	}

	wezterm.on("format-tab-title", function(tab)
		local is_zoomed = tab.active_pane.is_zoomed

		local title = tab.tab_title and tab.tab_title ~= "" and tab.tab_title .. " " or ""

		local is_active = tab.is_active

		local elements = {
			{
				Background = {
					Color = is_zoomed and theme.alert
						or is_active and theme.background_light
						or theme.inactive_panel_background,
				},
			},
		}

		if is_zoomed then
			table.insert(elements, {
				Background = { Color = theme.background },
			})

			table.insert(elements, {
				Foreground = { Color = theme.alert },
			})
		end

		table.insert(elements, { Text = " " .. wezterm.nerdfonts["md_numeric_" .. tab.tab_index + 1 .. "_box"] .. " " })
		table.insert(elements, { Text = title })

		return elements
	end)

	wezterm.on("update-status", function(window, pane)
		local active_key_table = window:active_key_table()
		local key_map_name = active_key_maps[active_key_table]

		local active_key_title = (key_map_name and key_map_name or active_key_table)
		local active_workspace = window:active_workspace()

		local title = active_workspace == "default" and "" or "" .. " " .. active_workspace .. ""

		-- Get git branch and status for the active pane's cwd
		local git_branch = ""
		local git_dirty = false
		local git_file_count = 0
		local cwd_uri = pane:get_current_working_dir()
		if cwd_uri then
			local cwd = cwd_uri.file_path
			if cwd then
				local success, stdout = wezterm.run_child_process({
					"git",
					"-C",
					cwd,
					"rev-parse",
					"--abbrev-ref",
					"HEAD",
				})
				if success then
					git_branch = stdout:gsub("%s+", "")

					-- Check for uncommitted changes
					local status_success, status_stdout = wezterm.run_child_process({
						"git",
						"-C",
						cwd,
						"status",
						"--porcelain",
					})
					if status_success and status_stdout ~= "" then
						git_dirty = true
						-- Count changed files
						for _ in status_stdout:gmatch("[^\r\n]+") do
							git_file_count = git_file_count + 1
						end
					end
				end
			end
		end

		window:set_left_status(wezterm.format({
			{
				Foreground = {
					Color = theme.alert,
				},
			},
			{
				Text = active_key_table and " " .. wezterm.nerdfonts.cod_layout .. " " .. active_key_title or "",
			},
			{
				Foreground = { Color = git_dirty and "#f9e2af" or "#a6e3a1" },
			},
			{
				Text = git_branch ~= ""
						and " "
							.. wezterm.nerdfonts.dev_git_branch
							.. ((git_branch ~= "main" and git_branch ~= "master") and " " .. git_branch or "")
							.. (git_dirty and " (" .. git_file_count .. ")" or "")
							.. " "
					or "",
			},
			{ Foreground = { Color = theme.foreground } },
			{
				Text = " " .. wezterm.nerdfonts.fa_terminal .. title .. " ",
			},
		}))
	end)

	return config
end

return M
