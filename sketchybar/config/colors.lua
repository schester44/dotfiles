-- Graphite theme colors for sketchybar
-- Format: 0xAARRGGBB (AA = alpha)

local palette = {
	-- backgrounds
	bg = 0xff1a1a1e,
	bg_dark = 0xff101012,
	bg_light = 0xff2a2a2e,
	bg_muted = 0xff222226,

	-- grays
	black = 0xff1C1C1C,
	white = 0xffFFFFFF,
	gray = 0xff808080,
	gray_dark = 0xff444444,
	gray_light = 0xff9E9E9E,
	gray_muted = 0xff626262,

	-- colors
	yellow = 0xffd4b870,
	yellow_light = 0xffe0cfa0,
	green = 0xff5fcf9f,
	green_glow = 0xff1bfd9c,
	blue = 0xff8fbfdc,
	blue_light = 0xff80FCFF,
	purple = 0xff967EFB,
	red = 0xffFF6B6B,
	red_muted = 0xffE57373,
	pink = 0xffFF628C,
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
		bg = 0xD0101012,
		border = 0xff2a2a2e,
	},
	popup = {
		bg = palette.bg_dark,
		border = palette.gray_muted,
	},
	bg1 = palette.bg_dark,
	bg2 = palette.gray_muted,
}
