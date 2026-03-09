-- Grapelean theme colors for sketchybar
-- Loads from ~/.dotfiles/colors/grapelean.json (single source of truth)
-- Format: 0xAARRGGBB (AA = alpha)

local json_path = os.getenv("HOME") .. "/.dotfiles/colors/grapelean.json"

local function load_json(path)
	local file = io.open(path, "r")
	if not file then
		error("Could not open palette file: " .. path)
	end
	local content = file:read("*a")
	file:close()

	local result = {}

	-- Extract palette section
	local palette_section = content:match('"palette"%s*:%s*(%b{})')
	if palette_section then
		result.palette = {}

		-- Extract nested objects (bg, gray, yellow, etc.)
		for key, value in palette_section:gmatch('"([%w_]+)"%s*:%s*(%b{})') do
			result.palette[key] = {}
			for subkey, subval in value:gmatch('"([%w_]+)"%s*:%s*"([^"]*)"') do
				result.palette[key][subkey] = subval
			end
		end

		-- Extract simple string values (black, white)
		for key, value in palette_section:gmatch('"([%w_]+)"%s*:%s*"([^"]*)"') do
			if not result.palette[key] then
				result.palette[key] = value
			end
		end
	end

	-- Extract terminal section
	local terminal_section = content:match('"terminal"%s*:%s*(%b{})')
	if terminal_section then
		result.terminal = {}
		for key, value in terminal_section:gmatch('"([%w_]+)"%s*:%s*"([^"]*)"') do
			result.terminal[key] = value
		end
	end

	return result
end

-- Convert hex "#RRGGBB" to sketchybar format 0xAARRGGBB
local function hex_to_argb(hex, alpha)
	alpha = alpha or 0xff
	local r, g, b = hex:match("#(%x%x)(%x%x)(%x%x)")
	if r and g and b then
		return alpha * 0x1000000 + tonumber(r, 16) * 0x10000 + tonumber(g, 16) * 0x100 + tonumber(b, 16)
	end
	return 0xff000000 -- fallback to black
end

local theme = load_json(json_path)
local p = theme.palette

-- Build palette in sketchybar format
local palette = {
	-- backgrounds
	bg = hex_to_argb(p.bg.base),
	bg_dark = hex_to_argb(p.bg.dark),
	bg_light = hex_to_argb(p.bg.light),
	bg_muted = hex_to_argb(p.bg.muted),

	-- grays
	black = hex_to_argb(p.black),
	white = hex_to_argb(p.white),
	gray = hex_to_argb(p.gray.base),
	gray_dark = hex_to_argb(p.gray.dark),
	gray_light = hex_to_argb(p.gray.light),
	gray_muted = hex_to_argb(p.gray.muted),

	-- colors
	yellow = hex_to_argb(p.yellow.base),
	yellow_light = hex_to_argb(p.yellow.light),
	green = hex_to_argb(p.green.base),
	green_glow = hex_to_argb(p.green.glow),
	blue = hex_to_argb(p.blue.base),
	blue_light = hex_to_argb(p.blue.light),
	purple = hex_to_argb(p.purple.base),
	red = hex_to_argb(p.red.base),
	red_muted = hex_to_argb(p.red.muted),
	pink = hex_to_argb(p.pink.base),
}

return {
	black = palette.black,
	white = palette.white,
	red = palette.red_muted,
	green = palette.green_glow,
	blue = palette.blue,
	light_blue = palette.blue_light,
	yellow = palette.yellow_light,
	purple = palette.purple,
	orange = palette.yellow,
	transparent = 0x00000000,

	bar = {
		bg = hex_to_argb(p.bg.dark, 0xD0), -- with transparency
		border = palette.bg_light,
	},
	popup = {
		bg = palette.bg_dark,
		border = palette.gray_muted,
	},
	bg1 = palette.bg_dark,
	bg2 = palette.gray_muted,
}
