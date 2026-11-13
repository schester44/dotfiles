-- Bar styles. Switch by changing `current`, then: sketchybar --reload
--   float: the original look — transparent bar, floating rounded pills
--   flat:  slim near-black strip across the very top; statusbar energy,
--          slight translucency + blur so it still feels like a mac

local M = {}

M.current = "float"

M.styles = {
	float = {
		bar = {
			-- starts at the screen top (for the notch extension); pills still
			-- sit 6px down, as with the old height 30 / y_offset 5
			height = 40,
			y_offset = 0,
			color = 0x00000000,
			margin = 0,
			x_padding = 10,
			blur_radius = 0,
		},
		-- containers around the spaces strip and the right cluster
		bracket = { color = 0x20ffffff, corner_radius = 12, height = 28 },
		-- focused-workspace highlight
		space_highlight = { corner_radius = 10, height = 22 },
		clock_sep = "|",
		-- battery stands alone in its own pill
		battery_own_pill = true,
		battery_pill = { color = 0x20ffffff, corner_radius = 12, height = 28 },
	},

	flat = {
		bar = {
			height = 24,
			y_offset = 0,
			color = 0x600a0a0e, -- mostly the wallpaper, darkened just enough to read
			margin = 0,
			x_padding = 6,
			blur_radius = 40,
		},
		-- no pills: items sit directly on the bar
		bracket = { color = 0x00000000, corner_radius = 0, height = 22 },
		space_highlight = { corner_radius = 5, height = 18 },
		clock_sep = "·",
		-- battery stands alone as its own small pill
		battery_own_pill = true,
		battery_pill = { color = 0x26ffffff, corner_radius = 5, height = 18 },
	},
}

-- Built-in display notch, in points (NSScreen auxiliaryTopLeft/RightArea and
-- safeAreaInsets.top). Spotify hangs off its right edge as an extension.
M.notch = { width = 185, height = 33, radius = 10 }

function M.get()
	return M.styles[M.current]
end

return M
