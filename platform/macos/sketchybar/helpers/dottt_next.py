#!/usr/bin/env python3
"""Print the current/next calendar event from Dottt's cache, Dottt-style.

  in progress:      "Standup<TAB>12m left"
  later today:      "Honeycomb<TAB>in 1h 7m"
  nothing today:    (empty line; the bar item hides)

Title and time are tab-separated so the bar item can hide the title.

Reads `cachedEvents` from Dottt's preferences (com.dottt.app), a JSON list of
Google Calendar-shaped events. That key is Dottt's internal cache, not an API:
if a Dottt update changes it, this prints nothing rather than failing loudly.
"""

import json
import plistlib
import subprocess
from datetime import datetime

MAX_TITLE = 22


def load_events():
    out = subprocess.run(
        ["defaults", "export", "com.dottt.app", "-"],
        capture_output=True,
        check=True,
    ).stdout
    return json.loads(plistlib.loads(out)["cachedEvents"])


def duration(seconds):
    mins = max(1, round(seconds / 60))
    h, m = divmod(mins, 60)
    if h and m:
        return f"{h}h {m}m"
    return f"{h}h" if h else f"{m}m"


def title(event):
    s = " ".join((event.get("summary") or "(No title)").split())
    return s if len(s) <= MAX_TITLE else s[: MAX_TITLE - 1].rstrip() + "…"


def main():
    now = datetime.now().astimezone()
    timed = []
    for e in load_events():
        if e.get("hasDeclined"):
            continue
        start, end = e.get("start", {}), e.get("end", {})
        if "dateTime" not in start or "dateTime" not in end:
            continue  # all-day
        timed.append(
            (
                datetime.fromisoformat(start["dateTime"]),
                datetime.fromisoformat(end["dateTime"]),
                e,
            )
        )
    timed.sort(key=lambda t: t[0])

    for start, end, e in timed:
        if start <= now < end:
            print(f"{title(e)}\t{duration((end - now).total_seconds())} left")
            return
        if start > now:
            if start.astimezone().date() == now.date():
                print(f"{title(e)}\tin {duration((start - now).total_seconds())}")
            else:
                print()
            return
    print()


if __name__ == "__main__":
    try:
        main()
    except Exception:
        print()
