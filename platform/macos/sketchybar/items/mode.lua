local constants = require("constants")
local colors = require("config.colors")

-- Mode popup under the bar's center. Two shapes:
--   sketchybar --trigger send_mode MESSAGE='layout: bsp' [HOLD=true]
--   sketchybar --trigger send_mode TITLE='Layout' HINTS='t=traditional b=bsp esc=cancel' HOLD=true
-- HINTS renders each "key=name" as a keycap followed by its name.

local MAX_HINTS = 10
local KEY_COLOR = colors.yellow
local TEXT_COLOR = colors.white
local MUTED = colors.bg2

local mode = sbar.add("item", constants.items.MODE, {
	width = 0,
	position = "center",
	popup = {
		align = "center",
		horizontal = true,
		y_offset = 4,
		background = {
			color = colors.popup.bg,
			border_color = colors.popup.border,
			border_width = 1,
			corner_radius = 10,
			shadow = { drawing = true },
		},
	},
	label = { padding_left = 0, padding_right = 0 },
	background = { padding_left = 0, padding_right = 0 },
})

local function popup_item(props)
	local base = {
		position = "popup." .. mode.name,
		drawing = false,
		background = { drawing = false },
	}
	for k, v in pairs(props) do
		base[k] = v
	end
	return sbar.add("item", base)
end

-- Title / plain message: accent icon + text
local title = popup_item({
	icon = { string = "󰕰", color = KEY_COLOR, padding_left = 14, padding_right = 8 },
	label = { color = TEXT_COLOR, padding_left = 0, padding_right = 10 },
})

-- Thin divider between the title and the hints
local divider = popup_item({
	width = 1,
	icon = { drawing = false },
	label = { drawing = false },
	background = { drawing = true, color = MUTED, height = 14 },
	padding_left = 4,
	padding_right = 6,
})

local hints = {}
for i = 1, MAX_HINTS do
	hints[i] = popup_item({
		icon = {
			color = KEY_COLOR,
			padding_left = 6,
			padding_right = 6,
			background = { drawing = true, color = colors.bg1, border_color = MUTED, border_width = 1, corner_radius = 5, height = 20 },
		},
		label = { color = TEXT_COLOR, padding_left = 6, padding_right = 8 },
		padding_left = 4,
		padding_right = i == MAX_HINTS and 10 or 2,
	})
end

local function parse_hints(s)
	local out = {}
	for key, name in (s or ""):gmatch("(%S-)=(%S+)") do
		table.insert(out, { key = key, name = name:gsub("_", " ") })
	end
	return out
end

local hide_generation = 0

local function hideMessage()
	mode:set({ popup = { drawing = false } })
end

local function show(env)
	local list = parse_hints(env.HINTS)
	local text = (env.TITLE ~= nil and env.TITLE ~= "") and env.TITLE or env.MESSAGE or ""
	local hold = env.HOLD == "true"

	title:set({ drawing = true, label = { string = text, padding_right = #list > 0 and 10 or 14 } })
	divider:set({ drawing = #list > 0 })
	for i, item in ipairs(hints) do
		local h = list[i]
		if h then
			item:set({
				drawing = true,
				icon = { string = h.key },
				label = { string = h.name },
				-- the last visible hint closes the popup with some breathing room
				padding_right = i == #list and 10 or 2,
			})
		else
			item:set({ drawing = false })
		end
	end
	mode:set({ popup = { drawing = true } })

	hide_generation = hide_generation + 1
	if not hold then
		local gen = hide_generation
		sbar.delay(2, function()
			if gen == hide_generation then
				hideMessage()
			end
		end)
	end
end

mode:subscribe(constants.events.SEND_MODE, show)
mode:subscribe(constants.events.HIDE_MODE, hideMessage)
