local M = {}

function M.toggle()
	local wezterm = require("wezterm")

	return wezterm.action_callback(function(window, pane)
		local mux = wezterm.mux

		-- Find a pane (and its window) by id anywhere in the mux.
		local function find_pane(pane_id)
			if not pane_id then
				return nil, nil
			end
			for _, mux_win in ipairs(mux.all_windows()) do
				for _, tab in ipairs(mux_win:tabs()) do
					for _, p in ipairs(tab:panes()) do
						if p:pane_id() == pane_id then
							return p, mux_win
						end
					end
				end
			end
			return nil, nil
		end

		-- Toggle off: close the tracked wezwork pane and go back to where we were.
		-- Kill strictly by the pane id recorded at spawn time: CloseCurrentPane
		-- ignores the pane argument for panes in other tabs and closes whatever
		-- pane is focused instead, and process-name sniffing can misfire.
		local wez_pane = find_pane(wezterm.GLOBAL.wezwork_pane)
		if wez_pane then
			local wezterm_bin = wezterm.executable_dir .. "/wezterm"
			wezterm.background_child_process({
				wezterm_bin,
				"cli",
				"kill-pane",
				"--pane-id",
				tostring(wez_pane:pane_id()),
			})
			wezterm.GLOBAL.wezwork_pane = nil

			-- Refocus the pane that was active before wezwork was opened.
			local prev_pane, prev_win = find_pane(wezterm.GLOBAL.wezwork_prev_pane)
			wezterm.GLOBAL.wezwork_prev_pane = nil
			if prev_pane then
				prev_pane:activate()
				local gui_win = prev_win:gui_window()
				if gui_win then
					gui_win:focus()
				end
			end
			return
		end
		-- Stale id (pane was closed manually): fall through and spawn fresh.
		wezterm.GLOBAL.wezwork_pane = nil

		-- Remember where we came from, then open wezwork in its own tab.
		-- Use the wezwork binary from PATH; show an error if it's not installed.
		wezterm.GLOBAL.wezwork_prev_pane = pane:pane_id()
		local new_tab, new_pane = window:mux_window():spawn_tab({
			args = {
				"/bin/zsh",
				"-lic",
				'export PATH="$HOME/go/bin:$PATH"; if command -v wezwork >/dev/null 2>&1; then exec wezwork; else echo "\033[1;31mError: wezwork is not installed or not in PATH.\033[0m"; echo "Install it with: go install <module>@latest"; read; fi',
			},
		})
		if new_tab then
			new_tab:set_title("wezwork")
		end
		if new_pane then
			wezterm.GLOBAL.wezwork_pane = new_pane:pane_id()
		end
	end)
end

return M
