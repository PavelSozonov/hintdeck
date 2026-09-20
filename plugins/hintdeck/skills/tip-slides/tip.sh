#!/bin/bash
# Wrapper: tip-slides shares the catalog, the shown history and the numbering of the `tip` skill.
BASE="$(cd "$(dirname "$0")/../tip" 2>/dev/null && pwd)"
if [ -z "$BASE" ] || [ ! -x "$BASE/tip.sh" ]; then
  echo "ERROR: the tip skill was not found next to this one (expected ../tip/tip.sh) — tip-slides runs on top of its catalog."
  exit 0
fi
exec "$BASE/tip.sh" "$@"
