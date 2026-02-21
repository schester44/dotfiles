---
name: gmail
description: Access Gmail messages using gogcli (gog). Search emails, read threads, send messages, manage labels/drafts/filters, and handle attachments. Use when the user asks about email, Gmail, reading messages, sending emails, or managing inbox.
---

# Gmail via gogcli

This skill uses [gogcli](https://github.com/steipete/gogcli) (`gog`) to interact with Gmail.

## Prerequisites

1. **Install gogcli:**
   ```bash
   brew install steipete/tap/gogcli
   ```

2. **Setup OAuth credentials** (one-time):
   - Create OAuth credentials at https://console.cloud.google.com/apis/credentials
   - Enable Gmail API at https://console.cloud.google.com/apis/api/gmail.googleapis.com
   - Download the OAuth client JSON file
   - Store credentials: `gog auth credentials ~/Downloads/client_secret_....json`

3. **Authorize account:**
   ```bash
   gog auth add you@gmail.com
   ```

4. **Set default account** (recommended):
   ```bash
   export GOG_ACCOUNT=you@gmail.com
   ```

## Common Commands

### Search & Read

```bash
# Search emails (Gmail search syntax)
gog gmail search 'newer_than:7d'                    # Last 7 days
gog gmail search 'from:someone@example.com'         # From specific sender
gog gmail search 'subject:invoice'                  # By subject
gog gmail search 'is:unread'                        # Unread messages
gog gmail search 'has:attachment'                   # With attachments
gog gmail search 'newer_than:1d is:unread' --max 20 # Combined query

# Read thread/message
gog gmail thread get <threadId>                     # Full thread
gog gmail thread get <threadId> --json              # JSON output for parsing
gog gmail get <messageId>                           # Single message
gog gmail get <messageId> --format metadata         # Headers only

# Open in browser
gog gmail url <threadId>                            # Print Gmail web URL
```

### Attachments

```bash
# Download all attachments from a thread
gog gmail thread get <threadId> --download
gog gmail thread get <threadId> --download --out-dir ./attachments

# Download specific attachment
gog gmail attachment <messageId> <attachmentId>
gog gmail attachment <messageId> <attachmentId> --out ./file.pdf
```

### Send Email

```bash
# Basic send
gog gmail send --to recipient@example.com --subject "Subject" --body "Message body"

# With HTML
gog gmail send --to a@b.com --subject "Hi" --body "Plain text fallback" --body-html "<p>HTML content</p>"

# Body from file or stdin
gog gmail send --to a@b.com --subject "Report" --body-file ./message.txt
gog gmail send --to a@b.com --subject "Report" --body-file -   # Read from stdin

# With CC/BCC
gog gmail send --to a@b.com --cc b@b.com --bcc c@b.com --subject "Hi" --body "..."
```

### Labels

```bash
gog gmail labels list                               # List all labels
gog gmail labels get INBOX --json                   # Label details with counts
gog gmail labels create "My Label"                  # Create new label

# Modify thread labels
gog gmail thread modify <threadId> --add STARRED --remove INBOX
gog gmail labels modify <threadId> --add STARRED --remove INBOX
```

### Drafts

```bash
gog gmail drafts list
gog gmail drafts create --subject "Draft" --body "Body"
gog gmail drafts create --to a@b.com --subject "Draft" --body "Body"
gog gmail drafts update <draftId> --subject "Updated Draft" --body "New body"
gog gmail drafts send <draftId>
```

### Batch Operations

```bash
# Delete multiple messages
gog gmail batch delete <messageId1> <messageId2>

# Modify multiple messages
gog gmail batch modify <messageId1> <messageId2> --add STARRED --remove INBOX
```

### Filters

```bash
gog gmail filters list
gog gmail filters create --from 'noreply@example.com' --add-label 'Notifications'
gog gmail filters delete <filterId>
```

### Settings

```bash
# Vacation/auto-reply
gog gmail vacation get
gog gmail vacation enable --subject "Out of office" --message "I'll be back on..."
gog gmail vacation disable

# Forwarding
gog gmail forwarding list
gog gmail forwarding add --email forward@example.com
gog gmail autoforward get
gog gmail autoforward enable --email forward@example.com
gog gmail autoforward disable

# Send-as aliases
gog gmail sendas list
gog gmail sendas create --email alias@example.com

# Delegation (Workspace only)
gog gmail delegates list
gog gmail delegates add --email delegate@example.com
gog gmail delegates remove --email delegate@example.com
```

## Output Formats

```bash
# Human-readable (default)
gog gmail search 'newer_than:7d'

# JSON for scripting/parsing
gog gmail search 'newer_than:7d' --json

# Plain TSV (tab-separated)
gog gmail search 'newer_than:7d' --plain
```

## Environment Variables

- `GOG_ACCOUNT` - Default account email (avoids `--account` flag)
- `GOG_JSON` - Default to JSON output
- `GOG_PLAIN` - Default to plain output

## Gmail Search Syntax

Common search operators:
- `from:` / `to:` / `cc:` / `bcc:` - By address
- `subject:` - In subject line
- `newer_than:Xd` / `older_than:Xd` - Relative date (d=days, m=months, y=years)
- `after:YYYY/MM/DD` / `before:YYYY/MM/DD` - Absolute date
- `is:unread` / `is:read` / `is:starred` / `is:important`
- `has:attachment` - Has attachments
- `filename:pdf` - Attachment filename
- `label:` - By label
- `in:inbox` / `in:sent` / `in:trash` / `in:spam`
- `category:primary` / `category:social` / `category:promotions`

Combine with AND (space), OR, `-` (NOT), and parentheses.

## Troubleshooting

```bash
# Check auth status
gog auth status
gog auth list --check

# Re-authorize if needed
gog auth add you@gmail.com --force-consent

# Verify account
gog gmail labels list
```
