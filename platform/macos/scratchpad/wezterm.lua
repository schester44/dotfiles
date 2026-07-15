local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Reuse main wezterm theme
package.path = os.getenv("HOME") .. "/.config/wezterm/?.lua;" .. package.path
local theme = require("theme")
theme.apply(config)

-- Window settings - floating scratchpad style
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.95
config.macos_window_background_blur = 20

-- Dark background that pairs with grapelean
config.colors = config.colors or {}
config.colors.background = "#111114"

config.window_padding = {
	left = 20,
	right = 20,
	top = 20,
	bottom = 16,
}

-- No tab bar for single-purpose window
config.enable_tab_bar = false

-- Skip "are you sure?" on close
config.window_close_confirmation = "NeverPrompt"

-- Initial size (columns x rows)
config.initial_cols = 80
config.initial_rows = 40

-- Force window title so aerospace can match it
wezterm.on("format-window-title", function()
	return "scratchpad"
end)

-- Launch directly into the vault
config.default_cwd = os.getenv("HOME") .. "/Documents/vaults/primary"

-- Position window on startup: right side of screen, always on top
wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
	local gui_win = window:gui_window()

	-- Always on top
	gui_win:perform_action(wezterm.action.SetWindowLevel("AlwaysOnTop"), pane)

	-- Right side of screen with padding
	local screen = wezterm.gui.screens().active
	local dims = gui_win:get_dimensions()
	local padding = 16
	local x = screen.x + screen.width - dims.pixel_width - padding
	local y = screen.y + padding + 40 -- menu bar / sketchybar
	gui_win:set_position(x, y)
end)

return config
