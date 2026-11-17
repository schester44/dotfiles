local colors = require("config.colors")
local style = require("config.styles").get()
local visibility = require("utils.bar_visibility")

-- Current/next calendar event, read from Dottt's event cache (no screen
-- capture). Hidden when nothing else is on today. See helpers/dottt_next.py.
-- A pill by the clock showing "󰭦 in 1h 2m"; hovering slides the title out
-- ("󰭦 Honeycomb in 1h 2m"). Two items under one bracket: dottt (icon + title)
-- and dottt.trailing (countdown).

local SCRIPT = os.getenv("CONFIG_DIR") .. "/helpers/dottt_next.py"

-- md-calendar_blank_outline
local ICON = "󰭦"
-- Collapsed title width: a sliver, so the icon's padding is the gap to the countdown
local COLLAPSED_W = 2
-- Space between an expanded title and the countdown
local GAP = 8
local CURVE, FRAMES = "tanh", 10

-- Space between this pill and the clock's, outside both brackets (a bracket's
-- background spans its members' padding, so padding would widen the pill)
local GAP_TO_CLOCK = 5

-- Right items lay out right to left: the gap and countdown first, so they stay nearest the clock
local gap = sbar.add("item", "dottt.gap", {
	position = "right",
	drawing = false,
	width = GAP_TO_CLOCK,
	padding_left = 0,
	padding_right = 0,
	icon = { drawing = false },
	label = { drawing = false },
	background = { drawing = false },
})

local trailing = sbar.add("item", "dottt.trailing", {
	position = "right",
	drawing = false,
	padding_left = 0,
	padding_right = 4,
	icon = { drawing = false },
	label = { padding_left = 0, padding_right = 14, color = colors.white, font = { size = 13.0 } },
	background = { drawing = false },
})

local dottt = sbar.add("item", "dottt", {
	position = "right",
	drawing = false,
	updates = true,
	update_freq = 60,
	padding_left = 6,
	padding_right = 0,
	icon = { string = ICON, color = colors.white, font = { size = 13.0 }, padding_left = 14, padding_right = 6 },
	label = { color = colors.white, padding_left = 0, padding_right = GAP },
	background = { drawing = false },
})

local background = sbar.add("bracket", "dottt.background", { "dottt", "dottt.trailing" }, {
	drawing = false,
	background = style.battery_own_pill and {
		color = style.battery_pill.color,
		corner_radius = style.battery_pill.corner_radius,
		height = style.battery_pill.height,
	} or { drawing = false },
})

visibility.slide("dottt", "dottt.trailing", "dottt.background")

local function set_drawing(on)
	for _, item in ipairs({ gap, dottt, trailing, background }) do
		item:set({ drawing = on })
	end
end

-- Collapse by animating the title's width to a sliver while fading it out.
-- Animates label.color.alpha only; don't set label.color while collapsed or
-- the text reappears.
local function collapse_pose(collapsed)
	dottt:set({
		label = { width = collapsed and COLLAPSED_W or "dynamic", color = { alpha = collapsed and 0 or 1 } },
	})
end

local function set_collapsed(collapsed)
	sbar.animate(CURVE, FRAMES, function()
		collapse_pose(collapsed)
	end)
end

local function update()
	sbar.exec("/usr/bin/python3 -I " .. SCRIPT, function(out)
		local line = type(out) == "string" and out:gsub("%s+$", "") or ""
		local title, time = line:match("^(.-)\t(.+)$")
		if not time then
			set_drawing(false)
			return
		end
		dottt:set({ label = { string = title } })
		trailing:set({ label = { string = time } })
		set_drawing(true)
	end)
end

-- The title and countdown are one hover target. Exit is deferred briefly so
-- crossing between their windows doesn't collapse and re-expand it.
local generation = 0
for _, item in ipairs({ dottt, trailing }) do
	item:subscribe("mouse.entered", function()
		generation = generation + 1
		set_collapsed(false)
	end)
	item:subscribe("mouse.exited", function()
		generation = generation + 1
		local pending = generation
		sbar.exec("sleep 0.05", function()
			if generation == pending then
				set_collapsed(true)
			end
		end)
	end)
end

collapse_pose(true)
dottt:subscribe({ "routine", "forced", "system_woke" }, update)
update()

return dottt
