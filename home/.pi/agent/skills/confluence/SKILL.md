---
name: confluence
description: Read and write Confluence pages via the Atlassian REST API. Use when the user asks to view, create, update, or search Confluence documentation.
---

# Confluence API Skill

Read and write Confluence wiki pages via the Atlassian Cloud REST API (v2).

## Required Environment Variables

| Variable | Description |
|----------|-------------|
| `JIRA_EMAIL` | Atlassian account email address |
| `JIRA_API_TOKEN` | Atlassian API token (same token works for Jira, Confluence, and Bitbucket — create at https://id.atlassian.com/manage-profile/security/api-tokens) |
| `JIRA_BASE_URL` | Atlassian instance base URL (e.g. `https://myorg.atlassian.net`) |

## Authentication

All requests use HTTP Basic Auth:

```bash
curl -u "$JIRA_EMAIL:$JIRA_API_TOKEN" "$JIRA_BASE_URL/wiki/api/v2/..."
```

## API Reference

Base path: `$JIRA_BASE_URL/wiki/api/v2`

### Read a Page

```bash
curl -s -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
  "$JIRA_BASE_URL/wiki/api/v2/pages/{pageId}?body-format=storage"
```

Response structure:
```json
{
  "id": "1234567890",
  "title": "Page Title",
  "status": "current",
  "version": { "number": 1 },
  "body": {
    "storage": {
      "value": "<h1>Content in Confluence storage format</h1>...",
      "representation": "storage"
    }
  },
  "spaceId": "12345",
  "parentId": "67890"
}
```

To extract readable text from the response, strip HTML tags:
```bash
curl -s -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
  "$JIRA_BASE_URL/wiki/api/v2/pages/{pageId}?body-format=storage" \
| python3 -c "
import json, sys, html, re
data = json.load(sys.stdin)
content = data.get('body', {}).get('storage', {}).get('value', '')
text = re.sub(r'<[^>]+>', ' ', content)
text = html.unescape(text)
text = re.sub(r'\s+', ' ', text).strip()
print(data.get('title', 'No title'))
print('=' * 80)
print(text)
"
```

### Update a Page

Updates require the current version number (increment by 1) and the full body content in storage format.

**Step 1: Get current version**
```bash
curl -s -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
  "$JIRA_BASE_URL/wiki/api/v2/pages/{pageId}" \
| python3 -c "import json,sys; print(json.load(sys.stdin)['version']['number'])"
```

**Step 2: PUT with incremented version**
```bash
curl -s -X PUT \
  -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "id": "{pageId}",
    "status": "current",
    "title": "Page Title",
    "version": {
      "number": 2,
      "message": "Updated via API"
    },
    "body": {
      "representation": "storage",
      "value": "<h1>New content</h1><p>Updated page body.</p>"
    }
  }' \
  "$JIRA_BASE_URL/wiki/api/v2/pages/{pageId}"
```

### Create a Page

```bash
curl -s -X POST \
  -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "spaceId": "{spaceId}",
    "title": "New Page Title",
    "parentId": "{parentPageId}",
    "status": "current",
    "body": {
      "representation": "storage",
      "value": "<h1>Page content</h1>"
    }
  }' \
  "$JIRA_BASE_URL/wiki/api/v2/pages"
```

### Search Pages

Search by title or content using CQL (Confluence Query Language):

```bash
# Search by title within a space
curl -s -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
  "$JIRA_BASE_URL/wiki/api/v2/pages?title=My+Page+Title&space-id={spaceId}"

# Full-text search using CQL (v1 API)
curl -s -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
  "$JIRA_BASE_URL/wiki/rest/api/content/search?cql=type%3Dpage+AND+text~%22search+term%22&limit=10"
```

### List Pages in a Space

```bash
curl -s -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
  "$JIRA_BASE_URL/wiki/api/v2/spaces/{spaceId}/pages?limit=25"
```

### Get Child Pages

```bash
curl -s -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
  "$JIRA_BASE_URL/wiki/api/v2/pages/{pageId}/children"
```

### List Spaces

```bash
curl -s -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
  "$JIRA_BASE_URL/wiki/api/v2/spaces?limit=50"
```

## Confluence Storage Format

Page content uses Confluence's storage format, which is a subset of XHTML with Confluence-specific macros. Common elements:

### Basic HTML

Standard HTML elements work: `<h1>`, `<h2>`, `<p>`, `<ul>`, `<ol>`, `<li>`, `<table>`, `<thead>`, `<tbody>`, `<tr>`, `<th>`, `<td>`, `<strong>`, `<em>`, `<code>`, `<a href="">`, `<hr />`.

### Code Blocks

```xml
<ac:structured-macro ac:name="code">
  <ac:parameter ac:name="language">bash</ac:parameter>
  <ac:plain-text-body><![CDATA[echo "hello world"]]></ac:plain-text-body>
</ac:structured-macro>
```

### Info / Warning / Note Panels

```xml
<ac:structured-macro ac:name="info">
  <ac:rich-text-body><p>This is an info panel.</p></ac:rich-text-body>
</ac:structured-macro>

<ac:structured-macro ac:name="warning">
  <ac:rich-text-body><p>This is a warning panel.</p></ac:rich-text-body>
</ac:structured-macro>

<ac:structured-macro ac:name="note">
  <ac:rich-text-body><p>This is a note panel.</p></ac:rich-text-body>
</ac:structured-macro>
```

### Expand (Collapsible Section)

```xml
<ac:structured-macro ac:name="expand">
  <ac:parameter ac:name="title">Click to expand</ac:parameter>
  <ac:rich-text-body><p>Hidden content here.</p></ac:rich-text-body>
</ac:structured-macro>
```

### Table of Contents

```xml
<ac:structured-macro ac:name="toc" />
```

## Tips

- **Page IDs** can be found in the URL when viewing a page: `$JIRA_BASE_URL/wiki/spaces/SPACE/pages/{pageId}/Page+Title`
- **Space IDs** are numeric. Use the list spaces endpoint to find them, or look at a page response's `spaceId` field.
- **Space keys** (e.g. `PT`, `ENG`) are the short identifiers in URLs. The v2 API primarily uses numeric `spaceId`, but you can find the mapping via the list spaces endpoint.
- When updating a page, you must provide the **complete body content** — it replaces the entire page, not a partial update.
- The version number must be exactly `currentVersion + 1` or the update will fail.
- For large pages, write the JSON payload to a temp file and use `curl -d @/tmp/payload.json` to avoid shell escaping issues with the storage format XML.
