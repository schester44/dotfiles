local M = {}

M.items = {
	CLOCK = "clock",
	SPACES = "spaces",
	AEROSPACE_MODE = "aerospace_mode",
	-- this needs to match the name of the app
	DOTTT = "Dottt",
}

M.aerospace = {}

M.events = {
	AEROSPACE_WORKSPACE_CHANGED = "aerospace_workspace_changed",
	AEROSPACE_SWITCH = "aerospace_switch",
	SWAP_MENU_AND_SPACES = "swap_menu_and_spaces",
	FRONT_APP_SWITCHED = "front_app_switched",
	UPDATE_WINDOWS = "update_windows",
	SEND_MODE = "send_mode",
	HIDE_MODE = "hide_mode",
}

M.aerospace = {
	LIST_ALL_WORKSPACES = "aerospace list-workspaces --all",
	GET_CURRENT_WORKSPACE = "aerospace list-workspaces --focused",
	LIST_WINDOWS = 'aerospace list-windows --workspace focused --format "id=%{window-id}, name=%{app-name}"',
	GET_CURRENT_WINDOW = "aerospace list-windows --focused --format %{app-name}",
}

return M
