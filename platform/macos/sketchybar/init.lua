-- Require the sketchybar module
---@diagnostic disable-next-line: lowercase-global
sbar = require("sketchybar")

-- Bundle the entire initial configuration into a single message to sketchybar
-- This improves startup times drastically, try removing both the begin and end
-- config calls to see the difference -- yeah..
sbar.begin_config()

require("bar")
require("config.default")
require("items")
sbar.hotload(true)
sbar.end_config()

-- Our fork adds a cancellable dwell delay and hide / show events (animated in
-- utils/bar_visibility.lua); install with ./install-toggle.sh.
local visibility = require("utils.bar_visibility")
sbar.exec(
	'pkill -x sketchybar-toggle; "$HOME/.local/bin/sketchybar-toggle" --trigger-zone 4 --menu-bar-height 35 --debounce 1 --hide-delay 160'
		.. " --hide-event " .. visibility.HIDE_EVENT .. " --show-event " .. visibility.SHOW_EVENT .. " &")

-- Run the event loop of the sketchybar module (without this there will be no
-- callback functions executed in the lua module)
sbar.event_loop()
