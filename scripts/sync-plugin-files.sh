#!/bin/bash
# The Claude plugin directory reads only the plugin folder: its README becomes the listing, and
# people who install the plugin receive nothing outside it. Three files there are therefore
# derived from files that live elsewhere in the repository:
#
#   plugins/hintdeck/README.md                   <- README.md, with links rewritten
#   plugins/hintdeck/LICENSE                     <- LICENSE
#   plugins/hintdeck/skills/tip-slides/tip.sh    <- plugins/hintdeck/skills/tip/tip.sh
#
# Usage: sync-plugin-files.sh           regenerate the derived files
#        sync-plugin-files.sh --check   fail if any of them is out of date (pre-commit and CI)
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
PLUGIN=plugins/hintdeck
REPO_URL=https://github.com/PavelSozonov/hintdeck/blob/main
MODE="${1:-write}"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# Links in the root README are relative to the repository; in the plugin folder they must point
# inside that folder, or to GitHub for files the plugin folder does not hold.
{
  echo "<!-- Generated from the repository README by scripts/sync-plugin-files.sh. Edit that file, not this one. -->"
  sed -e "s|](${PLUGIN}/|](|g" \
      -e "s|](SECURITY\.md)|](${REPO_URL}/SECURITY.md)|g" \
      -e "s|](CONTRIBUTING\.md)|](${REPO_URL}/CONTRIBUTING.md)|g" \
      -e "s|](CHANGELOG\.md)|](${REPO_URL}/CHANGELOG.md)|g" README.md
} > "$tmp/README.md"
cp LICENSE "$tmp/LICENSE"
cp "$PLUGIN/skills/tip/tip.sh" "$tmp/tip.sh"

rc=0
sync() { # sync <generated> <target>
  if [ "$MODE" = "--check" ]; then
    if ! cmp -s "$1" "$2"; then echo "out of date: $2 — run scripts/sync-plugin-files.sh"; rc=1; fi
  else
    mkdir -p "$(dirname "$2")"; cp "$1" "$2"
  fi
}
sync "$tmp/README.md" "$PLUGIN/README.md"
sync "$tmp/LICENSE"   "$PLUGIN/LICENSE"
sync "$tmp/tip.sh"    "$PLUGIN/skills/tip-slides/tip.sh"
[ "$MODE" = "--check" ] || chmod +x "$PLUGIN/skills/tip-slides/tip.sh"
[ "$rc" = "0" ] && [ "$MODE" = "--check" ] && echo "OK: the derived plugin files are in sync"
exit "$rc"
