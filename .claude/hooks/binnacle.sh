#!/usr/bin/env bash
# Binnacle reminder. Wired in .claude/settings.json:
#   PostToolUse (Write|Edit) -> `binnacle.sh mark`: remember that a file outside binnacle/ changed this session.
#   Stop                     -> `binnacle.sh check`: if something changed, ask Claude once to log it in binnacle/.
set -u

mode="${1:-}"
input="$(cat)"
sid="$(jq -r '.session_id // "nosession"' <<<"$input")"
flag="${TMPDIR:-/tmp}/claude-binnacle-$sid"

case "$mode" in
  mark)
    file="$(jq -r '.tool_input.file_path // empty' <<<"$input")"
    case "$file" in
      "" | */binnacle/*) exit 0 ;;
    esac
    : >"$flag"
    ;;
  check)
    # The block below makes Claude continue; on that second stop, let it finish.
    [ "$(jq -r '.stop_hook_active // false' <<<"$input")" = "true" ] && exit 0
    [ -f "$flag" ] || exit 0
    rm -f "$flag"
    today="$(date +%Y%m%d)"
    reason="Files changed this turn. Before finishing, log it in binnacle/ (see the format of existing entries there): if a binnacle/${today}-*.md entry already covers this topic, update it; otherwise create binnacle/${today}-<slug>.md. Write it in Spanish and cover what was done, what was tried and discarded, and what is still open. Do not touch CHANGELOG files, and do not use em dashes. If the changes were trivial and not worth a log entry, skip it and say so in one line."
    jq -n --arg r "$reason" '{decision: "block", reason: $r}'
    ;;
esac
