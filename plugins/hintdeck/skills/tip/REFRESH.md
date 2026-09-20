# tip refresh — updating the catalog

Goal: add tips for new features and remove what went stale. The sources of truth are the official
documentation (`https://code.claude.com/docs/en/<page>.md`, index at
`https://code.claude.com/docs/llms.txt`), the changelog and `claude --help`. Anything you cannot
confirm in a primary source stays out of the catalog — not even with a "possibly" note.

When the skill runs from an installed plugin, its directory is a cache that the next plugin update
overwrites. Refresh the catalog in a clone of the repository instead, commit, and let users get it
through a plugin update.

## Steps

1. `${CLAUDE_SKILL_DIR}/tip.sh status` — the installed CLI version and the last verified version.
2. `${CLAUDE_SKILL_DIR}/tip.sh changelog` — Added/Changed/Removed/Deprecated/Renamed entries newer
   than the last verification. Empty → nothing new, go to step 6.
3. Keep the entries that change the everyday work of one developer in a terminal. Skip gateways,
   managed settings, telemetry, cloud providers and bug fixes.
4. For each kept entry open the matching documentation page (`curl -fsSL`; the proxy comes from the
   environment) and verify the details: exact keys, command names, flags, settings, limits. Then
   write the tip in the default language, `decks/<deck>/en/new.md`, and add a faithful translation
   with the same id and metadata to every other language directory (`decks/<deck>/ru/new.md`, …).
5. Removed/Deprecated/Changed entries: find the affected tips
   (`grep -rn '<command or flag>' ${CLAUDE_SKILL_DIR}/decks/`) and fix or delete them in every
   language. Update `verified` on a tip you fixed.
6. `${CLAUDE_SKILL_DIR}/tip.sh number` (gives new tips permanent numbers and copies them to the
   translations), then `${CLAUDE_SKILL_DIR}/tip.sh lint` and `${CLAUDE_SKILL_DIR}/tip.sh refreshed`.
7. Report to the user: how many tips were added, fixed and removed (with numbers and ids). If the
   invocation was `/tip refresh`, stop here. If `EXHAUSTED` brought you here, run `tip.sh list`
   and deliver one fresh tip the normal way; when there is none, say the catalog is exhausted and
   that `tip.sh reset` starts the cycle over — only at the user's request.

## Tip format

```markdown
## <topic>-<slug> — <Title: what the feature does, in one line>
<!-- n: <number>; needs: <signals>; skip-if: <signals>; since: <version>; verified: <CLI version checked against> -->
Two to four sentences: what it is, why it matters, the important limitation. Exact keys and
commands in backticks. Second person.

**Try it:** one concrete action that takes a minute.
```

- `id` — lowercase letters, digits and hyphens; unique across the deck; prefixed by the topic file.
  A translation uses the same id in the file of the same name.
- `n` — the permanent number. Never write or change it by hand: `tip.sh number` issues the next one
  after `decks/<deck>/.last-number`. Numbers of removed tips are never reused — people refer to them.
- `needs` — the tip shows only when every listed signal is present; `skip-if` — it is hidden when
  any listed signal is present (the user already uses the feature). Both are optional. `tip.sh`
  computes the signals (function `signals`): `fullscreen hooks statusline auto-mode plugins
  output-style advisor notifications sandbox worktree-config keybindings user-claude-md agents rules
  tmux macos git worktree claude-md mcp worktree-include`.
- `since` — the version the feature arrived in; the tip stays hidden while the installed CLI is older.
- `n`, `needs`, `skip-if` and `since` must be identical in every language; `lint` checks it. The
  action line label is translated (`**Try it:**`, `**Попробуй:**`).
- Topics (files): `keys commands cli context config extend parallel practices new`.
