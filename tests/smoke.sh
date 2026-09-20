#!/bin/bash
# Smoke test for tip.sh: the guarantees the skills rely on, on an isolated state.
# Runs on the system bash and awk of Linux (mawk/gawk) and macOS (bash 3.2, BWK awk).
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILL="$ROOT/plugins/hintdeck/skills/tip"
TIP="$SKILL/tip.sh"
WRAPPER="$ROOT/plugins/hintdeck/skills/tip-slides/tip.sh"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
export HINTDECK_STATE_DIR="$WORK/state"
export CLAUDE_CONFIG_DIR="$WORK/config"   # no user settings: deterministic signals and language
unset HINTDECK_LANG HINTDECK_DECK
mkdir -p "$CLAUDE_CONFIG_DIR" "$WORK/bin"

# A fake `claude` so the version filter is deterministic; FAKE_CLI_VERSION picks the version.
cat > "$WORK/bin/claude" <<'SH'
#!/bin/bash
echo "${FAKE_CLI_VERSION:-9.9.9} (Claude Code)"
SH
chmod +x "$WORK/bin/claude"
export PATH="$WORK/bin:$PATH"

pass=0; failed=0
ok()   { pass=$((pass + 1)); echo "ok   - $1"; }
fail() { failed=$((failed + 1)); echo "FAIL - $1"; [ -n "${2:-}" ] && printf '       %s\n' "$2"; }
check() { # check <description> <haystack> <needle>
  case "$2" in *"$3"*) ok "$1" ;; *) fail "$1" "expected to find: $3" ;; esac
}
refute() { case "$2" in *"$3"*) fail "$1" "did not expect: $3" ;; *) ok "$1" ;; esac; }
ticket()   { "$TIP" list | awk '/^ticket:/ { print $2 }'; }
unseen_id(){ "$TIP" list | awk -F' [|] ' '/^#[0-9]+ [|] / { print $2; exit }'; }

out="$("$TIP" list)"
check "list reports the default language"        "$out" "lang: en (source: default)"
check "list issues a ticket"                     "$out" "ticket: t"
n="$(printf '%s\n' "$out" | grep -c '^#[0-9]* | ')"
[ "$n" -gt 100 ] && ok "list shows the unseen tips ($n)" || fail "list shows the unseen tips" "got $n rows"

id1="$(unseen_id)"; t1="$(ticket)"
out="$("$TIP" take "$id1" "$t1")"
check "take prints the tip"                      "$out" "## $id1"
check "take prints the number and the language"  "$out" "reply-lang: en"
num1="$(printf '%s\n' "$out" | sed -n 's/^number: \([0-9]*\).*/\1/p')"

out="$("$TIP" take "$(unseen_id)" "$t1")"
check "a ticket yields exactly one tip"          "$out" "REFUSED: the ticket is not valid"

t2="$(ticket)"
out="$("$TIP" take "$id1" "$t2")"
check "a shown tip is never taken again"         "$out" "REFUSED: tip '$id1' was already shown"
refute "a shown tip leaves the unseen list"      "$("$TIP" list)" "| $id1 |"
out="$("$TIP" take "$(unseen_id)" "$t2")"
check "a refusal does not burn the ticket"       "$out" "number: "

out="$("$TIP" show "#$num1" "$(ticket)")"
check "show returns a tip by its number"         "$out" "## $id1"
check "show marks a repeat"                      "$out" "repeat: first shown on"
out="$("$TIP" take no-such-tip "$(ticket)")"
check "an unknown id is refused"                 "$out" "REFUSED: there is no tip"
rows="$("$TIP" history | grep -c '^#[0-9]')"
[ "$rows" = "2" ] && ok "history lists the shown tips" || fail "history lists the shown tips" "got $rows rows"

en_title="$("$TIP" list | awk -F' [|] ' '/^#[0-9]+ [|] / { print $4; exit }')"
check "lang saves the choice"                    "$("$TIP" lang ru)" "tip language saved: ru"
out="$("$TIP" list)"
check "the saved language is used"               "$out" "lang: ru (source: saved)"
ru_title="$(printf '%s\n' "$out" | awk -F' [|] ' '/^#[0-9]+ [|] / { print $4; exit }')"
[ -n "$ru_title" ] && [ "$ru_title" != "$en_title" ] && ok "titles come from the translation" || fail "titles come from the translation" "en='$en_title' ru='$ru_title'"
check "the take output follows the language"     "$("$TIP" take "$(unseen_id)" "$(ticket)")" "reply-lang: ru"
check "HINTDECK_LANG overrides the saved choice" "$(HINTDECK_LANG=en "$TIP" lang)" "lang: en (source: env)"
check "an unknown language is refused"           "$("$TIP" lang xx)" "REFUSED: no catalog for"
"$TIP" lang auto >/dev/null
check "lang auto forgets the choice"             "$("$TIP" lang)" "lang: en (source: default)"
printf '{\n  "language": "russian"\n}\n' > "$CLAUDE_CONFIG_DIR/settings.json"
check "Claude Code's language setting is honoured" "$("$TIP" lang)" "lang: ru (source: claude-code-setting)"
rm -f "$CLAUDE_CONFIG_DIR/settings.json"

refute "tips newer than the CLI are hidden"      "$(FAKE_CLI_VERSION=2.1.200 "$TIP" list)" "| new-send-now |"
check  "and shown once the CLI catches up"       "$(FAKE_CLI_VERSION=9.9.9 "$TIP" list)"   "| new-send-now |"
printf '{\n  "statusLine": {"type": "command"}\n}\n' > "$CLAUDE_CONFIG_DIR/settings.json"
refute "skip-if hides what the user already has" "$("$TIP" list)" "| cmd-statusline |"
rm -f "$CLAUDE_CONFIG_DIR/settings.json"

check "the tip-slides wrapper reaches tip.sh"    "$("$WRAPPER" status)" "deck: claude-code"
dir="$("$WRAPPER" slides-dir)"
[ -d "$dir" ] && ok "slides-dir creates the directory" || fail "slides-dir creates the directory" "$dir"

"$TIP" lint --strict >/dev/null && ok "lint --strict passes on the catalog" || fail "lint --strict passes on the catalog"

# Work on a copy for anything that edits the catalog.
cp -R "$SKILL" "$WORK/skill"
"$WORK/skill/tip.sh" number >/dev/null 2>&1
diff -r "$SKILL/decks" "$WORK/skill/decks" >/dev/null && ok "number is idempotent" || fail "number is idempotent" "$(diff -r "$SKILL/decks" "$WORK/skill/decks" | head -3)"
first="$(ls "$WORK/skill/decks/claude-code/en"/*.md | head -1)"
printf '\n## %s — Duplicate\n<!-- n: 1; verified: 0.0.0 -->\nText.\n\n**Try it:** x\n' "$id1" >> "$first"
if "$WORK/skill/tip.sh" lint --strict >/dev/null; then fail "lint fails on a duplicate id"; else ok "lint fails on a duplicate id"; fi

"$TIP" list | awk -F' [|] ' -v d="$(date +%Y-%m-%d)" '/^#[0-9]+ [|] / { print $2 "\t" d }' >> "$HINTDECK_STATE_DIR/claude-code/shown.tsv"
check "an exhausted deck says so"                "$("$TIP" list)" "EXHAUSTED"
"$TIP" reset >/dev/null
refute "reset starts the deck over"              "$("$TIP" list)" "EXHAUSTED"

echo
echo "passed: $pass, failed: $failed"
[ "$failed" = "0" ]
