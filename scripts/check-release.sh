#!/bin/bash
# Release rules, checked against the base branch. Usage: check-release.sh <base-ref>
#
# 1. Permanent numbers: a tip's number never changes and is never reused.
# 2. Versioning: plugin.json sets an explicit version, so installed users receive an update only
#    when that version changes. Any change under plugins/hintdeck/ must bump it and must have a
#    CHANGELOG.md entry.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
BASE="${1:?usage: check-release.sh <base-ref>}"
PLUGIN=plugins/hintdeck
DECKS="$PLUGIN/skills/tip/decks"
bad=0

pairs() { # pairs <ref|WORKTREE> <deck> — lines "n<TAB>id" of the canonical catalog
  local ref="$1" deck="$2" f
  if [ "$ref" = "WORKTREE" ]; then
    for f in "$DECKS/$deck/en"/*.md; do [ -f "$f" ] && cat "$f"; done
  else
    git ls-tree -r --name-only "$ref" -- "$DECKS/$deck/en" 2>/dev/null | while read -r f; do git show "$ref:$f"; done
  fi | awk '/^## / { id = $2 } /^<!--/ && id != "" { if (match($0, /n:[ ]*[0-9]+/)) { n = substr($0, RSTART, RLENGTH); gsub(/[^0-9]/, "", n); print n "\t" id } id = "" }'
}

for d in "$DECKS"/*/; do
  deck="$(basename "$d")"
  old="$(mktemp)"; new="$(mktemp)"
  pairs "$BASE" "$deck" > "$old"; pairs WORKTREE "$deck" > "$new"
  base_last="$(git show "$BASE:$DECKS/$deck/.last-number" 2>/dev/null || echo 0)"
  head_last="$(cat "$DECKS/$deck/.last-number" 2>/dev/null || echo 0)"
  if [ "$head_last" -lt "$base_last" ]; then echo "$deck: .last-number went backwards ($base_last -> $head_last)"; bad=1; fi
  out="$(awk -F'\t' -v old="$old" -v last="$base_last" -v deck="$deck" '
    BEGIN { while ((getline l < old) > 0) { split(l, a, "\t"); was[a[1]] = a[2]; num[a[2]] = a[1] } }
    { if (($2 in num) && num[$2] != $1) print deck ": tip " $2 " changed its number from " num[$2] " to " $1 " — numbers are permanent"
      if ($1 in was) { if (was[$1] != $2) print deck ": number " $1 " moved from " was[$1] " to " $2 " — numbers are permanent" }
      else if ($1 + 0 <= last + 0) print deck ": new tip " $2 " reuses number " $1 " — run tip.sh number instead of writing n by hand" }' "$new")"
  if [ -n "$out" ]; then printf '%s\n' "$out"; bad=1; fi
  rm -f "$old" "$new"
done

if ! git diff --quiet "$BASE" -- "$PLUGIN"; then
  old_v="$(git show "$BASE:$PLUGIN/.claude-plugin/plugin.json" 2>/dev/null | sed -n 's/.*"version"[^"]*"\([^"]*\)".*/\1/p' | head -1)"
  new_v="$(sed -n 's/.*"version"[^"]*"\([^"]*\)".*/\1/p' "$PLUGIN/.claude-plugin/plugin.json" | head -1)"
  if [ "$old_v" = "$new_v" ]; then
    echo "files under $PLUGIN changed but the version is still $new_v."
    echo "  Installed users only receive an update when the version changes: bump it in $PLUGIN/.claude-plugin/plugin.json"
    bad=1
  elif [ "$(printf '%s\n%s\n' "$old_v" "$new_v" | sort -t. -k1,1n -k2,2n -k3,3n | tail -1)" != "$new_v" ]; then
    echo "the version went backwards: $old_v -> $new_v"; bad=1
  fi
  if ! grep -Eq "^## \[?$new_v\]?" CHANGELOG.md 2>/dev/null; then
    echo "CHANGELOG.md has no entry for $new_v"; bad=1
  fi
fi
[ "$bad" = "0" ] && echo "OK: numbers are stable and the release rules hold against $BASE"
exit "$bad"
