-- Hides and shows the bar's contents for sketchybar-toggle, which triggers
-- HIDE_EVENT / SHOW_EVENT (its --hide-event / --show-event) instead of toggling
-- the bar itself. Hiding animates, then really hides the bar so the native menu
-- bar underneath gets the clicks; showing reverses it.
--
--   visibility.slide("clock", "right_container")  -- these slide up off the bar
--   visibility.on_change(function(hidden) ... end) -- custom pose, runs inside the animation
--
-- Animations on the same property queue in SketchyBar, so a show that arrives
-- mid-hide plays after it, from the hidden pose.

local style = require("config.styles").get()

local M = {}

M.HIDE_EVENT = "bar_visibility_hide"
M.SHOW_EVENT = "bar_visibility_show"

-- Short: the native menu bar is already sliding in
local CURVE, FRAMES = "tanh", 8

local sliders = {}
local hooks = {}
local hidden = false
local generation = 0

function M.slide(...)
	for _, name in ipairs({ ... }) do
		table.insert(sliders, name)
	end
end

function M.on_change(fn)
	table.insert(hooks, fn)
end

local function pose()
	-- items are bar-tall windows, so a bar's height up is fully clipped
	local y = hidden and style.bar.height or 0
	for _, name in ipairs(sliders) do
		sbar.set(name, { y_offset = y })
	end
	for _, fn in ipairs(hooks) do
		fn(hidden)
	end
end

local function hide()
	if hidden then
		return
	end
	hidden = true
	generation = generation + 1
	local pending = generation
	sbar.animate(CURVE, FRAMES, pose)
	-- frames are 60ths of a second
	sbar.delay(FRAMES / 60 + 0.05, function()
		if pending == generation then
			sbar.bar({ hidden = true })
		end
	end)
end

local function show()
	generation = generation + 1
	sbar.bar({ hidden = false })
	-- sketchybar-toggle also triggers this on startup, when nothing is hidden
	if hidden then
		hidden = false
		sbar.animate(CURVE, FRAMES, pose)
	end
end

sbar.add("event", M.HIDE_EVENT)
sbar.add("event", M.SHOW_EVENT)

local watcher = sbar.add("item", "bar_visibility.watcher", { drawing = false, updates = true })
watcher:subscribe(M.HIDE_EVENT, hide)
watcher:subscribe(M.SHOW_EVENT, show)

return M
