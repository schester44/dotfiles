---
name: percy
description: Use when the user asks to approve Percy visual changes, review Percy builds, or interact with Percy for a GitHub PR
---

# Percy Skill

Approve or review Percy visual changes for GitHub PRs.

## Prerequisites

- GitHub CLI (`gh`) must be installed and authenticated
- Web browser skill must be available at `~/.claude/skills/web-browser/`

## Get Percy Build URL from PR Number

Use the GitHub CLI to get the Percy build URL from PR checks:

```bash
gh pr checks <PR_NUMBER> 2>/dev/null | grep -i percy
```

This returns output like:
```
percy/obie-risk-management	fail	0	https://percy.io/a35a33ec/web/obie-risk-management/builds/46120547?utm_campaign=...	3 visual changes need review
```

Extract the URL (4th field) - it contains the direct link to the Percy build.

## Approve Percy Changes

1. **Start Chrome with profile** (to use existing session):
   ```bash
   ~/.claude/skills/web-browser/scripts/start.js --profile
   ```

2. **Navigate to Percy build URL**:
   ```bash
   ~/.claude/skills/web-browser/scripts/nav.js "<PERCY_BUILD_URL>"
   ```

3. **Wait for page to load and take screenshot**:
   ```bash
   sleep 3 && ~/.claude/skills/web-browser/scripts/screenshot.js
   ```

4. **Click "Approve build" button**:
   ```bash
   ~/.claude/skills/web-browser/scripts/eval.js 'Array.from(document.querySelectorAll("button")).find(b => b.textContent.trim() === "Approve build")?.click()'
   ```

5. **Verify approval** by taking another screenshot - look for:
   - Button text changed to "Build approved"
   - "Approved by:" section showing the approver
   - Unreviewed count is 0

## Complete Example

```bash
# Get Percy URL from PR
PERCY_URL=$(gh pr checks 17652 2>/dev/null | grep -i percy | awk '{print $4}')

# Start browser and navigate
~/.claude/skills/web-browser/scripts/start.js --profile
~/.claude/skills/web-browser/scripts/nav.js "$PERCY_URL"
sleep 3

# Approve the build
~/.claude/skills/web-browser/scripts/eval.js 'Array.from(document.querySelectorAll("button")).find(b => b.textContent.trim() === "Approve build")?.click()'
```

## Notes

- The Percy URL from `gh pr checks` includes UTM parameters but works fine
- Percy uses BrowserStack authentication - the browser profile must have an active Percy/BrowserStack session
- If not logged in, you'll see a login page or "Access Denied" - user needs to log in manually first
- Build status values: "Unreviewed", "Changes requested", "Approved"
