local M = {}

M.items = {
	CLOCK = "clock",
	SPACES = "spaces",
	AEROSPACE_MODE = "aerospace_mode",
	AEROSPACE_FULLSCREEN = "aerospace_fullscreen",
	GIT = "git",
}

M.events = {
	AEROSPACE_WORKSPACE_CHANGED = "aerospace_workspace_changed",
	AEROSPACE_SWITCH = "aerospace_switch",
	SWAP_MENU_AND_SPACES = "swap_menu_and_spaces",
	FRONT_APP_SWITCHED = "front_app_switched",
	UPDATE_WINDOWS = "update_windows",
	SEND_MODE = "send_mode",
	HIDE_MODE = "hide_mode",
	FULLSCREEN = "fullscreen",
	RIFT_WINDOWS_CHANGED = "rift_windows_changed",
	RIFT_LAYOUT_CHANGED = "rift_layout_changed",
	GIT_UPDATE = "git_update",
}

return M
