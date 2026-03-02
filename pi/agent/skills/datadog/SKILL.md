---
name: datadog
description: Query Datadog APM traces, spans, and logs using the Datadog API. Use when investigating production issues, analyzing trace data, or debugging performance problems.
---

# Datadog API Skill

Query Datadog APM data (traces, spans, logs) via the REST API.

## Required Environment Variables

The following credentials must be set:

| Variable | Description |
|----------|-------------|
| `DD_API_KEY` | Datadog API Key |
| `DD_APP_KEY` | Datadog Application Key |

Ensure these are exported before making API calls.

## Configuration

- **Site**: `us5.datadoghq.com` (configured in `/opt/datadog-agent/etc/datadog.yaml`)
- **Base URL**: `https://api.us5.datadoghq.com`

## API Endpoints

### Search Spans by Trace ID

```bash
DD_API_KEY="<from 1password>"
DD_APP_KEY="<from 1password>"

curl -s -X POST "https://api.us5.datadoghq.com/api/v2/spans/events/search" \
  -H "Content-Type: application/json" \
  -H "DD-API-KEY: ${DD_API_KEY}" \
  -H "DD-APPLICATION-KEY: ${DD_APP_KEY}" \
  -d '{
    "data": {
      "type": "search_request",
      "attributes": {
        "filter": {
          "query": "trace_id:<TRACE_ID>",
          "from": "now-30d",
          "to": "now"
        },
        "sort": "timestamp",
        "page": {
          "limit": 1000
        }
      }
    }
  }'
```

### Search for Error Spans

```bash
curl -s -X POST "https://api.us5.datadoghq.com/api/v2/spans/events/search" \
  -H "Content-Type: application/json" \
  -H "DD-API-KEY: ${DD_API_KEY}" \
  -H "DD-APPLICATION-KEY: ${DD_APP_KEY}" \
  -d '{
    "data": {
      "type": "search_request",
      "attributes": {
        "filter": {
          "query": "trace_id:<TRACE_ID> status:error",
          "from": "now-30d",
          "to": "now"
        },
        "page": {
          "limit": 100
        }
      }
    }
  }'
```

### Search Spans by Service and Time Range

```bash
curl -s -X POST "https://api.us5.datadoghq.com/api/v2/spans/events/search" \
  -H "Content-Type: application/json" \
  -H "DD-API-KEY: ${DD_API_KEY}" \
  -H "DD-APPLICATION-KEY: ${DD_APP_KEY}" \
  -d '{
    "data": {
      "type": "search_request",
      "attributes": {
        "filter": {
          "query": "service:obie env:production",
          "from": "now-1h",
          "to": "now"
        },
        "sort": "-duration",
        "page": {
          "limit": 50
        }
      }
    }
  }'
```

## Useful Query Filters

| Filter | Example | Description |
|--------|---------|-------------|
| `trace_id` | `trace_id:309001704310680030` | Find all spans in a trace |
| `service` | `service:obie` | Filter by service name |
| `env` | `env:production` | Filter by environment |
| `status` | `status:error` | Find error spans |
| `operation_name` | `operation_name:pg.query` | Filter by operation type |
| `resource_name` | `resource_name:*invoices*` | Filter by resource |
| `@duration` | `@duration:>1000000000` | Duration > 1 second (in nanoseconds) |
| `@http.status_code` | `@http.status_code:500` | HTTP status codes |

## Analyzing Trace Data with jq

### Extract key span information

```bash
curl ... | jq '[.data[] | {
  span_id: .attributes.span_id,
  parent_id: .attributes.parent_id,
  operation: .attributes.operation_name,
  resource: (.attributes.resource_name | if length > 80 then .[0:80] + "..." else . end),
  service: .attributes.service,
  status: .attributes.status,
  error: .attributes.error,
  duration_ms: (.attributes.custom.duration / 1000000),
  start: .attributes.start_timestamp,
  end: .attributes.end_timestamp
}] | sort_by(.start)'
```

### Find slowest spans (>100ms)

```bash
curl ... | jq '[.[] | select(.duration_ns > 100000000) | {
  operation: .operation,
  resource: .resource,
  duration_ms: (.duration_ns / 1000000)
}] | sort_by(-.duration_ms)'
```

### Get trace summary

```bash
curl ... | jq '{
  total_spans: length,
  earliest_start: [.[].start] | min,
  latest_end: [.[].end] | max,
  unique_services: ([.[].service] | unique),
  total_db_queries: [.[] | select(.operation == "pg.query")] | length,
  total_http_requests: [.[] | select(.operation | test("http"))] | length
}'
```

## Response Structure

Key fields in span data:

```json
{
  "attributes": {
    "span_id": "1234567890",
    "parent_id": "0987654321",
    "trace_id": "309001704310680030",
    "operation_name": "pg.query",
    "resource_name": "SELECT * FROM users WHERE id = ?",
    "service": "obie-postgres",
    "status": "ok",
    "error": null,
    "start_timestamp": "2026-02-27T06:00:00.034Z",
    "end_timestamp": "2026-02-27T06:00:00.134Z",
    "custom": {
      "duration": 100000000,
      "db.statement": "SELECT * FROM users...",
      "db.system": "postgres"
    }
  }
}
```

## Common Issues to Look For

1. **N+1 Queries**: High number of similar DB queries (100s of `pg.query` spans)
2. **Slow Queries**: `duration` > 100ms for database operations
3. **External API Latency**: HTTP requests to external services taking > 500ms
4. **Error Spans**: `status: "error"` or `error` field populated
5. **Missing Indexes**: Repeated slow queries on same tables

## Pagination

Results are paginated. Check `meta.page.after` for cursor:

```bash
# Follow pagination
curl ... | jq '.links.next'
```

## Rate Limits

- API rate limits apply
- Use appropriate time ranges to reduce data volume
- Maximum 1000 spans per request
