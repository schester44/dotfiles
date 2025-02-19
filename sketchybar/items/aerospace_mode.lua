local constants = require("constants")
local colors = require("config.colors")

local mode = sbar.add("item", constants.items.AEROSPACE_MODE, {
	width = 0,
	position = "center",
	popup = { align = "center" },
	label = {
		padding_left = 0,
		padding_right = 0,
	},
	background = {
		padding_left = 0,
		padding_right = 0,
	},
})

local messagePopup = sbar.add("item", {
	position = "popup." .. mode.name,
	width = "dynamic",
	background = {
		color = colors.red,
	},
	label = {
		padding_right = 12,
		padding_left = 4,
	},
	icon = {
		padding_left = 12,
		padding_right = 0,
	},
})

local function hideMessage()
	mode:set({ popup = { drawing = false } })
end

local function showMessage(content, hold)
	hideMessage()

	mode:set({ popup = { drawing = true } })
	messagePopup:set({ icon = { string = "󰀝" }, label = { string = content } })

	if hold == false then
		sbar.delay(5, function()
			if hold then
				return
			end
			hideMessage()
		end)
	end
end

mode:subscribe(constants.events.SEND_MODE, function(env)
	local content = env.MESSAGE
	local hold = env.HOLD ~= nil and env.HOLD == "true" or false
	showMessage(content, hold)
end)

mode:subscribe(constants.events.HIDE_MODE, hideMessage)
