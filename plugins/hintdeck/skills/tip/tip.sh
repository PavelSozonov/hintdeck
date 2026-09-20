#!/bin/bash
# tip.sh — state keeping and tip delivery for the hintdeck skills.
# It enforces mechanically what a model cannot be trusted to remember:
# a tip is never repeated, and one skill invocation yields exactly one tip.
set -u
DIR="$(cd "$(dirname "$0")" && pwd)"
DECK="${HINTDECK_DECK:-claude-code}"
DECK_DIR="$DIR/decks/$DECK"
# State lives outside the skill directory: it survives plugin updates and stays out of git.
ROOT="${HINTDECK_STATE_DIR:-${CLAUDE_CONFIG_DIR:-$HOME/.claude}/hintdeck}"
STATE="$ROOT/$DECK"
SHOWN="$STATE/shown.tsv"
# The version the catalog was verified against is a property of the catalog, so it ships with it.
REFRESHED="$DECK_DIR/.verified-version"
TICKETS="$ROOT/tickets"
CHANGELOG_URL="https://code.claude.com/docs/en/changelog.md"
DEFAULT_LANG="en"
mkdir -p "$STATE" "$TICKETS"
touch "$SHOWN"

cli_version() { claude --version 2>/dev/null | awk '{print $1; exit}'; }
refreshed_version() { [ -s "$REFRESHED" ] && head -1 "$REFRESHED" || echo "none"; }

# version_gt A B — true when A is newer than B
version_gt() {
  [ "$1" = "$2" ] && return 1
  [ "$(printf '%s\n%s\n' "$1" "$2" | sort -t. -k1,1n -k2,2n -k3,3n | tail -1)" = "$1" ]
}

# ---------- language ----------

available_langs() { for d in "$DECK_DIR"/*/; do [ -d "$d" ] && basename "$d"; done | tr '\n' ' ' | sed 's/ $//'; }
has_lang() { [ -n "${1:-}" ] && [ -d "$DECK_DIR/$1" ]; }

# normalize_lang <free-form name> — maps "ru", "Russian", "русский", "ru_RU" to a catalog code
normalize_lang() {
  local v; v="$(printf '%s' "${1:-}" | tr 'A-Z' 'a-z')"
  case "$v" in
    ru|ru[-_]*|rus|russian|Русск*|русск*) v=ru ;;
    en|en[-_]*|eng|english) v=en ;;
  esac
  has_lang "$v" && echo "$v"
}

# The `language` setting of Claude Code itself ("Have Claude respond in a language other than English").
claude_code_language() {
  local cfg f root
  cfg="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
  root="$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")"
  for f in "$root/.claude/settings.local.json" "$root/.claude/settings.json" "$cfg/settings.json"; do
    [ -f "$f" ] || continue
    sed -n 's/^[[:space:]]*"language"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$f" | head -1 | grep . && return 0
  done
  return 1
}

# resolve_lang — prints "<code> <source>". Order: env var, saved choice, Claude Code setting, default.
resolve_lang() {
  local l
  l="$(normalize_lang "${HINTDECK_LANG:-}")";                  [ -n "$l" ] && { echo "$l env"; return; }
  l="$(normalize_lang "$(cat "$ROOT/lang" 2>/dev/null)")";     [ -n "$l" ] && { echo "$l saved"; return; }
  l="$(normalize_lang "$(claude_code_language)")";             [ -n "$l" ] && { echo "$l claude-code-setting"; return; }
  echo "$DEFAULT_LANG default"
}
LANG_CODE="$(resolve_lang | cut -d' ' -f1)"
LANG_SOURCE="$(resolve_lang | cut -d' ' -f2)"

# Catalog languages other than the default that the system locale hints at (a hint, never a switch).
locale_hint() {
  local prefs code out=""
  prefs="${LC_ALL:-} ${LC_MESSAGES:-} ${LANG:-} $(defaults read -g AppleLanguages 2>/dev/null | tr -d '\n')"
  for code in $(available_langs); do
    [ "$code" = "$DEFAULT_LANG" ] && continue
    printf '%s' "$prefs" | grep -Eiq "(^|[^a-z])${code}[-_]" && out="$out $code"
  done
  echo "$out" | sed 's/^ //'
}

cmd_lang() {
  local want="${1:-}" code
  if [ -z "$want" ]; then
    echo "lang: $LANG_CODE (source: $LANG_SOURCE) | available: $(available_langs)"
    return 0
  fi
  if [ "$want" = "auto" ]; then rm -f "$ROOT/lang"; echo "saved choice removed; now: $(resolve_lang)"; return 0; fi
  code="$(normalize_lang "$want")"
  if [ -z "$code" ]; then echo "REFUSED: no catalog for '$want'. Available: $(available_langs)"; return 0; fi
  echo "$code" > "$ROOT/lang"; : > "$ROOT/lang-offered"
  echo "tip language saved: $code"
}

# ---------- signals: what the user already uses and where the session runs ----------

signals() {
  local cfg s out="" root
  cfg="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
  s="$cfg/settings.json"
  has() { [ -f "$s" ] && grep -Eq "$1" "$s"; }
  has '"tui"[[:space:]]*:[[:space:]]*"fullscreen"' && out="$out fullscreen"
  has '"hooks"[[:space:]]*:' && out="$out hooks"
  has '"statusLine"[[:space:]]*:' && out="$out statusline"
  has '"defaultMode"[[:space:]]*:[[:space:]]*"auto"' && out="$out auto-mode"
  has '"enabledPlugins"[[:space:]]*:' && out="$out plugins"
  has '"outputStyle"[[:space:]]*:' && out="$out output-style"
  has '"advisorModel"[[:space:]]*:' && out="$out advisor"
  has '"(preferredNotifChannel|Notification)"[[:space:]]*:' && out="$out notifications"
  has '"sandbox"[[:space:]]*:' && out="$out sandbox"
  has '"worktree"[[:space:]]*:' && out="$out worktree-config"
  [ -f "$cfg/keybindings.json" ] && out="$out keybindings"
  [ -f "$cfg/CLAUDE.md" ] && out="$out user-claude-md"
  ls "$cfg"/agents/*.md >/dev/null 2>&1 && out="$out agents"
  [ -d "$cfg/rules" ] && out="$out rules"
  [ -n "${TMUX:-}" ] && out="$out tmux"
  [ "$(uname)" = "Darwin" ] && out="$out macos"
  if root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    out="$out git"
    case "$(git rev-parse --git-dir 2>/dev/null)" in */worktrees/*) out="$out worktree";; esac
  else
    root="$PWD"
  fi
  { [ -f "$root/CLAUDE.md" ] || [ -f "$root/.claude/CLAUDE.md" ]; } && out="$out claude-md"
  [ -d "$root/.claude/rules" ] && out="$out rules"
  ls "$root"/.claude/agents/*.md >/dev/null 2>&1 && out="$out agents"
  [ -f "$root/.mcp.json" ] && out="$out mcp"
  [ -f "$root/.worktreeinclude" ] && out="$out worktree-include"
  echo "$out" | tr ' ' '\n' | sort -u | tr '\n' ' ' | sed 's/^ *//; s/ *$//'
}

# ---------- catalog ----------

# parse_lang <lang> — rows: id<TAB>topic<TAB>title<TAB>needs<TAB>skipif<TAB>since<TAB>n
parse_lang() {
  local f
  for f in "$DECK_DIR/$1"/*.md; do
    [ -f "$f" ] || continue
    awk -v topic="$(basename "$f" .md)" '
      function field(meta, key,   m, n, i, kv) {
        n = split(meta, m, ";")
        for (i = 1; i <= n; i++) {
          kv = m[i]; gsub(/^[ \t]+|[ \t]+$/, "", kv)
          if (index(kv, key ":") == 1) { kv = substr(kv, length(key) + 2); gsub(/[ \t]/, "", kv); return kv }
        }
        return ""
      }
      function flush() { if (id != "") print id "\t" topic "\t" title "\t" needs "\t" skipif "\t" since "\t" num }
      /^## / {
        flush()
        line = substr($0, 4); sep = index(line, " — ")
        if (sep == 0) { id = line; title = "" } else { id = substr(line, 1, sep - 1); title = substr(line, sep + length(" — ")) }
        needs = ""; skipif = ""; since = ""; num = ""; next
      }
      /^<!--/ && id != "" {
        meta = $0; sub(/^<!--[ \t]*/, "", meta); sub(/[ \t]*-->.*$/, "", meta)
        needs = field(meta, "needs"); skipif = field(meta, "skip-if"); since = field(meta, "since"); num = field(meta, "n")
      }
      END { flush() }
    ' "$f"
  done
}

# catalog — the default-language catalog is canonical (ids, numbers, metadata);
# titles come from the active language where a translation exists.
catalog() {
  if [ "$LANG_CODE" = "$DEFAULT_LANG" ]; then parse_lang "$DEFAULT_LANG"; return; fi
  local tr; tr="$(mktemp)"; parse_lang "$LANG_CODE" > "$tr"
  parse_lang "$DEFAULT_LANG" | awk -F'\t' -v OFS='\t' -v tr="$tr" '
    BEGIN { while ((getline l < tr) > 0) { split(l, a, "\t"); title[a[1]] = a[3] } }
    { if ($1 in title && title[$1] != "") $3 = title[$1]; print }'
  rm -f "$tr"
}

# candidates — unseen tips that pass the signal and version filters
candidates() {
  local sig
  sig=" $(signals) "
  catalog | awk -F'\t' -v sig="$sig" -v shown="$SHOWN" -v cli="$(cli_version)" '
    function newer(a, b,   x, y) { split(a, x, "."); split(b, y, ".")
      if (x[1] != y[1]) return x[1]+0 > y[1]+0; if (x[2] != y[2]) return x[2]+0 > y[2]+0; return x[3]+0 > y[3]+0 }
    BEGIN { while ((getline l < shown) > 0) { split(l, a, "\t"); seen[a[1]] = 1 } }
    {
      if ($1 in seen) next
      ok = 1
      if ($6 != "" && cli != "" && newer($6, cli)) ok = 0
      n = split($4, need, ","); for (i = 1; i <= n; i++) if (need[i] != "" && index(sig, " " need[i] " ") == 0) ok = 0
      n = split($5, skip, ","); for (i = 1; i <= n; i++) if (skip[i] != "" && index(sig, " " skip[i] " ") > 0) ok = 0
      if (ok) print "#" $7 " | " $1 " | " $2 " | " $3
    }'
}

cmd_list() {
  local total shown left cli ref ticket hint recent
  find "$TICKETS" -type f -mmin +1440 -delete 2>/dev/null
  total="$(catalog | wc -l | tr -d ' ')"
  shown="$(grep -c . "$SHOWN")"
  left="$(candidates | wc -l | tr -d ' ')"
  cli="$(cli_version)"; ref="$(refreshed_version)"
  ticket="t$(date +%s)$$${RANDOM}"
  : > "$TICKETS/$ticket"
  echo "cli: ${cli:-unknown} | catalog verified against: $ref | deck: $DECK | tips: $total | shown: $shown | available now: $left"
  echo "lang: $LANG_CODE (source: $LANG_SOURCE) | available: $(available_langs)"
  if [ "$LANG_SOURCE" = "default" ] && [ ! -f "$ROOT/lang-offered" ]; then
    hint="$(locale_hint)"
    echo "offer-lang: pending${hint:+ | system locale suggests: $hint}"
  fi
  echo "signals (already in use / environment): $(signals)"
  recent="$(tail -5 "$SHOWN" | cut -f1 | while read -r i; do printf '%s, ' "$(catalog | awk -F'\t' -v id="$i" '$1 == id { print "#" $7 " " $1 " (" $2 ")" }')"; done | sed 's/, $//')"
  echo "recently shown (vary the topic): $recent"
  if [ -n "$cli" ] && [ "$ref" != "none" ] && version_gt "$cli" "$ref"; then
    echo "refresh: the CLI is newer than the catalog ($ref -> $cli) — after the tip add the one-line refresh reminder"
  fi
  echo "ticket: $ticket"
  echo
  if [ "$left" = "0" ]; then
    echo "EXHAUSTED: no unseen tips left."
  else
    echo "unseen tips (# | id | topic | title):"
    candidates
  fi
}

# resolve <id|number> — catalog row by id or by number ("42", "#42" and "№42" all work)
resolve() {
  local key="${1#\#}"; key="${key#№}"
  catalog | awk -F'\t' -v k="$key" '$1 == k || $7 == k'
}

print_tip() { # $1 = catalog row
  local id topic num file text_lang
  id="$(printf '%s' "$1" | cut -f1)"; topic="$(printf '%s' "$1" | cut -f2)"; num="$(printf '%s' "$1" | cut -f7)"
  file="$DECK_DIR/$LANG_CODE/$topic.md"; text_lang="$LANG_CODE"
  if ! grep -q "^## $id\( \|$\)" "$file" 2>/dev/null; then
    file="$DECK_DIR/$DEFAULT_LANG/$topic.md"; text_lang="$DEFAULT_LANG (no $LANG_CODE translation yet — translate it faithfully when answering)"
  fi
  echo "number: $num | topic: $topic | reply-lang: $LANG_CODE | text-lang: $text_lang"
  awk -v id="$id" '
    /^## / { on = (index($0, "## " id " — ") == 1 || $0 == "## " id) }
    on { print }' "$file"
}

lock() {
  local n=0
  until mkdir "$ROOT/lock" 2>/dev/null; do n=$((n + 1)); [ "$n" -gt 50 ] && break; sleep 0.1; done
}
unlock() { rmdir "$ROOT/lock" 2>/dev/null; }

# issue <id|number> <ticket> <mode> — mode=new: unseen tips only; mode=any: any tip, by number
issue() {
  local key="${1:-}" ticket="${2:-}" mode="$3" row id when
  if [ -z "$key" ] || [ -z "$ticket" ]; then echo "REFUSED: usage — take|show <id|number> <ticket>"; return 0; fi
  if [ ! -f "$TICKETS/$ticket" ]; then
    echo "REFUSED: the ticket is not valid — a tip has already been issued for this invocation. One invocation = one tip; there is no second tip."
    return 0
  fi
  row="$(resolve "$key")"
  if [ -z "$row" ]; then echo "REFUSED: there is no tip '$key' in the catalog."; return 0; fi
  id="$(printf '%s' "$row" | cut -f1)"
  when="$(grep "^$id	" "$SHOWN" | cut -f2 | head -1)"
  if [ -n "$when" ] && [ "$mode" = "new" ]; then
    echo "REFUSED: tip '$id' was already shown ($when). Pick another one from the unseen list."
    return 0
  fi
  rm -f "$TICKETS/$ticket"
  if [ -z "$when" ]; then printf '%s\t%s\n' "$id" "$(date +%Y-%m-%d)" >> "$SHOWN"; else echo "repeat: first shown on $when"; fi
  print_tip "$row"
}

cmd_take() { lock; issue "${1:-}" "${2:-}" new; unlock; }
cmd_show() { lock; issue "${1:-}" "${2:-}" any; unlock; }

# history — shown tips with their numbers, in the order they were shown
cmd_history() {
  [ -s "$SHOWN" ] || { echo "nothing shown yet"; return 0; }
  echo "# | date | topic | title"
  local cat; cat="$(catalog)"
  while IFS="$(printf '\t')" read -r id when; do
    printf '%s\n' "$cat" | awk -F'\t' -v id="$id" -v w="$when" '$1 == id { print "#" $7 " | " w " | " $2 " | " $3; f = 1 } END { if (!f) print "— | " w " | (removed from the catalog) | " id }'
  done < "$SHOWN"
}

cmd_status() {
  echo "cli: $(cli_version) | catalog verified against: $(refreshed_version) | deck: $DECK"
  echo "lang: $LANG_CODE (source: $LANG_SOURCE) | available: $(available_langs)"
  echo "tips: $(catalog | wc -l | tr -d ' ') | shown: $(grep -c . "$SHOWN") | available now: $(candidates | wc -l | tr -d ' ')"
  echo "by topic (total):"; catalog | cut -f2 | sort | uniq -c
}

# changelog — entries newer than the last verified version (Added/Changed/Removed/Deprecated/Renamed)
cmd_changelog() {
  local ref tmp; ref="$(refreshed_version)"; tmp="$(mktemp)"
  if ! curl -fsSL -m 60 "$CHANGELOG_URL" -o "$tmp"; then echo "ERROR: could not download $CHANGELOG_URL"; rm -f "$tmp"; return 0; fi
  awk -v ref="$ref" '
    function newer(a, b,   x, y) { split(a, x, "."); split(b, y, ".")
      if (x[1] != y[1]) return x[1]+0 > y[1]+0; if (x[2] != y[2]) return x[2]+0 > y[2]+0; return x[3]+0 > y[3]+0 }
    /<Update label=/ { match($0, /label="[^"]+"/); v = substr($0, RSTART + 7, RLENGTH - 8); on = (ref == "none" || newer(v, ref)) }
    on && /^[ \t]*\* (Added|Changed|Removed|Deprecated|Renamed)/ { sub(/^[ \t]*\* /, ""); print v " | " $0 }
  ' "$tmp"
  rm -f "$tmp"
}

cmd_refreshed() { local v; v="$(cli_version)"; [ -n "$v" ] && echo "$v" > "$REFRESHED" && echo "catalog marked as verified against $v"; }

# number — give permanent numbers to default-language tips that have none, then copy every
# number to the translations by id. Numbers of removed tips are never reused.
cmd_number() {
  local last max f tmp lang map
  last="$(cat "$DECK_DIR/.last-number" 2>/dev/null || echo 0)"
  max="$(parse_lang "$DEFAULT_LANG" | cut -f7 | sort -n | tail -1)"; [ "${max:-0}" -gt "$last" ] && last="$max"
  for f in "$DECK_DIR/$DEFAULT_LANG"/*.md; do
    tmp="$(mktemp)"
    awk -v last="$last" -v out="$DECK_DIR/.last-number.tmp" '
      /^## / { hdr = 1; print; next }
      hdr && /^<!--/ { hdr = 0; if ($0 !~ /<!--[ \t]*n:[ \t]*[0-9]+/) { last++; sub(/^<!--[ \t]*/, "<!-- n: " last "; "); print "assigned #" last > "/dev/stderr" } print; next }
      { hdr = 0; print }
      END { print last > out }' "$f" > "$tmp" && cat "$tmp" > "$f"
    rm -f "$tmp"; last="$(cat "$DECK_DIR/.last-number.tmp")"; rm -f "$DECK_DIR/.last-number.tmp"
  done
  echo "$last" > "$DECK_DIR/.last-number"
  map="$(mktemp)"; parse_lang "$DEFAULT_LANG" | cut -f1,7 > "$map"
  for lang in $(available_langs); do
    [ "$lang" = "$DEFAULT_LANG" ] && continue
    for f in "$DECK_DIR/$lang"/*.md; do
      [ -f "$f" ] || continue
      tmp="$(mktemp)"
      awk -v map="$map" '
        BEGIN { while ((getline l < map) > 0) { split(l, a, "\t"); num[a[1]] = a[2] } }
        /^## / { hdr = 1; id = $2; print; next }
        hdr && /^<!--/ { hdr = 0; if ($0 !~ /<!--[ \t]*n:[ \t]*[0-9]+/ && (id in num)) sub(/^<!--[ \t]*/, "<!-- n: " num[id] "; "); print; next }
        { hdr = 0; print }' "$f" > "$tmp" && cat "$tmp" > "$f"
      rm -f "$tmp"
    done
  done
  rm -f "$map"; echo "last number issued: $last"
}

# lint [--strict] — catalog check. Exits non-zero on errors; with --strict also on warnings
# (a tip without a translation). CI and the pre-commit hook run it with --strict.
cmd_lint() {
  local bad=0 warn=0 strict=0 dups f lang base out last max
  [ "${1:-}" = "--strict" ] && strict=1
  base="$(mktemp)"; parse_lang "$DEFAULT_LANG" > "$base"
  dups="$(cut -f1 "$base" | sort | uniq -d)"; [ -n "$dups" ] && { echo "duplicate ids: $dups"; bad=1; }
  dups="$(cut -f7 "$base" | sort | uniq -d)"; [ -n "$dups" ] && { echo "duplicate numbers: $dups"; bad=1; }
  awk -F'\t' '$1 !~ /^[a-z0-9-]+$/ { print "bad id: " $1; e = 1 } $3 == "" { print "no title: " $1; e = 1 }
              $7 !~ /^[0-9]+$/ { print "no number (run tip.sh number): " $1; e = 1 } END { exit e }' "$base" || bad=1
  last="$(cat "$DECK_DIR/.last-number" 2>/dev/null || echo 0)"
  max="$(cut -f7 "$base" | sort -n | tail -1)"
  if [ "${max:-0}" -gt "$last" ]; then echo ".last-number ($last) is behind the highest number in use ($max): run tip.sh number"; bad=1; fi
  for lang in $(available_langs); do
    for f in "$DECK_DIR/$lang"/*.md; do
      awk -v f="$lang/$(basename "$f")" '
        function check() { if (id != "" && (!meta || !try)) { print f ": " id ": missing " (meta ? "" : "metadata (verified:) ") (try ? "" : "the try-it line (**Label:** …)"); e = 1 } }
        /^## / { check(); id = $2; meta = 0; try = 0; next }
        /^<!--.*verified:/ { meta = 1 }
        /^\*\*[^*]+:\*\*/ { try = 1 }
        END { check(); exit e }' "$f" || bad=1
    done
    [ "$lang" = "$DEFAULT_LANG" ] && continue
    # translations must mirror the canonical metadata; a missing translation is a warning
    out="$(parse_lang "$lang" | awk -F'\t' -v base="$base" -v lang="$lang" -v dl="$DEFAULT_LANG" '
      BEGIN { while ((getline l < base) > 0) { split(l, a, "\t"); topic[a[1]] = a[2]; meta[a[1]] = a[4] "|" a[5] "|" a[6] "|" a[7] } }
      { seen[$1] = 1
        if (!($1 in meta)) { print "error: " lang ": " $1 ": not in the " dl " catalog"; next }
        if (topic[$1] != $2) print "error: " lang ": " $1 ": topic file differs (" $2 " vs " topic[$1] ")"
        if (meta[$1] != $4 "|" $5 "|" $6 "|" $7) print "error: " lang ": " $1 ": needs/skip-if/since/n differ from the canonical tip" }
      END { for (id in meta) if (!(id in seen)) print "warning: " lang ": no translation of " id }')"
    [ -n "$out" ] && printf '%s\n' "$out"
    printf '%s\n' "$out" | grep -q '^error:' && bad=1
    printf '%s\n' "$out" | grep -q '^warning:' && warn=1
  done
  [ "$warn" = "1" ] && [ "$strict" = "1" ] && { echo "strict mode: untranslated tips are not allowed"; bad=1; }
  [ "$bad" = "0" ] && echo "OK: $(wc -l < "$base" | tr -d ' ') tips in deck '$DECK'; languages: $(available_langs); ids and numbers unique, metadata consistent"
  rm -f "$base"
  return "$bad"
}

cmd_reset() { : > "$SHOWN"; echo "shown history cleared for deck '$DECK'"; }

case "${1:-list}" in
  list) cmd_list ;;
  take) shift; cmd_take "$@" ;;
  show) shift; cmd_show "$@" ;;
  history) cmd_history ;;
  status) cmd_status ;;
  lang) shift; cmd_lang "$@" ;;
  lang-offered) : > "$ROOT/lang-offered"; echo "noted: the language offer will not be repeated" ;;
  changelog) cmd_changelog ;;
  refreshed) cmd_refreshed ;;
  number) cmd_number ;;
  slides-dir) mkdir -p "$ROOT/slides" && echo "$ROOT/slides" ;;
  lint) shift; cmd_lint "$@"; exit $? ;;
  reset) cmd_reset ;;
  *) echo "usage: tip.sh [list | take <id|number> <ticket> | show <number> <ticket> | history | status | lang [code|auto] | lang-offered | changelog | refreshed | number | slides-dir | lint [--strict] | reset]" ;;
esac
exit 0
