local constants = require("constants")
local colors = require("config.colors")
local icons = require("config.icons")

local spaces = {}

local currentWorkspaceWatcher = sbar.add("item", {
	drawing = false,
	updates = true,
})

local spaceConfigs = {
	["1"] = { icon = icons.terminal, name = "Terminal", bg_color = colors.yellow },
	["2"] = { icon = icons.chrome, name = "Browser", bg_color = colors.green },
	["3"] = { icon = icons.db, name = "Database", bg_color = colors.yellow },
	["4"] = { icon = icons.utils, name = "Utils", bg_color = colors.red },
	["5"] = { icon = icons.chatgpt, name = "ChatGPT", bg_color = colors.blue },
	["S"] = { icon = icons.slack, name = "Slack", bg_color = colors.purple },
	["P"] = { icon = icons.personal, name = "Personal", bg_color = colors.light_blue },
}

local function updateWorkSpaces(focusedWorkspaceName)
	for sid, item in pairs(spaces) do
		if item ~= nil then
			local isSelected = sid == constants.items.SPACES .. "." .. focusedWorkspaceName

			local key = sid.gsub(sid, constants.items.SPACES .. ".", "")

			local spaceConfig = spaceConfigs[key]

			item:set({
				icon = {
					string = spaceConfig.icon,
					color = isSelected and colors.black or spaceConfig.bg_color,
					padding_left = 12,
					padding_right = 4,
				},
				label = {
					string = isSelected and spaceConfig.name or key,
					color = isSelected and colors.black or colors.white,
					padding_right = 12,
				},
				background = { color = isSelected and spaceConfig.bg_color or colors.bg1 },
			})
		end
	end

	sbar.trigger(constants.events.UPDATE_WINDOWS)
end

local function findAndSelectCurrentWorkspace()
	sbar.exec(constants.aerospace.GET_CURRENT_WORKSPACE, function(focusedWorkspaceOutput)
		local focusedWorkspaceName = focusedWorkspaceOutput:match("[^\r\n]+")
		updateWorkSpaces(focusedWorkspaceName)
	end)
end

local function addWorkspaceItem(workspaceName)
	local spaceName = constants.items.SPACES .. "." .. workspaceName
	local spaceConfig = spaceConfigs[workspaceName]

	spaces[spaceName] = sbar.add("item", spaceName, {
		label = {
			string = spaceConfig.name or workspaceName,
		},
		icon = {
			color = colors.white,
		},
		background = {
			color = colors.bg1,
		},
		click_script = "aerospace workspace " .. workspaceName,
	})

	sbar.add("item", spaceName .. ".padding", {
		width = 4,
	})
end

local function createWorkspaces()
	sbar.exec(constants.aerospace.LIST_ALL_WORKSPACES, function(workspacesOutput)
		for workspaceName in workspacesOutput:gmatch("[^\r\n]+") do
			addWorkspaceItem(workspaceName)
		end

		findAndSelectCurrentWorkspace()
	end)
end

currentWorkspaceWatcher:subscribe(constants.events.AEROSPACE_WORKSPACE_CHANGED, function(env)
	updateWorkSpaces(env.FOCUSED_WORKSPACE)
	sbar.trigger(constants.events.UPDATE_WINDOWS)
end)

createWorkspaces()
