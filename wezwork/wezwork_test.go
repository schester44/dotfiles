package main

import (
	"encoding/json"
	"os"
	"path/filepath"
	"runtime"
	"strings"
	"testing"
	"time"
)

func TestExtensionInstallAndUninstall(t *testing.T) {
	dir := t.TempDir()
	t.Setenv("PI_CODING_AGENT_DIR", dir)

	path, changed, err := ensureExtension(false)
	if err != nil || !changed {
		t.Fatalf("install: changed=%v err=%v", changed, err)
	}
	data, err := os.ReadFile(path)
	if err != nil || string(data) != string(extensionSource) {
		t.Fatalf("installed extension mismatch: %v", err)
	}
	if _, changed, err := ensureExtension(false); err != nil || changed {
		t.Fatalf("idempotent install: changed=%v err=%v", changed, err)
	}
	if _, removed, err := uninstallExtension(); err != nil || !removed {
		t.Fatalf("uninstall: removed=%v err=%v", removed, err)
	}
}

func TestExtensionRefusesForeignFileAndSymlink(t *testing.T) {
	dir := t.TempDir()
	t.Setenv("PI_CODING_AGENT_DIR", dir)
	path, _ := extensionPath()
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(path, []byte("export default () => {}\n"), 0o644); err != nil {
		t.Fatal(err)
	}
	if _, _, err := ensureExtension(false); err == nil || !strings.Contains(err.Error(), "unmanaged") {
		t.Fatalf("expected unmanaged-file error, got %v", err)
	}

	if runtime.GOOS != "windows" {
		if err := os.Remove(path); err != nil {
			t.Fatal(err)
		}
		target := filepath.Join(dir, "target.ts")
		if err := os.WriteFile(target, extensionSource, 0o644); err != nil {
			t.Fatal(err)
		}
		if err := os.Symlink(target, path); err != nil {
			t.Fatal(err)
		}
		if _, _, err := ensureExtension(true); err == nil || !strings.Contains(err.Error(), "symlink") {
			t.Fatalf("expected symlink error, got %v", err)
		}
	}
}

func TestParseBranchLine(t *testing.T) {
	info := &GitInfo{}
	parseBranchLine(info, "feature/sidebar...origin/feature/sidebar [ahead 2, behind 1]")
	if info.Branch != "feature/sidebar" || info.Ahead != 2 || info.Behind != 1 {
		t.Fatalf("unexpected branch info: %+v", info)
	}

	initial := &GitInfo{}
	parseBranchLine(initial, "No commits yet on main")
	if initial.Branch != "main" {
		t.Fatalf("unexpected initial branch: %+v", initial)
	}
}

func TestResponsiveViewsIncludeGit(t *testing.T) {
	live := LiveSession{
		Pane:    WezTermPane{PaneID: 42, Workspace: "work"},
		Session: PiSession{SessionName: "Build sidebar", CWD: "/tmp/project", State: "working", Model: &ModelInfo{ID: "gpt-test"}},
		Git:     &GitInfo{Branch: "main", Additions: 116, Deletions: 2, ChangedFiles: 3},
	}
	for _, width := range []int{42, 90, 160} {
		model := newUIModel([]LiveSession{live})
		model.width, model.height = width, 30
		view := model.View()
		for _, want := range []string{"Build sidebar", "main", "+116", "-2"} {
			if !strings.Contains(view, want) {
				t.Fatalf("width %d missing %q in view", width, want)
			}
		}
	}
}

func TestListLiveSessionsJoinsRegistryToPaneAndRejectsStale(t *testing.T) {
	root := t.TempDir()
	bin := filepath.Join(root, "bin")
	state := filepath.Join(root, "state")
	if err := os.MkdirAll(bin, 0o755); err != nil {
		t.Fatal(err)
	}
	wezterm := filepath.Join(bin, "wezterm")
	script := `#!/bin/sh
printf '%s' '[{"window_id":1,"tab_id":2,"pane_id":42,"workspace":"work","title":"pi","cwd":"file:///tmp/project","size":{"rows":40,"cols":120}}]'
`
	if err := os.WriteFile(wezterm, []byte(script), 0o755); err != nil {
		t.Fatal(err)
	}
	t.Setenv("PATH", bin+string(os.PathListSeparator)+os.Getenv("PATH"))
	t.Setenv("WEZWORK_STATE_DIR", state)
	liveDir := filepath.Join(state, "live")
	if err := os.MkdirAll(liveDir, 0o700); err != nil {
		t.Fatal(err)
	}

	session := PiSession{
		Version: 1, InstanceID: "test", PID: os.Getpid(), WezTermPane: "42",
		SessionID: "abc", SessionName: "hello\x1bworld", CWD: "/tmp/project",
		State: "idle", UpdatedAt: time.Now(),
	}
	recordPath := filepath.Join(liveDir, "42-test.json")
	data, _ := json.Marshal(session)
	if err := os.WriteFile(recordPath, data, 0o600); err != nil {
		t.Fatal(err)
	}

	sessions, err := listLiveSessions()
	if err != nil || len(sessions) != 1 {
		t.Fatalf("live sessions: len=%d err=%v", len(sessions), err)
	}
	if strings.ContainsRune(sessions[0].Session.SessionName, '\x1b') {
		t.Fatal("control character was not sanitized")
	}

	session.UpdatedAt = time.Now().Add(-time.Minute)
	data, _ = json.Marshal(session)
	if err := os.WriteFile(recordPath, data, 0o600); err != nil {
		t.Fatal(err)
	}
	sessions, err = listLiveSessions()
	if err != nil || len(sessions) != 0 {
		t.Fatalf("stale sessions: len=%d err=%v", len(sessions), err)
	}
}
