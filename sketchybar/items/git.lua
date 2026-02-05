local constants = require("constants")
local colors = require("config.colors")

-- Register the custom event
sbar.add("event", "git_update")

-- Track git state and wezterm visibility
local git_state = {
	branch = "",
	dirty = false,
	added = 0,
	modified = 0,
	deleted = 0,
	wezterm_visible = false,
}

local git = sbar.add("item", constants.items.GIT, {
	position = "left",
	updates = "on",
	icon = {
		string = "",
		padding_left = 12,
		padding_right = 4,
	},
	label = {
		string = "",
		padding_left = 0,
		padding_right = 12,
	},
	background = {
		color = colors.transparent,
	},
	drawing = false,
})

local function update_git_display()
	if not git_state.wezterm_visible or git_state.branch == "" then
		git:set({ drawing = false })
		return
	end

	-- Hide branch name if it's main or master
	local label = ""
	if git_state.branch ~= "main" and git_state.branch ~= "master" then
		label = git_state.branch
	end

	-- Build change indicators: +added !modified -deleted
	local changes = {}
	if git_state.added > 0 then
		table.insert(changes, "+" .. git_state.added)
	end
	if git_state.modified > 0 then
		table.insert(changes, "!" .. git_state.modified)
	end
	if git_state.deleted > 0 then
		table.insert(changes, "-" .. git_state.deleted)
	end

	if #changes > 0 then
		label = label .. (label ~= "" and " " or "") .. table.concat(changes, " ")
	end

	git:set({
		drawing = true,
		icon = {
			string = "󰘬",
			color = git_state.dirty and colors.yellow or colors.green,
		},
		label = {
			string = label,
			color = git_state.dirty and colors.yellow or colors.green,
		},
	})
end

local function check_wezterm_in_workspace()
	sbar.exec("aerospace list-windows --workspace focused --format %{app-name}", function(windows)
		git_state.wezterm_visible = windows:find("WezTerm") ~= nil
		update_git_display()
	end)
end

git:subscribe(constants.events.GIT_UPDATE, function(env)
	git_state.branch = env.BRANCH or ""
	git_state.dirty = env.DIRTY == "true"
	git_state.added = tonumber(env.ADDED) or 0
	git_state.modified = tonumber(env.MODIFIED) or 0
	git_state.deleted = tonumber(env.DELETED) or 0
	update_git_display()
end)

git:subscribe(constants.events.AEROSPACE_WORKSPACE_CHANGED, function()
	check_wezterm_in_workspace()
end)

-- Initial check
check_wezterm_in_workspace()
