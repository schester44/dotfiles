package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"os/exec"

	tea "github.com/charmbracelet/bubbletea"
)

const version = "0.1.0"

func main() {
	if err := run(os.Args[1:]); err != nil {
		fmt.Fprintln(os.Stderr, "wezwork:", err)
		os.Exit(1)
	}
}

func run(args []string) error {
	if len(args) == 0 {
		return runTUI()
	}
	switch args[0] {
	case "list":
		return runList(args[1:])
	case "install":
		return runInstall(args[1:])
	case "uninstall":
		return runUninstall(args[1:])
	case "doctor":
		return runDoctor()
	case "version", "--version", "-v":
		fmt.Println("wezwork " + version)
		return nil
	case "help", "--help", "-h":
		printHelp()
		return nil
	default:
		return fmt.Errorf("unknown command %q (try wezwork help)", args[0])
	}
}

func runTUI() error {
	if err := bootstrapExtension(); err != nil {
		return err
	}
	markDashboardPane(true)
	defer markDashboardPane(false)
	sessions, err := listLiveSessions()
	if err != nil {
		return err
	}
	program := tea.NewProgram(newUIModel(sessions), tea.WithAltScreen())
	_, err = program.Run()
	return err
}

func markDashboardPane(active bool) {
	if os.Getenv("WEZTERM_PANE") == "" {
		return
	}
	value := ""
	if active {
		value = "MQ==" // base64("1")
		fmt.Print("\x1b]0;wezwork\x07")
	}
	fmt.Printf("\x1b]1337;SetUserVar=wezwork_dashboard=%s\x07", value)
}

func runList(args []string) error {
	flags := flag.NewFlagSet("list", flag.ContinueOnError)
	jsonOutput := flags.Bool("json", false, "output JSON")
	if err := flags.Parse(args); err != nil {
		return err
	}
	if err := bootstrapExtension(); err != nil {
		return err
	}
	sessions, err := listLiveSessions()
	if err != nil {
		return err
	}
	if *jsonOutput {
		encoder := json.NewEncoder(os.Stdout)
		encoder.SetIndent("", "  ")
		return encoder.Encode(sessions)
	}
	if len(sessions) == 0 {
		fmt.Println("No instrumented Pi sessions found.")
		fmt.Println("Run /reload in open Pi panes after installing wezwork.")
		return nil
	}
	fmt.Printf("%-6s %-9s %-18s %-20s %-28s %-22s %s\n", "PANE", "STATE", "WORKSPACE", "PROJECT", "SESSION", "MODEL", "GIT")
	for _, live := range sessions {
		model := "-"
		if live.Session.Model != nil {
			model = live.Session.Model.ID
		}
		fmt.Printf("%-6d %-9s %-18s %-20s %-28s %-22s %s\n", live.Pane.PaneID, live.Session.State,
			clip(live.Pane.Workspace, 18), clip(projectName(live.Session.CWD), 20), clip(sessionLabel(live.Session), 28), model, gitSummaryPlain(live.Git))
	}
	return nil
}

func runInstall(args []string) error {
	flags := flag.NewFlagSet("install", flag.ContinueOnError)
	force := flags.Bool("force", false, "back up and replace an unmanaged extension")
	if err := flags.Parse(args); err != nil {
		return err
	}
	path, changed, err := ensureExtension(*force)
	if err != nil {
		return err
	}
	if changed {
		fmt.Println("Installed Pi extension:", path)
		fmt.Println("Run /reload in existing Pi sessions; new sessions load it automatically.")
	} else {
		fmt.Println("Pi extension is already current:", path)
	}
	return nil
}

func runUninstall(args []string) error {
	if len(args) != 0 {
		return fmt.Errorf("uninstall takes no arguments")
	}
	path, removed, err := uninstallExtension()
	if err != nil {
		return err
	}
	if removed {
		fmt.Println("Removed Pi extension:", path)
		fmt.Println("Run /reload in existing Pi sessions to stop publishing metadata.")
	} else {
		fmt.Println("Pi extension is not installed:", path)
	}
	return nil
}

func runDoctor() error {
	failed := false
	if path, err := exec.LookPath("wezterm"); err != nil {
		fmt.Println("✗ wezterm executable not found")
		failed = true
	} else {
		fmt.Println("✓ wezterm:", path)
	}
	if panes, err := listWezTermPanes(); err != nil {
		fmt.Println("✗ WezTerm mux:", err)
		failed = true
	} else {
		fmt.Printf("✓ WezTerm mux: %d panes\n", len(panes))
	}
	path, err := extensionPath()
	if err != nil {
		return err
	}
	data, err := os.ReadFile(path)
	if err != nil {
		fmt.Println("✗ Pi extension:", err)
		failed = true
	} else if !isManagedExtension(data) {
		fmt.Println("✗ Pi extension is not managed by wezwork:", path)
		failed = true
	} else if string(data) != string(extensionSource) {
		fmt.Println("! Pi extension is outdated:", path)
		failed = true
	} else {
		fmt.Println("✓ Pi extension:", path)
	}
	dir, err := runtimeDir()
	if err != nil {
		return err
	}
	if err := checkRegistryWritable(dir); err != nil {
		fmt.Println("✗ Live registry:", err)
		failed = true
	} else {
		fmt.Println("✓ Live registry:", dir)
	}
	if sessions, err := listLiveSessions(); err != nil {
		fmt.Println("✗ Session discovery:", err)
		failed = true
	} else {
		fmt.Printf("✓ Live Pi sessions: %d\n", len(sessions))
	}
	if failed {
		return fmt.Errorf("doctor found problems")
	}
	return nil
}

func checkRegistryWritable(dir string) error {
	if err := os.MkdirAll(dir, 0o700); err != nil {
		return fmt.Errorf("create %s: %w", dir, err)
	}
	probe, err := os.CreateTemp(dir, ".doctor-*")
	if err != nil {
		return fmt.Errorf("write %s: %w", dir, err)
	}
	name := probe.Name()
	defer os.Remove(name)
	if err := probe.Chmod(0o600); err != nil {
		probe.Close()
		return err
	}
	return probe.Close()
}

func bootstrapExtension() error {
	path, changed, err := ensureExtension(false)
	if err != nil {
		return err
	}
	if changed {
		fmt.Fprintf(os.Stderr, "Installed Pi extension at %s. Run /reload in existing Pi panes.\n", path)
	}
	return nil
}

func clip(value string, width int) string {
	runes := []rune(value)
	if len(runes) <= width {
		return value
	}
	return string(runes[:width-1]) + "…"
}

func printHelp() {
	fmt.Print(`wezwork — view live Pi sessions across WezTerm

Usage:
  wezwork                    Open the live TUI
  wezwork list [--json]      List live sessions
  wezwork install [--force]  Install/update the bundled Pi extension
  wezwork uninstall          Remove the managed Pi extension
  wezwork doctor             Check the integration
  wezwork version            Print the version

TUI keys:
  ↑/k, ↓/j     Select a session
  Enter        Focus the selected WezTerm pane
  r            Refresh now
  q/Escape     Quit

The first TUI/list run installs the Pi extension automatically. Existing Pi
sessions require /reload once; newly started sessions load it automatically.
`)
}
