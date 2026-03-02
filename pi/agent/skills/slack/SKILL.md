# Slack Search Skill

Use this skill when the user asks about information that might be in Slack conversations, or when searching team discussions, channel history, or messages would be helpful for context.

## Tokens

- `$SLACK_USER_TOKEN` - User token with `search:read` scope (use for search)
- `$SLACK_BOT_TOKEN` - Bot token (use for channel operations)

## Search Messages

```bash
curl -s -X POST 'https://slack.com/api/search.messages' \
  -H "Authorization: Bearer $SLACK_USER_TOKEN" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "query=YOUR_SEARCH_TERM&count=10" | python3 -m json.tool
```

### Search with filters
```bash
# Search in a specific channel
-d "query=search term in:#channel-name&count=10"

# Search from a specific user
-d "query=search term from:@username&count=10"

# Search with date range
-d "query=search term after:2024-01-01 before:2024-12-31&count=10"

# Combine filters
-d "query=deployment in:#the-porch from:@schester44&count=10"
```

### Parse search results nicely
```bash
curl -s -X POST 'https://slack.com/api/search.messages' \
  -H "Authorization: Bearer $SLACK_USER_TOKEN" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "query=YOUR_SEARCH_TERM&count=10" | python3 -c "
import sys, json
data = json.load(sys.stdin)
if not data.get('ok'):
    print(f'Error: {data.get(\"error\")}')
    sys.exit(1)
matches = data.get('messages', {}).get('matches', [])
print(f'Found {len(matches)} results:\n')
for m in matches:
    user = m.get('username', 'unknown')
    channel = m.get('channel', {}).get('name', 'unknown')
    text = m.get('text', '')[:300]
    permalink = m.get('permalink', '')
    print(f'#{channel} | @{user}')
    print(f'{text}')
    print(f'{permalink}')
    print('---')
"
```

## Search Files

```bash
curl -s -X POST 'https://slack.com/api/search.files' \
  -H "Authorization: Bearer $SLACK_USER_TOKEN" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "query=YOUR_SEARCH_TERM&count=10" | python3 -m json.tool
```

## Read Channel History

```bash
curl -s "https://slack.com/api/conversations.history?channel=CHANNEL_ID&limit=50" \
  -H "Authorization: Bearer $SLACK_BOT_TOKEN" | python3 -m json.tool
```

### Known channels (bot is member of)
| Channel | ID |
|---------|-----|
| neverwait | CP4RACY4T |
| the-porch | C0AHZ66NSJY |

## Read Thread Replies

```bash
curl -s "https://slack.com/api/conversations.replies?channel=CHANNEL_ID&ts=THREAD_TS" \
  -H "Authorization: Bearer $SLACK_BOT_TOKEN" | python3 -m json.tool
```

## Get User Info

```bash
curl -s "https://slack.com/api/users.info?user=USER_ID" \
  -H "Authorization: Bearer $SLACK_BOT_TOKEN" | python3 -m json.tool
```

## When to Use This Skill

- Looking for past team discussions or decisions
- Finding context about a project, feature, or bug
- Searching for shared links, documents, or resources
- Understanding what was discussed about a topic
- Finding messages from specific people or channels
