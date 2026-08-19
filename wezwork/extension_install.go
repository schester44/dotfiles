package main

import (
	_ "embed"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"time"
)

const (
	extensionName   = "wezwork.ts"
	managedMarker   = "// WEZWORK_PI_INTEGRATION_VERSION="
	managedPreamble = "// Managed by wezwork. Reinstalling the integration overwrites this file.\n" + managedMarker
)

//go:embed extension/wezwork.ts
var extensionSource []byte

func agentDir() (string, error) {
	if dir := os.Getenv("PI_CODING_AGENT_DIR"); dir != "" {
		return expandHome(dir)
	}
	home, err := os.UserHomeDir()
	if err != nil {
		return "", fmt.Errorf("find home directory: %w", err)
	}
	return filepath.Join(home, ".pi", "agent"), nil
}

func extensionPath() (string, error) {
	dir, err := agentDir()
	if err != nil {
		return "", err
	}
	return filepath.Join(dir, "extensions", extensionName), nil
}

func ensureExtension(force bool) (path string, changed bool, err error) {
	path, err = extensionPath()
	if err != nil {
		return "", false, err
	}

	if info, statErr := os.Lstat(path); statErr == nil && info.Mode()&os.ModeSymlink != 0 {
		return path, false, fmt.Errorf("refusing to overwrite symlink %s", path)
	} else if statErr != nil && !errors.Is(statErr, os.ErrNotExist) {
		return path, false, fmt.Errorf("inspect extension: %w", statErr)
	}

	current, readErr := os.ReadFile(path)
	if readErr == nil {
		if string(current) == string(extensionSource) {
			return path, false, nil
		}
		if !isManagedExtension(current) {
			if !force {
				return path, false, fmt.Errorf("refusing to overwrite unmanaged extension %s (use --force)", path)
			}
			backup := fmt.Sprintf("%s.backup-%s", path, time.Now().Format("20060102-150405"))
			if err := os.WriteFile(backup, current, 0o600); err != nil {
				return path, false, fmt.Errorf("back up unmanaged extension: %w", err)
			}
		}
	} else if !errors.Is(readErr, os.ErrNotExist) {
		return path, false, fmt.Errorf("read extension: %w", readErr)
	}

	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return path, false, fmt.Errorf("create extension directory: %w", err)
	}
	tmp, err := os.CreateTemp(filepath.Dir(path), ".wezwork-*.ts")
	if err != nil {
		return path, false, fmt.Errorf("create temporary extension: %w", err)
	}
	tmpName := tmp.Name()
	defer os.Remove(tmpName)
	if err := tmp.Chmod(0o644); err != nil {
		tmp.Close()
		return path, false, err
	}
	if _, err := tmp.Write(extensionSource); err != nil {
		tmp.Close()
		return path, false, fmt.Errorf("write extension: %w", err)
	}
	if err := tmp.Close(); err != nil {
		return path, false, fmt.Errorf("close extension: %w", err)
	}
	if err := os.Rename(tmpName, path); err != nil {
		return path, false, fmt.Errorf("install extension: %w", err)
	}
	return path, true, nil
}

func uninstallExtension() (string, bool, error) {
	path, err := extensionPath()
	if err != nil {
		return "", false, err
	}
	if info, statErr := os.Lstat(path); statErr == nil && info.Mode()&os.ModeSymlink != 0 {
		return path, false, fmt.Errorf("refusing to remove symlink %s", path)
	} else if statErr != nil && !errors.Is(statErr, os.ErrNotExist) {
		return path, false, statErr
	}
	current, err := os.ReadFile(path)
	if errors.Is(err, os.ErrNotExist) {
		return path, false, nil
	}
	if err != nil {
		return path, false, err
	}
	if !isManagedExtension(current) {
		return path, false, fmt.Errorf("refusing to remove unmanaged extension %s", path)
	}
	if err := os.Remove(path); err != nil {
		return path, false, err
	}
	return path, true, nil
}

func isManagedExtension(content []byte) bool {
	return strings.HasPrefix(string(content), managedPreamble)
}

func expandHome(path string) (string, error) {
	if path == "~" || strings.HasPrefix(path, "~/") {
		home, err := os.UserHomeDir()
		if err != nil {
			return "", err
		}
		if path == "~" {
			return home, nil
		}
		return filepath.Join(home, path[2:]), nil
	}
	return path, nil
}
