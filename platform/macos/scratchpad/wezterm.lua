local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Reuse main wezterm theme
package.path = os.getenv("HOME") .. "/.config/wezterm/?.lua;" .. package.path
local theme = require("theme")
theme.apply(config)

-- Window settings - floating scratchpad style
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
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

-- Quitting hides instead: the window and nvim stay alive so the next toggle
-- is instant. session.sh restarts nvim after :q and asks to be hidden via the
-- `scratchpad` user var. `:cq` in nvim is the way to really quit.
config.keys = config.keys or {}
for _, key in ipairs({ "q", "w" }) do
	table.insert(config.keys, { key = key, mods = "CMD", action = wezterm.action.HideApplication })
end

-- Cmd+Shift+D toggles the title strip (needed to drag the window) on/off
table.insert(config.keys, {
	key = "d",
	mods = "CMD|SHIFT",
	action = wezterm.action_callback(function(window)
		local overrides = window:get_config_overrides() or {}
		local current = overrides.window_decorations or config.window_decorations
		overrides.window_decorations = current == "RESIZE" and "INTEGRATED_BUTTONS|RESIZE" or "RESIZE"
		window:set_config_overrides(overrides)
	end),
})

wezterm.on("user-var-changed", function(window, _, name)
	if name == "scratchpad" then
		window:perform_action(wezterm.action.HideApplication, window:active_pane())
	end
end)

-- Initial size (columns x rows)
config.initial_cols = 80
config.initial_rows = 40

-- Force window title so the rift app rule can match it
wezterm.on("format-window-title", function()
	return "scratchpad"
end)

-- Launch directly into the vault
config.default_cwd = os.getenv("HOME") .. "/Documents/vaults/primary"

-- Visual focus indicator: constant border, color swaps on focus
config.window_frame = {
	border_left_width = "4px",
	border_right_width = "4px",
	border_bottom_height = "4px",
	border_top_height = "4px",
	border_left_color = "#111114",
	border_right_color = "#111114",
	border_bottom_color = "#111114",
	border_top_color = "#111114",
}

wezterm.on("window-focus-changed", function(window)
	local overrides = window:get_config_overrides() or {}

	overrides.window_background_opacity = window:is_focused() and 0.95 or 0.7

	window:set_config_overrides(overrides)
end)

-- Position window on startup: right side of screen, always on top
--
-- The window is created at its final position (spawn_window's `position`)
-- rather than moved after it appears, which showed it centered for a frame.
-- Right-aligning needs the window's width, which isn't known until it exists,
-- so the width from the previous launch is cached. The first launch (or a
-- launch on a screen with a different DPI) uses the fallback and is corrected
-- with set_position.
--
-- WezTerm on macOS divides the spawn position by the display scale twice
-- (once in new_window, again in screen_point_to_cartesian), so on a Retina
-- screen the requested coordinates are multiplied by the scale to compensate.
-- set_position runs unconditionally afterwards, so if that bug is fixed
-- upstream the window is still moved to the right place.
local WIDTH_CACHE = os.getenv("HOME") .. "/.local/state/scratchpad/window-width"
local FALLBACK_WIDTH = 760
local PADDING = 16
local TOP_OFFSET = 40 -- menu bar / sketchybar

local function read_cached_width()
	local file = io.open(WIDTH_CACHE, "r")
	if not file then
		return nil
	end
	local width = tonumber(file:read("*l"))
	file:close()
	return width
end

local function write_cached_width(width)
	local file = io.open(WIDTH_CACHE, "w")
	if not file then
		-- First run: the state dir doesn't exist yet
		os.execute("mkdir -p " .. wezterm.shell_quote_arg(WIDTH_CACHE:match("(.*)/")))
		file = io.open(WIDTH_CACHE, "w")
	end
	if not file then
		return
	end
	file:write(tostring(width))
	file:close()
end

local function top_right(screen, width)
	return screen.x + screen.width - width - PADDING, screen.y + PADDING + TOP_OFFSET
end

wezterm.on("gui-startup", function(cmd)
	local screen = wezterm.gui.screens().active
	local estimated_x, y = top_right(screen, read_cached_width() or FALLBACK_WIDTH)

	local spawn = cmd or {}
	local scale = (screen.effective_dpi or 72) / 72
	spawn.position = { x = estimated_x * scale, y = y * scale, origin = "ScreenCoordinateSystem" }
	local _, pane, window = wezterm.mux.spawn_window(spawn)
	local gui_win = window:gui_window()

	gui_win:perform_action(wezterm.action.SetWindowLevel("AlwaysOnTop"), pane)

	local width = gui_win:get_dimensions().pixel_width
	write_cached_width(width)
	gui_win:set_position(top_right(screen, width), y)
end)

return config
