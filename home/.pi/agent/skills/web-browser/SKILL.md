---
name: web-browser
description: "Allows to interact with web pages by performing actions such as clicking buttons, filling out forms, and navigating links. It works by remote controlling Google Chrome or Chromium browsers using the Chrome DevTools Protocol (CDP). When Claude needs to browse the web, it can use this skill to do so."
license: Stolen from Mario
---

# Web Browser Skill

Minimal CDP tools for collaborative site exploration.

**Performance note:** `nav.js`, `eval.js`, and `screenshot.js` share a persistent
daemon (auto-spawned on first use, socket at `$TMPDIR/web-browser-cdp.sock`) that
holds one CDP connection — commands cost ~20–150ms instead of rebuilding the
connection each call. The daemon exits when Chrome closes or after 60min idle.
If it misbehaves: `pkill -f scripts/daemon.js` (it will respawn on next command).

## Start Chrome

\`\`\`bash
./scripts/start.js              # Fresh profile
./scripts/start.js --profile    # Copy your profile (cookies, logins)
\`\`\`

Start Chrome on `:9222` with remote debugging.

## Navigate

\`\`\`bash
./scripts/nav.js https://example.com
./scripts/nav.js https://example.com --new   # open in new tab
./scripts/nav.js https://example.com --idle  # wait for network idle instead of load
\`\`\`

Navigate current tab or open new tab. Waits for the page load event (up to 15s),
so no `sleep` needed after navigation. Use `--idle` for SPAs and pages that load
content via XHR after the load event. Creates a tab if none exists.

## Wait for Conditions (never use `sleep`)

\`\`\`bash
./scripts/wait.js '#search-results'                  # element appears
./scripts/wait.js --gone '.loading-spinner'          # element disappears
./scripts/wait.js --js 'document.title.includes("Order")' 30000
\`\`\`

MutationObserver-based — resolves the instant the condition is met, errors on
timeout (default 15s). Use after clicks that trigger renders, before scraping
JS-rendered content, or to await dialogs.

## Evaluate JavaScript

\`\`\`bash
./scripts/eval.js 'document.title'
./scripts/eval.js 'document.querySelectorAll("a").length'
./scripts/eval.js 'JSON.stringify(Array.from(document.querySelectorAll("a")).map(a => ({ text: a.textContent.trim(), href: a.href })).filter(link => !link.href.startsWith("https://")))'
\`\`\`

Execute JavaScript in active tab (async context).  Be careful with string escaping, best to use single quotes.

## Screenshot

\`\`\`bash
./scripts/screenshot.js
\`\`\`

Screenshot current viewport, returns temp file path

## Pick Elements

\`\`\`bash
./scripts/pick.js "Click the submit button"
\`\`\`

Interactive element picker. Click to select, Cmd/Ctrl+Click for multi-select, Enter to finish.

## Dismiss Cookie Dialogs

\`\`\`bash
./scripts/dismiss-cookies.js          # Accept cookies
./scripts/dismiss-cookies.js --reject # Reject cookies (where possible)
\`\`\`

Automatically dismisses EU cookie consent dialogs. Supports:
- **OneTrust** (booking.com, ikea.com, many others)
- **Google** consent dialogs
- **Cookiebot**
- **Didomi**
- **Quantcast Choice**
- **Usercentrics** (shadow DOM)
- **Sourcepoint** (BBC, etc. - works with iframes)
- **Amazon**
- **TrustArc**
- **Klaro**
- Generic cookie banners with common button text patterns

Run after navigating to a page:
\`\`\`bash
./scripts/nav.js https://example.com --idle && ./scripts/dismiss-cookies.js
\`\`\`
(`--idle` waits for network idle, which is when late-injected banners have arrived —
no `sleep` needed.)
