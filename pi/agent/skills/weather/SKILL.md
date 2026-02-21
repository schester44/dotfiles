---
name: weather
description: Use when the user asks about weather, forecasts, or needs weather data for a location
---

# Weather

Fetch weather data using wttr.in (no API key required).

## IMPORTANT: Always Use JSON Format

**Always use `?format=j1` for weather queries.** This enables rich UI rendering of weather data.

```bash
# ALWAYS use this format for weather queries:
curl -s "wttr.in/Seattle?format=j1"
```

The JSON response will be automatically rendered as a beautiful weather card in the UI.

## Examples

```bash
# City name (ALWAYS use format=j1)
curl -s "wttr.in/NYC?format=j1"

# By coordinates
curl -s "wttr.in/47.6,-122.3?format=j1"

# Airport code
curl -s "wttr.in/JFK?format=j1"
```

## Notes

- Supports city names, airport codes, coordinates, IP addresses
- Add `?m` for metric (before format), `?u` for USCS units
- Rate limited - don't spam requests
- The UI will render a weather card automatically from the JSON response
