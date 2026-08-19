package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/url"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
	"strconv"
	"strings"
	"syscall"
	"time"
)

type PaneSize struct {
	Rows        int     `json:"rows"`
	Cols        int     `json:"cols"`
	PixelWidth  int     `json:"pixel_width"`
	PixelHeight int     `json:"pixel_height"`
	DPI         float64 `json:"dpi"`
}

type WezTermPane struct {
	WindowID         int      `json:"window_id"`
	TabID            int      `json:"tab_id"`
	PaneID           int      `json:"pane_id"`
	Workspace        string   `json:"workspace"`
	Size             PaneSize `json:"size"`
	Title            string   `json:"title"`
	CWD              string   `json:"cwd"`
	CursorX          int      `json:"cursor_x"`
	CursorY          int      `json:"cursor_y"`
	CursorShape      string   `json:"cursor_shape"`
	CursorVisibility string   `json:"cursor_visibility"`
	LeftCol          int      `json:"left_col"`
	TopRow           int      `json:"top_row"`
	TabTitle         string   `json:"tab_title"`
	WindowTitle      string   `json:"window_title"`
	IsActive         bool     `json:"is_active"`
	IsZoomed         bool     `json:"is_zoomed"`
	TTYName          string   `json:"tty_name"`
}

type ModelInfo struct {
	Provider string `json:"provider"`
	ID       string `json:"id"`
}

type PiSession struct {
	Version       int        `json:"version"`
	InstanceID    string     `json:"instanceId"`
	PID           int        `json:"pid"`
	WezTermPane   string     `json:"weztermPane"`
	SessionID     string     `json:"sessionId"`
	SessionFile   string     `json:"sessionFile"`
	SessionName   string     `json:"sessionName"`
	CWD           string     `json:"cwd"`
	State         string     `json:"state"`
	Model         *ModelInfo `json:"model"`
	ThinkingLevel string     `json:"thinkingLevel"`
	EntryCount    int        `json:"entryCount"`
	ContextTokens *int       `json:"contextTokens"`
	ContextWindow *int       `json:"contextWindow"`
	UpdatedAt     time.Time  `json:"updatedAt"`
}

type LiveSession struct {
	Pane    WezTermPane `json:"wezterm"`
	Session PiSession   `json:"pi"`
	Git     *GitInfo    `json:"git,omitempty"`
}

func runtimeDir() (string, error) {
	home, err := os.UserHomeDir()
	if err != nil {
		return "", err
	}
	normalize := func(path string) (string, error) {
		expanded, err := expandHome(path)
		if err != nil {
			return "", err
		}
		if !filepath.IsAbs(expanded) {
			expanded = filepath.Join(home, expanded)
		}
		return filepath.Clean(expanded), nil
	}
	if dir := os.Getenv("WEZWORK_STATE_DIR"); dir != "" {
		dir, err = normalize(dir)
		if err != nil {
			return "", err
		}
		return filepath.Join(dir, "live"), nil
	}
	base := os.Getenv("XDG_STATE_HOME")
	if base == "" {
		base = filepath.Join(home, ".local", "state")
	} else if base, err = normalize(base); err != nil {
		return "", err
	}
	return filepath.Join(base, "wezwork", "live"), nil
}

func listLiveSessions() ([]LiveSession, error) {
	panes, err := listWezTermPanes()
	if err != nil {
		return nil, err
	}
	byID := make(map[int]WezTermPane, len(panes))
	for _, pane := range panes {
		byID[pane.PaneID] = pane
	}

	dir, err := runtimeDir()
	if err != nil {
		return nil, err
	}
	entries, err := os.ReadDir(dir)
	if os.IsNotExist(err) {
		return []LiveSession{}, nil
	}
	if err != nil {
		return nil, fmt.Errorf("read session registry: %w", err)
	}

	live := make([]LiveSession, 0, len(entries))
	for _, entry := range entries {
		if entry.IsDir() || filepath.Ext(entry.Name()) != ".json" {
			continue
		}
		path := filepath.Join(dir, entry.Name())
		info, err := entry.Info()
		if err != nil || info.Size() > 64*1024 {
			continue
		}
		data, err := os.ReadFile(path)
		if err != nil {
			continue
		}
		var session PiSession
		if json.Unmarshal(data, &session) != nil || session.Version != 1 || session.InstanceID == "" || session.PID <= 0 {
			continue
		}
		paneID, err := strconv.Atoi(session.WezTermPane)
		if err != nil {
			continue
		}
		pane, exists := byID[paneID]
		stale := session.UpdatedAt.IsZero() || time.Since(session.UpdatedAt) > 15*time.Second || time.Until(session.UpdatedAt) > time.Minute
		if !exists || stale || !processAlive(session.PID) {
			removeRegistryIfInstance(path, session.InstanceID)
			continue
		}
		sanitizeLiveSession(&pane, &session)
		live = append(live, LiveSession{Pane: pane, Session: session, Git: gitInfo(session.CWD)})
	}

	sort.Slice(live, func(i, j int) bool {
		if live[i].Pane.Workspace != live[j].Pane.Workspace {
			return live[i].Pane.Workspace < live[j].Pane.Workspace
		}
		return live[i].Pane.PaneID < live[j].Pane.PaneID
	})
	return live, nil
}

func removeRegistryIfInstance(path, instanceID string) {
	current, err := os.ReadFile(path)
	if err != nil {
		return
	}
	var record struct {
		InstanceID string `json:"instanceId"`
	}
	if json.Unmarshal(current, &record) == nil && record.InstanceID == instanceID {
		_ = os.Remove(path)
	}
}

func listWezTermPanes() ([]WezTermPane, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()
	command := exec.CommandContext(ctx, "wezterm", "cli", "list", "--format", "json")
	output, err := command.Output()
	if err != nil {
		if ctx.Err() != nil {
			return nil, fmt.Errorf("wezterm cli list timed out: %w", ctx.Err())
		}
		if exit, ok := err.(*exec.ExitError); ok {
			return nil, fmt.Errorf("wezterm cli list: %s", strings.TrimSpace(string(exit.Stderr)))
		}
		return nil, fmt.Errorf("run wezterm: %w", err)
	}
	var panes []WezTermPane
	if err := json.Unmarshal(output, &panes); err != nil {
		return nil, fmt.Errorf("parse wezterm pane list: %w", err)
	}
	return panes, nil
}

func activatePane(paneID int) error {
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()
	command := exec.CommandContext(ctx, "wezterm", "cli", "activate-pane", "--pane-id", strconv.Itoa(paneID))
	if output, err := command.CombinedOutput(); err != nil {
		if ctx.Err() != nil {
			return fmt.Errorf("activate pane %d timed out: %w", paneID, ctx.Err())
		}
		return fmt.Errorf("activate pane %d: %s", paneID, strings.TrimSpace(string(output)))
	}
	return nil
}

func processAlive(pid int) bool {
	process, err := os.FindProcess(pid)
	if err != nil {
		return false
	}
	return process.Signal(syscall.Signal(0)) == nil
}

func displayCWD(raw string) string {
	parsed, err := url.Parse(raw)
	if err == nil && parsed.Scheme == "file" {
		if path, err := url.PathUnescape(parsed.Path); err == nil {
			return path
		}
	}
	return raw
}

func projectName(path string) string {
	path = strings.TrimSuffix(path, string(filepath.Separator))
	if path == "" {
		return "-"
	}
	return filepath.Base(path)
}

func sanitize(value string) string {
	return strings.Map(func(r rune) rune {
		if r < 0x20 || r == 0x7f {
			return ' '
		}
		return r
	}, value)
}

func sanitizeLiveSession(pane *WezTermPane, session *PiSession) {
	pane.Workspace = sanitize(pane.Workspace)
	pane.Title = sanitize(pane.Title)
	pane.CWD = sanitize(pane.CWD)
	pane.TabTitle = sanitize(pane.TabTitle)
	pane.WindowTitle = sanitize(pane.WindowTitle)
	pane.TTYName = sanitize(pane.TTYName)
	session.SessionID = sanitize(session.SessionID)
	session.SessionFile = sanitize(session.SessionFile)
	session.SessionName = sanitize(session.SessionName)
	session.CWD = sanitize(session.CWD)
	session.State = sanitize(session.State)
	session.ThinkingLevel = sanitize(session.ThinkingLevel)
	if session.Model != nil {
		session.Model.Provider = sanitize(session.Model.Provider)
		session.Model.ID = sanitize(session.Model.ID)
	}
}
