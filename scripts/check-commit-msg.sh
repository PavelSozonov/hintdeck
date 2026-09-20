#!/bin/bash
# Commit message policy. Usage:
#   check-commit-msg.sh <file>          — the commit-msg hook: checks the message in <file>
#   check-commit-msg.sh --range A..B    — CI: checks every commit in the range
#   check-commit-msg.sh --title "<t>"   — CI: checks a pull request title (it becomes the squash subject)
set -euo pipefail
SUBJECT='^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([a-z0-9._/-]+\))?!?: [^ ].*$'
cyrillic="$(printf '[\320-\323]')"

check() { # check <label> <message>
  local label="$1" msg="$2" subject bad=0
  subject="$(printf '%s\n' "$msg" | grep -v '^#' | sed -n '1p')"
  case "$subject" in "Merge "*|"Revert \""*|"fixup! "*|"squash! "*) return 0 ;; esac
  if ! printf '%s\n' "$subject" | grep -Eq "$SUBJECT"; then
    echo "$label: the subject is not a Conventional Commit: '$subject'"
    echo "  expected <type>(<scope>): <description>, type one of feat fix docs style refactor perf test build ci chore revert"
    bad=1
  fi
  if [ "${#subject}" -gt 100 ]; then echo "$label: the subject is longer than 100 characters"; bad=1; fi
  if printf '%s\n' "$msg" | grep -v '^#' | grep -Eiq '^co-authored-by:'; then echo "$label: no Co-Authored-By trailers"; bad=1; fi
  if printf '%s\n' "$msg" | grep -v '^#' | LC_ALL=C grep -q "$cyrillic"; then echo "$label: commit messages are written in English"; bad=1; fi
  return "$bad"
}

rc=0
case "${1:-}" in
  --range) for c in $(git rev-list "$2"); do check "$(git rev-parse --short "$c")" "$(git log -1 --format=%B "$c")" || rc=1; done ;;
  --title) check "pull request title" "$2" || rc=1 ;;
  "")      echo "usage: $0 <file> | --range A..B | --title <title>"; exit 2 ;;
  *)       check "commit message" "$(cat "$1")" || rc=1 ;;
esac
[ "$rc" = "0" ] && echo "OK: commit messages follow the policy"
exit "$rc"
