local wezzy = require("wezzy")

local config = wezzy.setup({
	window = {
		opacity = 0.8,
	},

	wezterm = function(config)
		require("theme").apply(config)
		config.enable_kitty_keyboard = true
		config.audible_bell = "SystemBeep"
	end,

	plugins = { "https://github.com/smart-splits-nvim/backend-wezterm" },

	workspaces = {
		{ name = "neverwait", cwd = "~/work/neverwait" },
		{ name = "wezzy",     cwd = "~/work/wezzy" },
	},
})

-- smart-splits' keys, named for Settings → Shortcuts
for key, dir in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
	wezzy.name("ctrl+" .. key, "Move " .. dir)
	wezzy.name("alt+" .. key, "Resize " .. dir)
end

-- Leader 1..9: go to that window (the numbered chips in the top bar)
for i = 1, 9 do
	wezzy.bind("leader+" .. i, wezzy.action.ActivateWindow(i - 1))
end

wezzy.bind("cmd+shift+m", function(window, pane)
	window:perform_action(
		wezzy.action.SpawnCommandInNewPane({
			cwd = os.getenv("HOME") .. "/Documents/vaults/primary",
			args = {
				os.getenv("SHELL") or "/bin/zsh",
				"-lc",
				"exec nvim",
			},
		}),
		pane
	)
end, "Notes vault")

-- Cmd-d: Diffview in a new tab. Asks which worktree (skipped when there's only
-- one), then what to compare against. Diffview runs inside the picked worktree,
-- so its uncommitted changes show and edits land there.
local function git(dir, ...)
	local ok, out = wezzy.wezterm.run_child_process({ "git", "-C", dir, ... })
	return ok and out:gsub("%s+$", "") or nil
end

local function shell_quote(s)
	return "'" .. s:gsub("'", [['\'']]) .. "'"
end

local function open_diff(window, pane, dir, cmd)
	window:perform_action(
		wezzy.action.SpawnCommandInNewTab({
			cwd = dir,
			args = { os.getenv("SHELL") or "/bin/zsh", "-lc", cmd },
		}),
		pane
	)
end

-- step 2: what to compare the worktree against
local function pick_base(window, pane, dir)
	local branch = git(dir, "branch", "--show-current") or ""
	local origin_default = git(dir, "rev-parse", "--abbrev-ref", "origin/HEAD") -- "origin/main"
	local default = origin_default and origin_default:gsub("^origin/", "") or "main"
	local upstream = git(dir, "rev-parse", "--abbrev-ref", "@{upstream}")

	local choices = {}
	local seen = {}
	local function vs(ref)
		if ref and not seen[ref] and ref ~= branch and git(dir, "rev-parse", "--verify", "--quiet", ref) then
			seen[ref] = true
			table.insert(choices, { id = "base:" .. ref, label = "Changes vs " .. ref })
		end
	end
	vs(default)
	vs(origin_default)
	vs(upstream)
	table.insert(choices, { id = "uncommitted", label = "Uncommitted changes" })
	if #choices > 1 then
		local ref = choices[1].id:gsub("^base:", "")
		table.insert(choices, { id = "history:" .. ref, label = "Commits since " .. ref })
	end

	window:perform_action(
		wezzy.action.InputSelector({
			title = branch ~= "" and ("Diff " .. branch) or "Diff",
			choices = choices,
			action = wezzy.action_callback(function(window, pane, id)
				if not id then
					return
				end
				local kind, ref = id:match("^(%w+):?(.*)$")
				local cmd
				if kind == "base" then
					cmd = "base=$(git merge-base HEAD " .. shell_quote(ref) .. ') && exec nvim -c "DiffviewOpen $base"'
				elseif kind == "history" then
					cmd = "base=$(git merge-base HEAD " ..
							shell_quote(ref) .. ') && exec nvim -c "DiffviewFileHistory --range=$base..HEAD"'
				else
					cmd = 'exec nvim -c "DiffviewOpen"'
				end
				open_diff(window, pane, dir, cmd)
			end),
		}),
		pane
	)
end

wezzy.bind("cmd+d", function(window, pane)
	local cwd = pane:get_current_working_dir()
	local here = cwd and cwd.file_path or wezzy.wezterm.home_dir
	local top = git(here, "rev-parse", "--show-toplevel")
	if not top then
		return open_diff(window, pane, here, 'exec nvim -c "DiffviewOpen"')
	end

	-- step 1: which worktree (this one first)
	local home = wezzy.wezterm.home_dir
	local choices = {}
	local path
	for line in (git(top, "worktree", "list", "--porcelain") or ""):gmatch("[^\n]+") do
		local p = line:match("^worktree (.+)")
		if p then
			path = p
		end
		local b = line:match("^branch refs/heads/(.+)")
		local detached = line == "detached"
		if path and (b or detached) then
			local entry = { id = path, label = (b or "detached") .. "\t" .. path:gsub("^" .. home:gsub("%p", "%%%0"), "~") }
			table.insert(choices, path == top and 1 or #choices + 1, entry)
			path = nil
		end
	end
	if #choices <= 1 then
		return pick_base(window, pane, top)
	end
	window:perform_action(
		wezzy.action.InputSelector({
			title = "Worktree",
			choices = choices,
			action = wezzy.action_callback(function(window, pane, id)
				if id then
					pick_base(window, pane, id)
				end
			end),
		}),
		pane
	)
end, "Diffview")

return config
