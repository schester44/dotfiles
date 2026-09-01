-- Session persistence via resurrect.wezterm
--
-- Saves workspace layouts (windows/tabs/panes/cwd/scrollback text) to json
-- under the plugin's state dir. Does NOT persist running processes.
--
--   LEADER+w  save current workspace state
--   LEADER+W  fuzzy-load a saved workspace/window/tab state
--   auto      periodic save of the active workspace every 5 minutes
--   startup   restores the last-saved workspace

local M = {}

-- Show a transient message in the left status bar (rendered by window.lua)
local function flash(text, seconds)
	local wezterm = require("wezterm")
	wezterm.GLOBAL.flash_text = text
	wezterm.GLOBAL.flash_until = wezterm.time.now():format("%s") + (seconds or 3)
end

function M.apply(config)
	local wezterm = require("wezterm")
	local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")

	-- Keep state files reasonably sized
	resurrect.state_manager.set_max_nlines(1000)

	-- Auto-save the active workspace every 5 minutes
	resurrect.state_manager.periodic_save({
		interval_seconds = 300,
		save_workspaces = true,
	})

	-- Record which workspace is "current" after each periodic save, so
	-- resurrect_on_gui_startup knows what to restore
	wezterm.on("resurrect.state_manager.periodic_save.finished", function()
		resurrect.state_manager.write_current_state(wezterm.mux.get_active_workspace(), "workspace")
	end)

	-- Restore the last-saved workspace when the GUI starts
	wezterm.on("gui-startup", resurrect.state_manager.resurrect_on_gui_startup)

	local keys = {
		-- Save current workspace state
		{
			key = "w",
			mods = "LEADER",
			action = wezterm.action_callback(function()
				resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
				resurrect.state_manager.write_current_state(wezterm.mux.get_active_workspace(), "workspace")
				flash(wezterm.nerdfonts.md_content_save .. " workspace saved")
			end),
		},
		-- Fuzzy-load a saved state
		{
			key = "W",
			mods = "LEADER|SHIFT",
			action = wezterm.action_callback(function(win, pane)
				resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id)
					local type = string.match(id, "^([^/]+)") -- match before '/'
					id = string.match(id, "([^/]+)$")    -- match after '/'
					id = string.match(id, "(.+)%..+$")   -- remove file extension
					local opts = {
						relative = true,
						restore_text = true,
						on_pane_restore = resurrect.tab_state.default_on_pane_restore,
					}
					if type == "workspace" then
						local state = resurrect.state_manager.load_state(id, "workspace")
						opts.spawn_in_workspace = true
						resurrect.workspace_state.restore_workspace(state, opts)
						-- Switch to the restored workspace
						local name = state.workspace or id
						win:perform_action(wezterm.action.SwitchToWorkspace({ name = name }), pane)
						flash(wezterm.nerdfonts.md_folder_open .. " restored workspace: " .. name)
					elseif type == "window" then
						local state = resurrect.state_manager.load_state(id, "window")
						resurrect.window_state.restore_window(pane:window(), state, opts)
					elseif type == "tab" then
						local state = resurrect.state_manager.load_state(id, "tab")
						resurrect.tab_state.restore_tab(pane:tab(), state, opts)
					end
				end)
			end),
		},
	}

	for _, key in ipairs(keys) do
		table.insert(config.keys, key)
	end

	return config
end

return M
