local colors = require("config.colors")
local notch_chip = require("utils.notch_chip")

-- Current/next calendar event, read from Dottt's event cache (no screen
-- capture). Hidden when nothing else is on today. See helpers/dottt_next.py.
-- Left of the notch on notched displays, a pill by the clock elsewhere (utils/notch_chip.lua).

local SCRIPT = os.getenv("CONFIG_DIR") .. "/helpers/dottt_next.py"

-- md-calendar_blank_outline
local ICON = "󰭦"

local dottt = notch_chip.new("dottt", {
	side = "left",
	notch_overlap = 24, -- extend under the notch's bottom curve
	update_freq = 60,
	icon = { string = ICON, color = colors.white, font = { size = 13.0 } },
	label = { color = colors.white },
	-- Persistent suffix after the animated meeting title.
	trailing = { color = colors.white, font = { size = 13.0 } },
})

-- Shows just the countdown; hovering slides the meeting name out of the notch
local title, time = nil, nil

local function render()
	if not time then
		dottt:set({ drawing = false })
		return
	end
	-- Expanded: "󰭦 Honeycomb in 1h 2m"; collapsed: "󰭦 in 1h 2m".
	dottt:set({ drawing = true, label = { string = title }, trailing = { string = time } })
end

local function update()
	sbar.exec("/usr/bin/python3 -I " .. SCRIPT, function(out)
		local line = type(out) == "string" and out:gsub("%s+$", "") or ""
		title, time = line:match("^(.-)\t(.+)$")
		render()
	end)
end

dottt:subscribe({ "routine", "forced", "system_woke" }, update)
dottt:on_hover(function()
	dottt:set_collapsed(false)
end, function()
	dottt:set_collapsed(true)
end)
dottt:set_collapsed(true)
update()

return dottt
