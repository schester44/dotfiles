-- A chip that is a regular pill on displays without a notch, and a black
-- extension of the notch on displays with one (left or right of it).
--
--   local chip = notch_chip.new("spotify", { side = "right", icon = {...}, label = {...}, ... })
--   chip:set({ drawing = true, label = { string = "..." } })  -- applies to both variants
--   chip:subscribe({ "routine" }, fn)                         -- events (on the pill item)
--   chip:on_click(fn)                                         -- clicks on either variant
--   chip:on_hover(enter_fn, exit_fn)                          -- mouse enter/leave on either variant
--   chip:set_collapsed(true)                                  -- animate the label away
--
-- When the bar hides (utils/bar_visibility.lua) the notch variant shrinks into
-- the notch and the pill slides up with the rest of the bar.
--
-- Items per chip: <name> (pill, top right), <name>.notch and <name>.notch.corner.
-- Which displays get which variant is re-detected on display_change.
--
-- SketchyBar geometry the notch variant relies on (v2.24 source):
--  * each item is its own window, bar-tall and item-wide, so anything drawn
--    outside the item's span is clipped. The background is shifted away from
--    the notch by R so its rounded corner on the notch side is clipped off
--    (straight edge), and the item starts OVERLAP points under the notch so the
--    notch's own bottom curve doesn't leave a gap.
--  * a background's top is computed as `y - height/2` in unsigned ints, with y
--    = bar.height/2 + item y_offset. Taller than ~2y and it wraps and vanishes.
--    So the item is lifted by LIFT (text pushed back down by LIFT), which lets
--    the background run past the screen top, where the window clips it and its
--    top corners disappear.
--  * a border insets the fill by border_width/2 on every side, so a 1pt
--    invisible border is the only way to get a half-point (1px) edge.
--  * PNG images render at pixel size * image.scale, are placed on whole points
--    by image.padding_left / image.y_offset, and ignore the background's offsets.
--  * negative item padding is allowed and moves the next item's window.
--
-- The corner item draws an inverted corner image at the background's top
-- outer edge, so it sweeps out along the screen top like the notch's own
-- corners (SketchyBar can only round corners outward).

local styles = require("config.styles")
local visibility = require("utils.bar_visibility")
local style = styles.get()

local M = {}

local NOTCH = styles.notch
local R = NOTCH.radius
local BAR_H = style.bar.height
-- Points the chip starts under the notch, to cover the notch's bottom curve
local OVERLAP = 6
-- Bottom edge of the black, in points from the screen top (the border insets it another 0.5)
local BOTTOM = NOTCH.height + 1
local LIFT = 10
-- Inverted corner radius
local CR = 5
-- Images land on whole points; an odd CR gets a 1pt solid strip on top that sits off-screen
local CR_PAD = CR % 2
-- Text inset from the black's outer edge / from the notch
local TEXT_PAD = 12
-- Label widths when collapsed to just the icon, past the icon's 6pt right
-- padding: the pill keeps 14pt; right of the notch the black ends R short of the
-- item; left of it the item runs OVERLAP under the notch
local COLLAPSED_W = { pill = 14 - 6, right = TEXT_PAD - 6 + R, left = TEXT_PAD - 6 + OVERLAP }
local COLLAPSE_CURVE, COLLAPSE_FRAMES = "tanh", 10
-- The notch fill: wider than the notch by GROW, moved right by SHIFT
local FILL_GROW, FILL_SHIFT = 0, 1

local CACHE_DIR = os.getenv("HOME") .. "/.cache/sketchybar"
local CORNER_SCRIPT = os.getenv("CONFIG_DIR") .. "/helpers/notch_corner.py"
local DISPLAYS_SCRIPT = os.getenv("CONFIG_DIR") .. "/helpers/notch_displays.js"

local chips = {}
-- arrangement ids, as comma-separated strings ("" = none)
local displays = { notch = "", plain = "" }

local function corner_png(side)
	local path = CACHE_DIR .. "/notch_corner_" .. side .. ".png"
	-- The square part stops 0.5 short: the background's edge is inset 0.5 by its border.
	-- On the left the image is mirrored, so lead it with 0.5 of transparency to line up.
	os.execute(
		string.format(
			"mkdir -p %q && /usr/bin/python3 -I %q %g %d %d %g %s %q",
			CACHE_DIR,
			CORNER_SCRIPT,
			R - 0.5,
			CR,
			CR_PAD,
			side == "left" and 0.5 or 0,
			side,
			path
		)
	)
	return path
end

local function pill_props(opts)
	return {
		position = "right",
		padding_left = 6,
		padding_right = 4,
		icon = { padding_left = 14, padding_right = 6 },
		label = { padding_left = 0, padding_right = 14 },
		background = style.battery_own_pill and {
			color = style.battery_pill.color,
			corner_radius = style.battery_pill.corner_radius,
			height = style.battery_pill.height,
		} or { drawing = false },
	}
end

local function notch_props(side)
	local right = side == "right"
	return {
		-- "e" grows rightward from the notch's right edge, "q" leftward from its left edge
		position = right and "e" or "q",
		padding_left = right and -OVERLAP or 0,
		padding_right = right and 0 or -OVERLAP,
		y_offset = LIFT,
		icon = {
			padding_left = TEXT_PAD + (right and OVERLAP or R),
			padding_right = 6,
			y_offset = -LIFT,
		},
		label = {
			padding_left = 0,
			padding_right = TEXT_PAD + (right and R or OVERLAP),
			y_offset = -LIFT,
		},
		background = {
			drawing = true,
			color = 0xff000000,
			corner_radius = R,
			border_width = 1,
			border_color = 0x00000000,
			-- origin.y = (BAR_H/2 + LIFT) - height/2 = 0, so y_offset is the bottom edge (from the window bottom)
			height = BAR_H + 2 * LIFT,
			y_offset = BAR_H - BOTTOM,
			x_offset = right and -R or R,
		},
	}
end

local function corner_props(side)
	local right = side == "right"
	return {
		position = right and "e" or "q",
		drawing = false,
		width = R + CR,
		-- the background's outer edge is R in from the chip's outer edge; start
		-- (right) / end (left) the corner window R further in, over the black
		padding_left = right and -2 * R or 0,
		padding_right = right and 0 or -2 * R,
		icon = { drawing = false },
		label = { drawing = false },
		background = {
			drawing = true,
			color = 0x00000000,
			border_width = 0,
			image = {
				string = corner_png(side),
				drawing = true,
				-- drawn at 2x (retina)
				scale = 0.5,
				-- centered on BAR_H/2 by default; lift it so the curve's top meets
				-- the screen top (the pad strip goes above it)
				y_offset = math.floor(BAR_H / 2 - (CR + CR_PAD) / 2 + CR_PAD),
			},
		},
	}
end

-- 0xAARRGGBB -> 0..1
local function alpha_of(color)
	return ((color >> 24) & 0xff) / 255
end

local function merge(into, from)
	for k, v in pairs(from) do
		if type(v) == "table" and type(into[k]) == "table" then
			merge(into[k], v)
		else
			into[k] = v
		end
	end
	return into
end

local Chip = {}
Chip.__index = Chip

function Chip:apply_displays()
	local pill_on = self.visible and displays.plain ~= ""
	local notch_on = self.visible and displays.notch ~= ""
	local pill = { drawing = pill_on }
	local notch = { drawing = notch_on }
	if pill_on then
		pill.display = displays.plain
	end
	if notch_on then
		notch.display = displays.notch
	end
	self.pill:set(pill)
	self.notch:set(notch)
	self.corner:set(notch)
end

-- props: item properties for both variants; `drawing` is the chip's visibility
function Chip:set(props)
	local content = {}
	for k, v in pairs(props) do
		if k ~= "drawing" then
			content[k] = v
		end
	end
	if props.icon and type(props.icon.color) == "number" then
		self.icon_alpha = alpha_of(props.icon.color)
	end
	if next(content) then
		self.pill:set(content)
		self.notch:set(content)
	end
	if props.drawing ~= nil and props.drawing ~= self.visible then
		self.visible = props.drawing
		self:apply_displays()
	end
end

-- Collapse to the icon by animating the label's width to almost nothing (the
-- chip's outer edge slides into the notch) while fading the text out, so the
-- part that overflows the shrinking black never shows. Expanding reverses it.
-- The fade animates label.color.alpha only; don't set label.color while
-- collapsed or the text reappears.
function Chip:set_collapsed(collapsed)
	if self.collapsed == collapsed then
		return
	end
	local first = self.collapsed == nil
	self.collapsed = collapsed
	local alpha = collapsed and 0 or 1
	local pill_w = COLLAPSED_W.pill
	local notch_w = COLLAPSED_W[self.side]
	local function go()
		self.pill:set({ label = { width = collapsed and pill_w or "dynamic", color = { alpha = alpha } } })
		-- while tucked the label stays at nothing; untucking applies this state
		if not self.tucked then
			self.notch:set({ label = { width = collapsed and notch_w or "dynamic", color = { alpha = alpha } } })
		end
	end
	if first then
		go()
	else
		sbar.animate(COLLAPSE_CURVE, COLLAPSE_FRAMES, go)
	end
end

-- Tuck the notch variant into the notch: every width and text inset animates
-- to nothing while the text fades, so the black's outer edge runs in under the
-- notch and the corner follows it. Untucking restores the collapsed / expanded
-- pose. Call inside sbar.animate.
function Chip:set_tucked(tucked)
	self.tucked = tucked
	local rest = self.rest
	if tucked then
		local gone = { width = 0, padding_left = 0, padding_right = 0, color = { alpha = 0 } }
		self.notch:set({ icon = gone, label = gone })
		return
	end
	local collapsed = self.collapsed
	local collapsed_w = COLLAPSED_W[self.side]
	self.notch:set({
		icon = {
			width = "dynamic",
			padding_left = rest.icon.padding_left,
			padding_right = rest.icon.padding_right,
			color = { alpha = self.icon_alpha },
		},
		label = {
			width = collapsed and collapsed_w or "dynamic",
			padding_left = rest.label.padding_left,
			padding_right = rest.label.padding_right,
			color = { alpha = collapsed and 0 or 1 },
		},
	})
end

function Chip:subscribe(events, fn)
	self.pill:subscribe(events, fn)
end

function Chip:on_click(fn)
	self.pill:subscribe("mouse.clicked", fn)
	self.notch:subscribe("mouse.clicked", fn)
end

function Chip:on_hover(enter, exit)
	for _, item in ipairs({ self.pill, self.notch }) do
		item:subscribe("mouse.entered", enter)
		item:subscribe("mouse.exited", exit)
	end
end

-- opts: side ("left" | "right" of the notch), icon, label, update_freq
function M.new(name, opts)
	local content = { icon = opts.icon or {}, label = opts.label or {} }

	local pill = merge(pill_props(opts), {
		drawing = false,
		updates = true,
		update_freq = opts.update_freq,
	})
	local notch = merge(notch_props(opts.side), { drawing = false })

	local chip = setmetatable({ name = name, side = opts.side, visible = false }, Chip)
	chip.icon_alpha = type(content.icon.color) == "number" and alpha_of(content.icon.color) or 1
	chip.pill = sbar.add("item", name, merge(pill, content))
	chip.notch = sbar.add("item", name .. ".notch", merge(notch, content))
	-- the notch variant's text insets when shown, for untucking
	chip.rest = {
		icon = { padding_left = notch.icon.padding_left, padding_right = notch.icon.padding_right },
		label = { padding_left = notch.label.padding_left, padding_right = notch.label.padding_right },
	}
	visibility.slide(name)
	-- added after the chip, so it sits on the chip's outer side
	chip.corner = sbar.add("item", name .. ".notch.corner", corner_props(opts.side))
	table.insert(chips, chip)
	return chip
end

-- Solid black over the notch itself, down to the chips' bottom edge. The
-- hardware hides it, but screenshots and screen sharing capture that area, where
-- the chips would otherwise float apart. Its bottom corners are rounded like the
-- notch's; a chip's black overlaps them on its side. Created before any chip so
-- it is the first "e" item, then pulled back over the notch by its own width.
-- The width comes from an empty fixed-width label: an item with a fixed width
-- of its own advances the next item by that width whatever its padding.
local FILL_W = NOTCH.width + FILL_GROW
local fill = sbar.add("item", "notch_chip.fill", {
	position = "e",
	drawing = false,
	padding_left = -FILL_W + FILL_SHIFT,
	padding_right = -FILL_SHIFT,
	y_offset = LIFT,
	icon = { drawing = false },
	label = { string = "", width = FILL_W, padding_left = 0, padding_right = 0 },
	background = {
		drawing = true,
		color = 0xff000000,
		corner_radius = R,
		border_width = 1,
		border_color = 0x00000000,
		height = BAR_H + 2 * LIFT,
		y_offset = BAR_H - BOTTOM,
	},
})

-- Display detection: notch screens via NSScreen (helpers/notch_displays.js),
-- mapped to SketchyBar arrangement ids through `sketchybar --query displays`.
local function detect()
	sbar.exec("/usr/bin/osascript -l JavaScript " .. DISPLAYS_SCRIPT, function(notch_out)
		local notched = {}
		for id in tostring(notch_out):gmatch("%d+") do
			notched[tonumber(id)] = true
		end
		sbar.exec("sketchybar --query displays", function(list)
			local notch_ids, plain_ids = {}, {}
			if type(list) == "table" then
				for _, d in ipairs(list) do
					local arr = d["arrangement-id"]
					if notched[d["DirectDisplayID"]] then
						table.insert(notch_ids, arr)
					else
						table.insert(plain_ids, arr)
					end
				end
			end
			displays.notch = table.concat(notch_ids, ",")
			displays.plain = table.concat(plain_ids, ",")
			if displays.notch ~= "" then
				fill:set({ drawing = true, display = displays.notch })
			else
				fill:set({ drawing = false })
			end
			for _, chip in ipairs(chips) do
				chip:apply_displays()
			end
		end)
	end)
end

visibility.on_change(function(hidden)
	for _, chip in ipairs(chips) do
		chip:set_tucked(hidden)
	end
end)

local watcher = sbar.add("item", "notch_chip.watcher", { drawing = false, updates = true })
watcher:subscribe({ "display_change", "system_woke", "forced" }, detect)
detect()

return M
