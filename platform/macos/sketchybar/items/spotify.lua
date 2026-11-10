local colors = require("config.colors")
local style = require("config.styles").get()

-- Now playing (Spotify desktop). Visible while a track is loaded (playing or paused); paused is dimmed.

local MAX_LEN = 40
local DIM = 0x99ffffff
local EVENT = "spotify_change"

sbar.add("event", EVENT, "com.spotify.client.PlaybackStateChanged")

local spotify = sbar.add("item", "spotify", {
	position = "right",
	update_freq = 10,
	padding_left = 6,
	padding_right = 4,
	drawing = false,
	updates = true,
	icon = {
		string = "󰓇",
		color = colors.green,
		padding_left = 14,
		padding_right = 6,
	},
	label = {
		color = colors.white,
		padding_left = 0,
		padding_right = 14,
	},
	background = style.battery_own_pill and {
		color = style.battery_pill.color,
		corner_radius = style.battery_pill.corner_radius,
		height = style.battery_pill.height,
	} or { drawing = false },
})

-- Only query Spotify if it is already running (tell would otherwise launch it)
local QUERY = [[pgrep -x Spotify >/dev/null && osascript -e 'tell application "Spotify" to if player state is not stopped then return (player state as string) & "|" & (artist of current track) & " - " & (name of current track)' 2>/dev/null]]

local function truncate(s)
	if utf8.len(s) and utf8.len(s) > MAX_LEN then
		return s:sub(1, utf8.offset(s, MAX_LEN) - 1) .. "…"
	end
	return s
end

local function update()
	sbar.exec(QUERY, function(out)
		local text = type(out) == "string" and out:gsub("%s+$", "") or ""
		local state, track = text:match("^(%a+)|(.+)$")
		if track then
			local playing = state == "playing"
			spotify:set({
				drawing = true,
				icon = { color = playing and colors.green or DIM },
				label = { string = truncate(track), color = playing and colors.white or DIM },
			})
		else
			spotify:set({ drawing = false })
		end
	end)
end

spotify:subscribe({ EVENT, "routine", "forced", "system_woke" }, update)

spotify:subscribe("mouse.clicked", function()
	sbar.exec([[osascript -e 'tell application "Spotify" to playpause']], update)
end)

update()

-- Sit just left of the clock pill, outside its bracket span
if style.battery_own_pill then
	sbar.exec("sketchybar --move spotify after clock")
end
