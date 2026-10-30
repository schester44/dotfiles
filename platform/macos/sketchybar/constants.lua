local M = {}

M.items = {
	CLOCK = "clock",
	SPACES = "spaces",
	MODE = "mode",
	GIT = "git",
}

M.events = {
	WORKSPACE_CHANGED = "rift_workspace_changed",
	SWAP_MENU_AND_SPACES = "swap_menu_and_spaces",
	FRONT_APP_SWITCHED = "front_app_switched",
	UPDATE_WINDOWS = "update_windows",
	SEND_MODE = "send_mode",
	HIDE_MODE = "hide_mode",
	RIFT_WINDOWS_CHANGED = "rift_windows_changed",
	RIFT_LAYOUT_CHANGED = "rift_layout_changed",
	GIT_UPDATE = "git_update",
}

return M
