package main

import (
	"context"
	"os/exec"
	"strconv"
	"strings"
	"sync"
	"time"
)

type GitInfo struct {
	Root         string `json:"root"`
	Branch       string `json:"branch"`
	ChangedFiles int    `json:"changedFiles"`
	Untracked    int    `json:"untracked"`
	Additions    int    `json:"additions"`
	Deletions    int    `json:"deletions"`
	Ahead        int    `json:"ahead"`
	Behind       int    `json:"behind"`
}

type cachedGitInfo struct {
	info      *GitInfo
	refreshed time.Time
}

var gitCache = struct {
	sync.Mutex
	byCWD map[string]cachedGitInfo
}{byCWD: make(map[string]cachedGitInfo)}

func gitInfo(cwd string) *GitInfo {
	if cwd == "" {
		return nil
	}
	gitCache.Lock()
	cached, ok := gitCache.byCWD[cwd]
	if ok && time.Since(cached.refreshed) < 3*time.Second {
		gitCache.Unlock()
		return cached.info
	}
	gitCache.Unlock()

	info := loadGitInfo(cwd)
	gitCache.Lock()
	gitCache.byCWD[cwd] = cachedGitInfo{info: info, refreshed: time.Now()}
	gitCache.Unlock()
	return info
}

func loadGitInfo(cwd string) *GitInfo {
	root, ok := runGit(cwd, "rev-parse", "--show-toplevel")
	if !ok {
		return nil
	}
	status, ok := runGit(cwd, "status", "--porcelain=v1", "--branch", "--untracked-files=normal")
	if !ok {
		return nil
	}
	info := &GitInfo{Root: strings.TrimSpace(root)}
	lines := strings.Split(strings.TrimRight(status, "\n"), "\n")
	if len(lines) > 0 && strings.HasPrefix(lines[0], "## ") {
		parseBranchLine(info, strings.TrimPrefix(lines[0], "## "))
		lines = lines[1:]
	}
	for _, line := range lines {
		if len(line) < 2 {
			continue
		}
		info.ChangedFiles++
		if strings.HasPrefix(line, "??") {
			info.Untracked++
		}
	}

	numstat, ok := runGit(cwd, "diff", "--numstat", "HEAD", "--")
	if !ok {
		numstat, _ = runGit(cwd, "diff", "--numstat", "--")
	}
	for _, line := range strings.Split(strings.TrimSpace(numstat), "\n") {
		fields := strings.SplitN(line, "\t", 3)
		if len(fields) < 2 {
			continue
		}
		if additions, err := strconv.Atoi(fields[0]); err == nil {
			info.Additions += additions
		}
		if deletions, err := strconv.Atoi(fields[1]); err == nil {
			info.Deletions += deletions
		}
	}
	return info
}

func parseBranchLine(info *GitInfo, line string) {
	if strings.HasPrefix(line, "No commits yet on ") {
		line = strings.TrimPrefix(line, "No commits yet on ")
	} else if strings.HasPrefix(line, "Initial commit on ") {
		line = strings.TrimPrefix(line, "Initial commit on ")
	}
	nameAndTracking := strings.SplitN(line, " ", 2)
	info.Branch = strings.SplitN(nameAndTracking[0], "...", 2)[0]
	if info.Branch == "HEAD" || info.Branch == "HEAD (no branch)" {
		info.Branch = "detached"
	}
	if len(nameAndTracking) < 2 {
		return
	}
	tracking := strings.Trim(nameAndTracking[1], "[]")
	for _, part := range strings.Split(tracking, ",") {
		fields := strings.Fields(strings.TrimSpace(part))
		if len(fields) != 2 {
			continue
		}
		value, _ := strconv.Atoi(fields[1])
		switch fields[0] {
		case "ahead":
			info.Ahead = value
		case "behind":
			info.Behind = value
		}
	}
}

func runGit(cwd string, args ...string) (string, bool) {
	ctx, cancel := context.WithTimeout(context.Background(), 1500*time.Millisecond)
	defer cancel()
	commandArgs := append([]string{"-C", cwd}, args...)
	output, err := exec.CommandContext(ctx, "git", commandArgs...).Output()
	return string(output), err == nil && ctx.Err() == nil
}
