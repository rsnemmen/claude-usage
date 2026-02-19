#!/usr/bin/env bash
#<xbar.title>Claude Usage</xbar.title>
#<xbar.version>1.0</xbar.version>
#<xbar.author>Rodrigo Nemmen da Silva</xbar.author>
#<xbar.desc>Display Claude Code API rate limit utilization</xbar.desc>
#<xbar.dependencies>curl,python3</xbar.dependencies>

# User variables
# ================
#<xbar.var>boolean(VAR_SHOW_7D="false"): Also show 7-day window in title (e.g. 45%/23%).</xbar.var>
#<xbar.var>boolean(VAR_COLORS="true"): Color-code title at warning (>75%) and critical (>90%) levels.</xbar.var>
#<xbar.var>boolean(VAR_SHOW_RESET="true"): Show time-until-reset for each window in the dropdown.</xbar.var>

SHOW_7D="${VAR_SHOW_7D:-false}"
COLORS="${VAR_COLORS:-true}"
SHOW_RESET="${VAR_SHOW_RESET:-true}"

CLAUDE_ICON="iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAASBlWElmTU0AKgAAAAgABwESAAMAAAABAAEAAAEaAAUAAAABAAAAYgEbAAUAAAABAAAAagEoAAMAAAABAAIAAAExAAIAAABDAAAAcgE7AAIAAAAbAAAAtodpAAQAAAABAAAA0gAAAAAAAqY3AAAJbAACpjcAAAlsQ2FudmEgZG9jPURBRy1fU2thMlpFIHVzZXI9VUFETjFRbC1vQWcgYnJhbmQ9QkFETjFRcVFyMTggdGVtcGxhdGU9AABBbHkg4oCcU3Rqb3VzYW1h4oCdIFlJTE1BWgAAAAaQAAAHAAAABDAyMTCRAQAHAAAABAECAwCgAAAHAAAABDAxMDCgAQADAAAAAQABAACgAgAEAAAAAQAAABCgAwAEAAAAAQAAABAAAAAA3fObhwAAAAlwSFlzAAALEgAACxIB0t1+/AAABmRpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhNUCBDb3JlIDYuMC4wIj4KICAgPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICAgICAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6ZXhpZj0iaHR0cDovL25zLmFkb2JlLmNvbS9leGlmLzEuMC8iCiAgICAgICAgICAgIHhtbG5zOnhtcD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wLyIKICAgICAgICAgICAgeG1sbnM6dGlmZj0iaHR0cDovL25zLmFkb2JlLmNvbS90aWZmLzEuMC8iCiAgICAgICAgICAgIHhtbG5zOmRjPSJodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyI+CiAgICAgICAgIDxleGlmOkNvbG9yU3BhY2U+NjU1MzU8L2V4aWY6Q29sb3JTcGFjZT4KICAgICAgICAgPGV4aWY6UGl4ZWxYRGltZW5zaW9uPjEwMjQ8L2V4aWY6UGl4ZWxYRGltZW5zaW9uPgogICAgICAgICA8ZXhpZjpFeGlmVmVyc2lvbj4wMjEwPC9leGlmOkV4aWZWZXJzaW9uPgogICAgICAgICA8ZXhpZjpGbGFzaFBpeFZlcnNpb24+MDEwMDwvZXhpZjpGbGFzaFBpeFZlcnNpb24+CiAgICAgICAgIDxleGlmOlBpeGVsWURpbWVuc2lvbj4xMDI0PC9leGlmOlBpeGVsWURpbWVuc2lvbj4KICAgICAgICAgPGV4aWY6Q29tcG9uZW50c0NvbmZpZ3VyYXRpb24+CiAgICAgICAgICAgIDxyZGY6U2VxPgogICAgICAgICAgICAgICA8cmRmOmxpPjE8L3JkZjpsaT4KICAgICAgICAgICAgICAgPHJkZjpsaT4yPC9yZGY6bGk+CiAgICAgICAgICAgICAgIDxyZGY6bGk+MzwvcmRmOmxpPgogICAgICAgICAgICAgICA8cmRmOmxpPjA8L3JkZjpsaT4KICAgICAgICAgICAgPC9yZGY6U2VxPgogICAgICAgICA8L2V4aWY6Q29tcG9uZW50c0NvbmZpZ3VyYXRpb24+CiAgICAgICAgIDx4bXA6Q3JlYXRvclRvb2w+Q2FudmEgZG9jPURBRy1fU2thMlpFIHVzZXI9VUFETjFRbC1vQWcgYnJhbmQ9QkFETjFRcVFyMTggdGVtcGxhdGU9PC94bXA6Q3JlYXRvclRvb2w+CiAgICAgICAgIDx0aWZmOlJlc29sdXRpb25Vbml0PjI8L3RpZmY6UmVzb2x1dGlvblVuaXQ+CiAgICAgICAgIDx0aWZmOk9yaWVudGF0aW9uPjE8L3RpZmY6T3JpZW50YXRpb24+CiAgICAgICAgIDx0aWZmOlhSZXNvbHV0aW9uPjcxOTgzLzEwMDA8L3RpZmY6WFJlc29sdXRpb24+CiAgICAgICAgIDx0aWZmOllSZXNvbHV0aW9uPjcxOTgzLzEwMDA8L3RpZmY6WVJlc29sdXRpb24+CiAgICAgICAgIDxkYzp0aXRsZT4KICAgICAgICAgICAgPHJkZjpBbHQ+CiAgICAgICAgICAgICAgIDxyZGY6bGkgeG1sOmxhbmc9IngtZGVmYXVsdCI+QWRzxLF6IHRhc2FyxLFtIC0gMTwvcmRmOmxpPgogICAgICAgICAgICA8L3JkZjpBbHQ+CiAgICAgICAgIDwvZGM6dGl0bGU+CiAgICAgICAgIDxkYzpjcmVhdG9yPgogICAgICAgICAgICA8cmRmOlNlcT4KICAgICAgICAgICAgICAgPHJkZjpsaT5BbHkg4oCcU3Rqb3VzYW1h4oCdIFlJTE1BWjwvcmRmOmxpPgogICAgICAgICAgICA8L3JkZjpTZXE+CiAgICAgICAgIDwvZGM6Y3JlYXRvcj4KICAgICAgPC9yZGY6RGVzY3JpcHRpb24+CiAgIDwvcmRmOlJERj4KPC94OnhtcG1ldGE+CvEDdfIAAAKvSURBVDgRdVJdSFRBFD5zZ3bXdVvZ0oxWZUvEF8OCsqhAXLQIJNOX3qMgKKiEhKIIkYIIUgh9CCqIHiOlkHCL/nwQrDDC8iG1MLNda2/3T1Pv3ntPM7ve9ac6MDPnzDnfd86cOQT+I/OolipAI8L9HSCxHd6OAolaq8PZ6gt9XmlgjDVbQKv8j2IBq/c5bCqNzBh1u98YaHSGSbB7OUZyDUSkmilfZ172kFJag+AEbEbB8eeANTS8JtVyNZp77eYDTf7a3orodXHZU1mQ22w0UU8pqJm/Mgt11HAGtXkZ5WcxTOxrwtmWC6iq3y5ngUJRTXXHrKUvGJa6BHZJxGlrnMpEZXQYE7WHUOnsMsdQ3yuwi0+wT/ioz+s4jrhbKZQCTiVgrvkikEAueE4fAamv35M/NnFUBEqIk37CWLUJuBIoLA/vscQXIkibi4HkBYBWV4HJbfv9SHUHfgmxEQis3zgwVGBPJ4E27gew7QwRZWD1PEnrrOkAeE/xhJYJxE8AC/OBJJIFlZCbL8V5CmfoA1rdsQxw+c7LB/4TIJ6WWkhXki6UV8B/jas+lMbBkaEkLBPNANRneMluWyxgDbXADtbyqhbnh/tQN4D8kIGEC5MCKx0n6zS6pbzfSwjY/YMA1LdUQ4oDxXKF+6yXg+CVKLBtFa8ENp1OLovccuqjZurGXXDGxnnzcgA4YVaEzu+Ez+q6B059jZksLbmd9QtFMeJts+cuYaKuEeXYY9R+/8wMkRikuSTKT/syg8RjRKwLzqZpxY/eM1roCty5f9bpfQGpUBBIpCjzuRNT4FH52+ujIB073N6Rp5xvJRWmIMkSuIyTqDSFhj+fTA2+24mT8SBvPZDisOHZtfW1WlnWVULW9rix/yRIOxGlAZDLNwArEvY0SFN7IPiJ9+WvUf0Dx59eemkgEEAAAAAASUVORK5CYII="

# === Retrieve credentials from Keychain ===

RAW_CREDS="$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)"

if [ -z "$RAW_CREDS" ]; then
  echo "⚠️ No Credentials"
  echo "---"
  echo "No Claude Code credentials found in Keychain."
  echo "Sign in to Claude Code first."
  exit 1
fi

TOKEN="$(printf '%s' "$RAW_CREDS" | python3 -c "
import json, sys
try:
    d = json.loads(sys.stdin.read().strip())
    if 'claudeAiOauth' in d:
        print(d['claudeAiOauth']['accessToken'])
    elif 'accessToken' in d:
        print(d['accessToken'])
    else:
        sys.exit(1)
except Exception:
    sys.exit(1)
" 2>/dev/null)"

if [ -z "$TOKEN" ]; then
  echo "⚠️ No Credentials"
  echo "---"
  echo "Could not parse Claude Code credentials."
  exit 1
fi

# === Fetch usage from API ===

response="$(curl -s -w "\n%{http_code}" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "anthropic-beta: oauth-2025-04-20" \
  -H "Accept: application/json" \
  "https://api.anthropic.com/api/oauth/usage")"

http_code="$(printf '%s\n' "$response" | tail -n 1)"
body="$(printf '%s\n' "$response" | sed '$d')"

if [ "$http_code" = "401" ]; then
  echo "⚠️ Token Expired"
  exit 1
elif [ "$http_code" -lt 200 ] 2>/dev/null || [ "$http_code" -ge 300 ] 2>/dev/null; then
  echo "⚠️ API Error ($http_code)"
  echo "Response: $body" >&2
  exit 1
fi

# === Parse JSON response ===

parsed="$(printf '%s' "$body" | python3 -c "
import json, sys
try:
    d = json.loads(sys.stdin.read())
    def get_val(window, field, default='0'):
        try:
            w = d.get(window)
            if not w:
                return default
            v = w.get(field)
            return str(v) if v is not None else default
        except Exception:
            return default
    print(get_val('five_hour',      'utilization', '0'))
    print(get_val('seven_day',      'utilization', '0'))
    print(get_val('seven_day_opus', 'utilization', '0'))
    print(get_val('five_hour',      'resets_at',   ''))
    print(get_val('seven_day',      'resets_at',   ''))
    print(get_val('seven_day_opus', 'resets_at',   ''))
except Exception as e:
    sys.stderr.write(str(e) + '\n')
    sys.exit(1)
" 2>/dev/null)"

if [ -z "$parsed" ]; then
  echo "⚠️ Parse Error"
  echo "Could not parse API response: $body" >&2
  exit 1
fi

UTIL_5H="$(      printf '%s\n' "$parsed" | sed -n '1p')"
UTIL_7D="$(      printf '%s\n' "$parsed" | sed -n '2p')"
UTIL_7D_OPUS="$( printf '%s\n' "$parsed" | sed -n '3p')"
RESET_5H="$(     printf '%s\n' "$parsed" | sed -n '4p')"
RESET_7D="$(     printf '%s\n' "$parsed" | sed -n '5p')"
RESET_7D_OPUS="$(printf '%s\n' "$parsed" | sed -n '6p')"

# === Helper: round float to integer percentage ===

format_pct() {
  python3 -c "print(round(float('${1:-0}')))" 2>/dev/null || echo "0"
}

PCT_5H="$(      format_pct "$UTIL_5H")"
PCT_7D="$(      format_pct "$UTIL_7D")"
PCT_7D_OPUS="$( format_pct "$UTIL_7D_OPUS")"

# === Helper: human-readable countdown from ISO 8601 timestamp ===

time_until() {
  local ts="$1"
  [ -z "$ts" ] && echo "?" && return
  python3 -c "
from datetime import datetime, timezone
ts = '${ts}'
try:
    if ts.endswith('Z'):
        ts = ts[:-1] + '+00:00'
    reset = datetime.fromisoformat(ts)
    now = datetime.now(timezone.utc)
    diff = reset - now
    secs = diff.total_seconds()
    if secs <= 0:
        print('now')
    else:
        days  = int(secs // 86400)
        hours = int((secs % 86400) // 3600)
        mins  = int((secs % 3600) // 60)
        if days > 0:
            print(f'{days}d {hours}h')
        elif hours > 0:
            print(f'{hours}h {mins}m')
        else:
            print(f'{mins}m')
except Exception:
    print('?')
" 2>/dev/null || echo "?"
}

# === Helper: color for a given percentage ===

color_for_pct() {
  local pct=$1
  if [ "$COLORS" = "true" ]; then
    [ "$pct" -ge 90 ] 2>/dev/null && echo "#FF0000" && return
    [ "$pct" -ge 75 ] 2>/dev/null && echo "#FFD700" && return
  fi
  echo ""
}

# === Helper: ASCII progress bar (20 chars) ===

make_bar() {
  local pct="${1:-0}"
  local width=20
  local filled
  filled=$(python3 -c "print(min(int(round(${pct} * ${width} / 100)), ${width}))" 2>/dev/null || echo "0")
  local bar=""
  local i=1
  while [ "$i" -le "$width" ]; do
    if [ "$i" -le "$filled" ]; then
      bar="${bar}█"
    else
      bar="${bar}░"
    fi
    i=$((i + 1))
  done
  echo "$bar"
}

# === Build menu bar title ===

COLOR_5H="$(color_for_pct "$PCT_5H")"
COLOR_7D="$(color_for_pct "$PCT_7D")"

# For title, use the "most urgent" color (critical > warning > none)
title_color() {
  local c1="$1" c2="$2"
  [ "$c1" = "#FF0000" ] || [ "$c2" = "#FF0000" ] && echo "#FF0000" && return
  [ "$c1" = "#FFD700" ] || [ "$c2" = "#FFD700" ] && echo "#FFD700" && return
  echo ""
}

if [ "$SHOW_7D" = "true" ]; then
  TITLE_COLOR="$(title_color "$COLOR_5H" "$COLOR_7D")"
  TITLE="${PCT_5H}%/${PCT_7D}%"
else
  TITLE_COLOR="$COLOR_5H"
  TITLE="${PCT_5H}%"
fi

# Emit menu bar line
if [ -n "$TITLE_COLOR" ]; then
  echo "${TITLE} | templateImage=${CLAUDE_ICON} color=${TITLE_COLOR}"
else
  echo "${TITLE} | templateImage=${CLAUDE_ICON}"
fi

# === Dropdown ===

echo "---"

# --- 5h window ---
BAR_5H="$(make_bar "$PCT_5H")"
if [ -n "$COLOR_5H" ]; then
  echo "5h window | color=#888888"
  echo "5h: ${PCT_5H}% ${BAR_5H} | color=${COLOR_5H}"
else
  echo "5h window | color=#888888"
  echo "5h: ${PCT_5H}% ${BAR_5H}"
fi

if [ "$SHOW_RESET" = "true" ] && [ -n "$RESET_5H" ]; then
  UNTIL_5H="$(time_until "$RESET_5H")"
  echo "Resets in: ${UNTIL_5H} | color=#888888"
fi

echo "---"

# --- 7d window ---
COLOR_7D_VAL="$(color_for_pct "$PCT_7D")"
BAR_7D="$(make_bar "$PCT_7D")"
echo "7d window | color=#888888"
if [ -n "$COLOR_7D_VAL" ]; then
  echo "7d: ${PCT_7D}% ${BAR_7D} | color=${COLOR_7D_VAL}"
else
  echo "7d: ${PCT_7D}% ${BAR_7D}"
fi

if [ "$SHOW_RESET" = "true" ] && [ -n "$RESET_7D" ]; then
  UNTIL_7D="$(time_until "$RESET_7D")"
  echo "Resets in: ${UNTIL_7D} | color=#888888"
fi

echo "---"

# --- 7d Opus window ---
COLOR_OPUS="$(color_for_pct "$PCT_7D_OPUS")"
BAR_OPUS="$(make_bar "$PCT_7D_OPUS")"
echo "7d Opus window | color=#888888"
if [ -n "$COLOR_OPUS" ]; then
  echo "7d Opus: ${PCT_7D_OPUS}% ${BAR_OPUS} | color=${COLOR_OPUS}"
else
  echo "7d Opus: ${PCT_7D_OPUS}% ${BAR_OPUS}"
fi

if [ "$SHOW_RESET" = "true" ] && [ -n "$RESET_7D_OPUS" ]; then
  UNTIL_OPUS="$(time_until "$RESET_7D_OPUS")"
  echo "Resets in: ${UNTIL_OPUS} | color=#888888"
fi

echo "---"
echo "Refresh | refresh=true"
