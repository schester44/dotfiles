local colors = require("config.colors")
local notch_chip = require("utils.notch_chip")

-- Now playing (Spotify desktop). Visible while a track is loaded, icon-only
-- until hovered (the name slides out of the notch). Paused dims the icon;
-- click to play/pause.
-- Right of the notch on notched displays, a pill by the clock elsewhere (utils/notch_chip.lua).

local MAX_LEN = 40
local DIM = 0x99ffffff
local EVENT = "spotify_change"

sbar.add("event", EVENT, "com.spotify.client.PlaybackStateChanged")

local spotify = notch_chip.new("spotify", {
	side = "right",
	update_freq = 10,
	icon = { string = "󰓇", color = colors.green },
	label = { color = colors.white },
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
				label = { string = truncate(track) },
			})
		else
			spotify:set({ drawing = false })
		end
	end)
end

spotify:subscribe({ EVENT, "routine", "forced", "system_woke" }, update)
spotify:on_hover(function()
	spotify:set_collapsed(false)
end, function()
	spotify:set_collapsed(true)
end)
spotify:set_collapsed(true)

spotify:on_click(function()
	sbar.exec([[osascript -e 'tell application "Spotify" to playpause']], update)
end)

update()
