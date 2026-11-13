-- Left side items
require("items.rift_spaces")
require("items.rift_layout")

-- Right side items
require("items.mode")
require("items.clock")
require("items.battery")
require("items.spotify")
require("items.dottt")

-- Standalone pills sit left of (outside) the clock pill's span, or the bracket
-- draws around them. One command so the moves apply in order; each lands next
-- to the clock, so the last is closest: clock, dottt, spotify, battery.
if require("config.styles").get().battery_own_pill then
	sbar.exec("sketchybar --move battery after clock --move spotify after clock --move dottt.trailing after clock --move dottt after dottt.trailing")
end
