#!/bin/bash
# Commit message policy. Usage:
#   check-commit-msg.sh <file>          — the commit-msg hook: checks the message in <file>
#   check-commit-msg.sh --range A..B    — CI: checks every commit in the range
#   check-commit-msg.sh --title "<t>"   — checks a pull request title
#   check-commit-msg.sh --pr            — CI: checks PR_TITLE and PR_BODY from the environment. Pull requests
#                                         are squash-merged, so these two become the commit on main; the
#                                         individual commits of a pull request are not checked.
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

check_body() { # the pull request description becomes the body of the squash commit
  local body="$1" bad=0
  if [ -z "$(printf '%s' "$body" | tr -d '[:space:]')" ]; then
    echo "pull request description: it is empty — describe what changes and why"; bad=1
  fi
  if printf '%s\n' "$body" | grep -q 'This text becomes the body of the squash commit'; then
    echo "pull request description: replace the template text with a description"; bad=1
  fi
  if printf '%s\n' "$body" | grep -Eiq '^co-authored-by:|generated with \[?claude code'; then
    echo "pull request description: no Co-Authored-By or other attribution lines — it becomes a commit message"; bad=1
  fi
  if printf '%s\n' "$body" | LC_ALL=C grep -q "$cyrillic"; then
    echo "pull request description: written in English"; bad=1
  fi
  return "$bad"
}

rc=0
case "${1:-}" in
  --pr)    check "pull request title" "${PR_TITLE:-}" || rc=1; check_body "${PR_BODY:-}" || rc=1 ;;
  --range) for c in $(git rev-list "$2"); do check "$(git rev-parse --short "$c")" "$(git log -1 --format=%B "$c")" || rc=1; done ;;
  --title) check "pull request title" "$2" || rc=1 ;;
  "")      echo "usage: $0 <file> | --range A..B | --title <title> | --pr"; exit 2 ;;
  *)       check "commit message" "$(cat "$1")" || rc=1 ;;
esac
[ "$rc" = "0" ] && echo "OK: the message follows the policy"
exit "$rc"
