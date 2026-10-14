local colors = require("config.colors")
local style = require("config.styles").get()

-- Conditional battery: only visible while discharging at <= 30%.
-- Invisible otherwise — the bar stays minimal until it matters.

local THRESHOLD = 30

local battery = sbar.add("item", "battery", {
	position = "right",
	update_freq = 120,
	padding_left = 6,
	icon = {
		string = "󰁺",
		color = colors.red,
		padding_left = 8,
		padding_right = 2,
	},
	label = {
		color = colors.white,
		padding_left = 0,
		padding_right = 8,
	},
	drawing = false,
	updates = true,
	background = style.battery_own_pill and {
		color = style.battery_pill.color,
		corner_radius = style.battery_pill.corner_radius,
		height = style.battery_pill.height,
	} or { drawing = false },
})

local function check()
	sbar.exec("pmset -g batt", function(out)
		local pct = tonumber(out:match("(%d+)%%"))
		local discharging = out:find("discharging") ~= nil
		local show = discharging and pct ~= nil and pct <= THRESHOLD

		if show then
			battery:set({
				drawing = true,
				icon = { string = pct <= 15 and "󰁺" or "󰁼" },
				label = { string = pct .. "%" },
			})
		else
			battery:set({ drawing = false })
		end
	end)
end

battery:subscribe({ "routine", "forced", "system_woke", "power_source_change" }, check)
check()

-- A standalone battery pill must sit left of (outside) the clock pill's span,
-- or the bracket draws around it (pill in a pill)
if style.battery_own_pill then
	sbar.exec("sketchybar --move battery after clock")
end
