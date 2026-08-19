package main

import (
	"fmt"
	"strings"
	"time"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

var (
	// Colors from grapelean (system/colors/grapelean.json):
	// gray base with pink, purple, and green accents.
	accentStyle   = lipgloss.NewStyle().Foreground(lipgloss.Color("#967EFB")).Bold(true)                                           // purple.base
	dimStyle      = lipgloss.NewStyle().Foreground(lipgloss.Color("#626262"))                                                      // gray.muted / comment
	selectedStyle = lipgloss.NewStyle().Foreground(lipgloss.Color("#FFFFFF")).Background(lipgloss.Color("#424246"))                // white on bg.lighter
	workingStyle  = lipgloss.NewStyle().Foreground(lipgloss.Color("#d4a055")).Bold(true)                                           // yellow.muted / warning
	idleStyle     = lipgloss.NewStyle().Foreground(lipgloss.Color("#4bdd9c"))                                                      // green.glow
	errorStyle    = lipgloss.NewStyle().Foreground(lipgloss.Color("#FF6B6B"))                                                      // red.base / error
	additionStyle = lipgloss.NewStyle().Foreground(lipgloss.Color("#6fbfa0")).Bold(true)                                           // green.base / added
	deletionStyle = lipgloss.NewStyle().Foreground(lipgloss.Color("#FF628C")).Bold(true)                                           // pink.base / removed
	branchStyle   = lipgloss.NewStyle().Foreground(lipgloss.Color("#b8a8e8"))                                                      // purple.light
	borderStyle   = lipgloss.NewStyle().Border(lipgloss.RoundedBorder()).BorderForeground(lipgloss.Color("#444444")).Padding(0, 1) // gray.dark
)

type sessionsMsg struct {
	sessions []LiveSession
	err      error
}

type tickMsg time.Time

type activateResultMsg struct{ err error }

type uiModel struct {
	sessions   []LiveSession
	selected   int
	width      int
	height     int
	err        error
	status     string
	refreshing bool
}

func newUIModel(sessions []LiveSession) uiModel {
	return uiModel{sessions: sessions}
}

func (m uiModel) Init() tea.Cmd { return tickCmd() }

func tickCmd() tea.Cmd {
	return tea.Tick(time.Second, func(t time.Time) tea.Msg { return tickMsg(t) })
}

func refreshCmd() tea.Cmd {
	return func() tea.Msg {
		sessions, err := listLiveSessions()
		return sessionsMsg{sessions: sessions, err: err}
	}
}

func activateCmd(paneID int) tea.Cmd {
	return func() tea.Msg { return activateResultMsg{err: activatePane(paneID)} }
}

func (m uiModel) Update(message tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := message.(type) {
	case tea.KeyMsg:
		switch msg.String() {
		case "q", "ctrl+c", "esc":
			return m, tea.Quit
		case "up", "k":
			if m.selected > 0 {
				m.selected--
			}
		case "down", "j":
			if m.selected+1 < len(m.sessions) {
				m.selected++
			}
		case "home", "g":
			m.selected = 0
		case "end", "G":
			if len(m.sessions) > 0 {
				m.selected = len(m.sessions) - 1
			}
		case "r":
			if !m.refreshing {
				m.status = "refreshing…"
				m.refreshing = true
				return m, refreshCmd()
			}
		case "enter":
			if len(m.sessions) > 0 {
				m.status = fmt.Sprintf("activating pane %d…", m.sessions[m.selected].Pane.PaneID)
				return m, activateCmd(m.sessions[m.selected].Pane.PaneID)
			}
		}
	case tea.WindowSizeMsg:
		m.width, m.height = msg.Width, msg.Height
	case tickMsg:
		if !m.refreshing {
			m.refreshing = true
			return m, tea.Batch(refreshCmd(), tickCmd())
		}
		return m, tickCmd()
	case sessionsMsg:
		m.refreshing = false
		selectedPane := -1
		if m.selected < len(m.sessions) {
			selectedPane = m.sessions[m.selected].Pane.PaneID
		}
		m.err = msg.err
		if msg.err == nil {
			m.sessions = msg.sessions
			m.selected = 0
			for index := range m.sessions {
				if m.sessions[index].Pane.PaneID == selectedPane {
					m.selected = index
					break
				}
			}
			if m.selected >= len(m.sessions) && len(m.sessions) > 0 {
				m.selected = len(m.sessions) - 1
			}
		}
		m.status = ""
	case activateResultMsg:
		if msg.err != nil {
			m.err = msg.err
			m.status = ""
			return m, nil
		}
		m.err = nil
		m.status = "pane activated"
		return m, nil
	}
	return m, nil
}

func (m uiModel) View() string {
	// Don't render until the real terminal size is known: rendering at a
	// guessed width in a narrower pane wraps lines and permanently corrupts
	// bubbletea's renderer state.
	if m.width <= 0 || m.height <= 0 {
		return ""
	}
	width := m.width
	var out strings.Builder
	out.WriteString(accentStyle.Render("wezwork"))
	out.WriteString(dimStyle.Render(fmt.Sprintf("  live Pi sessions · %d open", len(m.sessions))))
	out.WriteString("\n\n")

	if m.err != nil {
		out.WriteString(errorStyle.Render("Error: " + m.err.Error()))
		out.WriteString("\n\n")
	}
	if len(m.sessions) == 0 {
		out.WriteString("No instrumented Pi sessions found.\n")
		out.WriteString(dimStyle.Render("Run /reload in open Pi panes after installing wezwork."))
		out.WriteString("\n")
	} else {
		sidebar := width < 70
		showDetails := !sidebar && (m.height == 0 || m.height >= 24)
		maxRows := m.height - 7
		if sidebar {
			maxRows = (m.height - 5) / 3
		} else if showDetails {
			maxRows = m.height - 21
		}
		if maxRows < 1 {
			maxRows = 1
		}
		if sidebar {
			out.WriteString(m.renderSidebar(width, maxRows))
		} else {
			out.WriteString(m.renderTable(width, maxRows))
		}
		if showDetails {
			out.WriteString("\n")
			out.WriteString(m.renderDetails(width))
		}
	}

	if m.status != "" {
		out.WriteString("\n")
		out.WriteString(dimStyle.Render(m.status))
	}
	return out.String()
}

func (m uiModel) renderSidebar(width, maxRows int) string {
	start, end := visibleRange(len(m.sessions), m.selected, maxRows)
	contentWidth := max(16, width-3)
	var out strings.Builder
	for index := start; index < end; index++ {
		live := m.sessions[index]
		marker := "  "
		if index == m.selected {
			marker = accentStyle.Render("▌ ")
		}
		dot := idleStyle.Render("●")
		if live.Session.State == "working" {
			dot = workingStyle.Render("●")
		}
		nameWidth := max(8, contentWidth-9)
		line1 := fmt.Sprintf("%s %s  %s", dot, fit(sessionLabel(live.Session), nameWidth), dimStyle.Render(fmt.Sprint(live.Pane.PaneID)))
		line2 := dimStyle.Render(fit(projectName(live.Session.CWD)+" · "+live.Pane.Workspace, contentWidth))
		model := "-"
		if live.Session.Model != nil {
			model = live.Session.Model.ID
		}
		line3 := gitSummaryStyled(live.Git, contentWidth-len([]rune(model))-3)
		if line3 != "" {
			line3 += dimStyle.Render(" · ")
		}
		line3 += dimStyle.Render(fit(model, max(8, contentWidth/2)))
		out.WriteString(marker + line1 + "\n")
		out.WriteString("  " + line2 + "\n")
		out.WriteString("  " + line3)
		if index+1 < end {
			out.WriteByte('\n')
		}
	}
	return out.String()
}

func (m uiModel) renderTable(width, maxRows int) string {
	start, end := visibleRange(len(m.sessions), m.selected, maxRows)
	if width < 120 {
		paneW, stateW, projectW, gitW := 6, 8, 16, 22
		sessionW := max(14, width-paneW-stateW-projectW-gitW-8)
		row := func(pane, state, project, session, git string) string {
			return fmt.Sprintf("%-*s  %-*s  %-*s  %-*s  %-*s", paneW, fit(pane, paneW), stateW, fit(state, stateW),
				projectW, fit(project, projectW), sessionW, fit(session, sessionW), gitW, fit(git, gitW))
		}
		var out strings.Builder
		out.WriteString(dimStyle.Render(row("PANE", "STATE", "PROJECT", "SESSION", "GIT")))
		out.WriteByte('\n')
		for index := start; index < end; index++ {
			live := m.sessions[index]
			line := row(fmt.Sprint(live.Pane.PaneID), live.Session.State, projectName(live.Session.CWD), sessionLabel(live.Session), gitSummaryPlain(live.Git))
			if index == m.selected {
				out.WriteString(selectedStyle.Width(min(width, lipgloss.Width(line))).Render(line))
			} else {
				out.WriteString(line)
			}
			out.WriteByte('\n')
		}
		return strings.TrimSuffix(out.String(), "\n")
	}

	paneW, stateW, workspaceW, projectW, modelW, gitW := 6, 8, 14, 16, 18, 24
	fixed := paneW + stateW + workspaceW + projectW + modelW + gitW + 12
	sessionW := max(16, width-fixed)
	row := func(pane, state, workspace, project, session, model, git string) string {
		return fmt.Sprintf("%-*s  %-*s  %-*s  %-*s  %-*s  %-*s  %-*s",
			paneW, fit(pane, paneW), stateW, fit(state, stateW), workspaceW, fit(workspace, workspaceW),
			projectW, fit(project, projectW), sessionW, fit(session, sessionW), modelW, fit(model, modelW), gitW, fit(git, gitW))
	}

	var out strings.Builder
	out.WriteString(dimStyle.Render(row("PANE", "STATE", "WORKSPACE", "PROJECT", "SESSION", "MODEL", "GIT")))
	out.WriteByte('\n')
	for index := start; index < end; index++ {
		live := m.sessions[index]
		model := "-"
		if live.Session.Model != nil {
			model = live.Session.Model.ID
		}
		line := row(fmt.Sprint(live.Pane.PaneID), live.Session.State, live.Pane.Workspace,
			projectName(live.Session.CWD), sessionLabel(live.Session), model, gitSummaryPlain(live.Git))
		if index == m.selected {
			out.WriteString(selectedStyle.Width(min(width, lipgloss.Width(line))).Render(line))
		} else if live.Session.State == "working" {
			out.WriteString(workingStyle.Render(line))
		} else {
			out.WriteString(line)
		}
		out.WriteByte('\n')
	}
	return strings.TrimSuffix(out.String(), "\n")
}

func (m uiModel) renderDetails(width int) string {
	if m.selected >= len(m.sessions) {
		return ""
	}
	live := m.sessions[m.selected]
	session, pane := live.Session, live.Pane
	model := "-"
	if session.Model != nil {
		model = session.Model.Provider + "/" + session.Model.ID
	}
	context := "-"
	if session.ContextTokens != nil && session.ContextWindow != nil {
		percent := float64(*session.ContextTokens) / float64(*session.ContextWindow) * 100
		context = fmt.Sprintf("%s / %s (%.1f%%)", compactNumber(*session.ContextTokens), compactNumber(*session.ContextWindow), percent)
	}
	updated := "-"
	if !session.UpdatedAt.IsZero() {
		updated = time.Since(session.UpdatedAt).Round(time.Second).String() + " ago"
	}
	body := fmt.Sprintf(
		"%s %s\n%s %s\n%s %s\n%s %s · thinking %s · context %s\n%s %s\n%s pane %d · entries %d · PID %d · updated %s\n%s window %d · tab %d · workspace %s · active %t · zoomed %t",
		accentStyle.Render("Session"), valueOr(session.SessionName, "unnamed"),
		dimStyle.Render("ID     "), valueOr(session.SessionID, "-"),
		dimStyle.Render("File   "), valueOr(session.SessionFile, "ephemeral"),
		dimStyle.Render("Model  "), model, valueOr(session.ThinkingLevel, "-"), context,
		dimStyle.Render("Git    "), gitDetailsStyled(live.Git),
		dimStyle.Render("Runtime"), pane.PaneID, session.EntryCount, session.PID, updated,
		dimStyle.Render("WezTerm"), pane.WindowID, pane.TabID, valueOr(pane.Workspace, "default"), pane.IsActive, pane.IsZoomed,
	)
	return borderStyle.Width(max(0, width-4)).Render(body)
}

func visibleRange(total, selected, limit int) (int, int) {
	if limit <= 0 || limit >= total {
		return 0, total
	}
	start := selected - limit/2
	if start < 0 {
		start = 0
	}
	if start+limit > total {
		start = total - limit
	}
	return start, start + limit
}

func gitSummaryPlain(info *GitInfo) string {
	if info == nil {
		return "-"
	}
	parts := []string{valueOr(info.Branch, "detached")}
	if info.Additions > 0 {
		parts = append(parts, fmt.Sprintf("+%d", info.Additions))
	}
	if info.Deletions > 0 {
		parts = append(parts, fmt.Sprintf("-%d", info.Deletions))
	}
	if info.Untracked > 0 {
		parts = append(parts, fmt.Sprintf("?%d", info.Untracked))
	}
	if info.ChangedFiles == 0 {
		parts = append(parts, "clean")
	}
	return strings.Join(parts, " ")
}

func gitSummaryStyled(info *GitInfo, width int) string {
	if info == nil || width < 3 {
		return ""
	}
	stats := ""
	plainStats := ""
	if info.Additions > 0 {
		plainStats += fmt.Sprintf(" +%d", info.Additions)
		stats += " " + additionStyle.Render(fmt.Sprintf("+%d", info.Additions))
	}
	if info.Deletions > 0 {
		plainStats += fmt.Sprintf(" -%d", info.Deletions)
		stats += " " + deletionStyle.Render(fmt.Sprintf("-%d", info.Deletions))
	}
	if info.Untracked > 0 {
		plainStats += fmt.Sprintf(" ?%d", info.Untracked)
		stats += " " + workingStyle.Render(fmt.Sprintf("?%d", info.Untracked))
	}
	if info.ChangedFiles == 0 {
		plainStats = " clean"
		stats = " " + idleStyle.Render("clean")
	}
	branchWidth := max(3, width-len([]rune(plainStats)))
	return branchStyle.Render(fit(valueOr(info.Branch, "detached"), branchWidth)) + stats
}

func gitDetailsStyled(info *GitInfo) string {
	if info == nil {
		return "not a repository"
	}
	text := gitSummaryStyled(info, 80)
	text += dimStyle.Render(fmt.Sprintf(" · %d changed", info.ChangedFiles))
	if info.Ahead > 0 {
		text += additionStyle.Render(fmt.Sprintf(" · ↑%d", info.Ahead))
	}
	if info.Behind > 0 {
		text += deletionStyle.Render(fmt.Sprintf(" · ↓%d", info.Behind))
	}
	text += dimStyle.Render(" · " + info.Root)
	return text
}

func sessionLabel(session PiSession) string {
	if session.SessionName != "" {
		return session.SessionName
	}
	if session.SessionID != "" {
		return shortID(session.SessionID)
	}
	return "unnamed"
}

func shortID(id string) string {
	if len(id) <= 8 {
		return id
	}
	return id[:8]
}

func fit(value string, width int) string {
	runes := []rune(strings.ReplaceAll(value, "\n", " "))
	if len(runes) <= width {
		return string(runes)
	}
	if width <= 1 {
		return "…"
	}
	return string(runes[:width-1]) + "…"
}

func compactNumber(number int) string {
	if number >= 1_000_000 {
		return fmt.Sprintf("%.1fM", float64(number)/1_000_000)
	}
	if number >= 1_000 {
		return fmt.Sprintf("%.1fk", float64(number)/1_000)
	}
	return fmt.Sprint(number)
}

func valueOr(value, fallback string) string {
	if value == "" {
		return fallback
	}
	return value
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
func max(a, b int) int {
	if a > b {
		return a
	}
	return b
}
