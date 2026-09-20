# hintdeck — design

Created 2026-09-20 against Claude Code CLI 2.1.278.

## Purpose

Raise awareness of what Claude Code and its CLI can do: keyboard shortcuts, commands, flags,
context and memory, settings and hooks, skills/subagents/MCP, parallel work, ways of working,
recent additions. One tip per invocation, never repeated, in the user's language.

## Requirements and what enforces them

| Requirement | Mechanism |
|---|---|
| Never repeat a tip | `shown.tsv` in the state directory; `tip.sh take` refuses an id that was shown; a lock guards against two parallel sessions taking the same tip |
| One tip per invocation | A single-use `ticket`: `list` issues it when the skill is invoked, `take`/`show` burn it |
| On demand only | No hooks, nothing shown automatically; the skill runs on `/tip` or a phrase like "tip of the day" |
| Catalog plus updates | `decks/<deck>/<lang>/*.md` verified against the official docs; `REFRESH.md` and `tip.sh changelog` pull in what is new |
| Context-aware choice | `tip.sh` filters out what the user already uses (`skip-if`) and what does not apply (`needs`, `since`); the model picks from the rest by what the session is doing |
| Permanent numbering | The `n` field in a tip's metadata; `decks/<deck>/.last-number`; numbers are never reused; `/tip <number>`, `/tip history` |
| Multilingual, English by default | One directory per language; ids, numbers and metadata shared; language resolved by `tip.sh` |
| Slides (`tip-slides`) | A separate skill on the same `tip.sh`; rules for the number of slides and a "question → visual form" table |

A baseline without the skill (three clean sessions) showed: two of three answers were the same tip
(double Esc), all three added a "bonus" second tip, and answers hedged with "depends on your
version". Hence the decisions: repetition and count are handled by the script, the shape of the
reply by a positive four-part recipe, the facts by the catalog only.

## Language

The default-language catalog (`en`) is canonical: it owns ids, numbers and metadata. Other
languages translate title, body and the action line under the same id; `lint` keeps `n`, `needs`,
`skip-if` and `since` identical. A tip with no translation falls back to English text, and the
model translates it while replying.

The tip language is resolved in this order:

1. the `HINTDECK_LANG` environment variable;
2. the saved choice — `/tip lang ru` writes `<state>/lang`, `/tip lang auto` removes it;
3. Claude Code's own `language` setting (user or project settings) — someone who told Claude to
   answer in Russian has already chosen;
4. `en`.

The system locale never switches the language — it is not the user's choice of tip language. It
only makes the skill offer the switch once (`offer-lang: pending` → one line in the reply →
`tip.sh lang-offered`). The shown history is keyed by id, so switching languages keeps it.

## Layout

```
plugins/hintdeck/skills/tip/
  SKILL.md        delivery steps, language rules, reply format
  REFRESH.md      updating the catalog from the changelog and the docs
  DESIGN.md       this file
  tip.sh          list | take | show | history | status | lang | changelog | refreshed | number | lint | reset
  decks/<deck>/<lang>/<topic>.md   the catalog; topics: keys commands cli context config extend parallel practices new
  decks/<deck>/.last-number
plugins/hintdeck/skills/tip-slides/
  SKILL.md        the same tip → a slide deck (Artifact Slides; HTML fallback)
  tip.sh          a wrapper around ../tip/tip.sh
  deck-template.html   the template of the HTML fallback
<state> = ~/.claude/hintdeck/    (HINTDECK_STATE_DIR overrides it)
  lang, lang-offered, tickets/, slides/
  <deck>/shown.tsv, <deck>/refreshed-version
```

The state of an invocation is injected into SKILL.md dynamically (the `!` block), so the catalog
never enters the context as a whole: the model sees only the titles of unseen tips, and the text
of the one it picked. `allowed-tools: Bash(${CLAUDE_SKILL_DIR}/tip.sh *)` lets the script run
without permission prompts. State lives outside the skill directory, so it survives plugin updates
and stays out of git.

Decks are a directory level of their own (`HINTDECK_DECK`, default `claude-code`) so that catalogs
for other tools can be added later without renumbering: a tip is addressed as `<deck>#<number>`.

## Catalog rule

A tip enters the catalog only when a primary source confirms it:
`https://code.claude.com/docs/en/*.md`, the changelog, `claude --help`. Every tip carries
`verified: <CLI version>`. What cannot be verified stays out — not even marked "possibly".

## Deliberately not done

- Showing a tip at session start (a SessionStart hook) — the skill is on demand only.
- Starting the cycle over when the catalog is exhausted — only an explicit `tip.sh reset` at the
  user's request.
- One cumulative deck in `tip-slides` — each deck is separate, one tip each.
- A UI for switching decks — the directory level exists, the switch is an environment variable.
