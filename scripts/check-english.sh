#!/bin/bash
# Language policy: everything in this repository is English, except the translated tip catalogs
# and the few files that quote localized reply labels or match language names.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
ALLOWED='^plugins/hintdeck/skills/tip/decks/[^/]+/[a-z-]+/|^plugins/hintdeck/skills/tip/(SKILL|REFRESH)\.md$|^plugins/hintdeck/skills/tip-slides/SKILL\.md$|^plugins/hintdeck/skills/tip/tip\.sh$'
CANON='^plugins/hintdeck/skills/tip/decks/[^/]+/en/'
cyrillic="$(printf '[\320-\323]')"   # UTF-8 lead bytes of U+0400–U+04FF
bad=0
while IFS= read -r f; do
  [ -f "$f" ] || continue
  case "$f" in *.png|*.gif|*.jpg|*.woff2) continue ;; esac
  if printf '%s\n' "$f" | grep -Eq "$ALLOWED" && ! printf '%s\n' "$f" | grep -Eq "$CANON"; then continue; fi
  if LC_ALL=C grep -n "$cyrillic" "$f" >/dev/null 2>&1; then
    echo "non-English text in $f:"; LC_ALL=C grep -n "$cyrillic" "$f" | head -3 | sed 's/^/  /'
    bad=1
  fi
done < <(git ls-files)
[ "$bad" = "0" ] && echo "OK: English everywhere outside the translated catalogs"
exit "$bad"
