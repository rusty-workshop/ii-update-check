#!/usr/bin/env bash
# Notifies when end-4/dots-hyprland (illogical-impulse) has new upstream
# commits since the last check. Never pulls or applies anything itself —
# the installer touches too much (system packages, configs) to run
# unattended; this just tells Rusty there's something to look at.
set -euo pipefail

REPO="end-4/dots-hyprland"
STATE_FILE="$HOME/.cache/ii-update-check/last-seen-sha"
STATUS_FILE="$HOME/.local/state/ii-update-check/status.json"
mkdir -p "$(dirname "$STATE_FILE")" "$(dirname "$STATUS_FILE")"

write_status() {
  printf '{"last_run":"%s","latest_sha":"%s","has_update":%s}\n' \
    "$(date -Iseconds)" "$1" "$2" > "$STATUS_FILE"
}

LATEST_SHA=$(curl -fsS "https://api.github.com/repos/$REPO/commits/main" \
  -H "Accept: application/vnd.github+json" | jq -r '.sha')

if [ -z "$LATEST_SHA" ]; then
  echo "Failed to fetch latest commit for $REPO" >&2
  exit 1
fi

if [ ! -f "$STATE_FILE" ]; then
  echo "$LATEST_SHA" > "$STATE_FILE"
  echo "First run: recorded $LATEST_SHA as baseline, no notification sent."
  write_status "$LATEST_SHA" false
  exit 0
fi

LAST_SHA=$(cat "$STATE_FILE")

if [ "$LATEST_SHA" != "$LAST_SHA" ]; then
  SHORT=${LATEST_SHA:0:7}
  echo "New commit(s) on $REPO main: $SHORT (was ${LAST_SHA:0:7})"
  if command -v notify-send >/dev/null; then
    notify-send "illogical-impulse update available" \
      "$REPO has new commits ($SHORT). Check the changelog before pulling: https://github.com/$REPO/commits/main"
  fi
  echo "$LATEST_SHA" > "$STATE_FILE"
  write_status "$LATEST_SHA" true
else
  echo "No new commits on $REPO main."
  write_status "$LATEST_SHA" false
fi
