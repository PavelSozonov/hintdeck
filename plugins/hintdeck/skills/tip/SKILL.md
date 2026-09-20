---
name: tip
description: Use when the user asks for a tip of the day or for advice on working with Claude Code and its CLI more effectively — "/tip", "tip of the day", "give me a Claude Code tip", "what don't I know about Claude Code", "совет дня", "/tip <topic>" (hotkeys, hooks, worktrees, context…), "/tip 42" or "tip #42" (show a tip by number), "/tip history", "/tip lang ru", "/tip refresh"
argument-hint: "[topic | tip number | history | lang <code> | refresh]"
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/tip.sh *)
---

# tip — tip of the day for Claude Code

## Overview

One invocation, one tip from a catalog verified against the official documentation. `tip.sh` —
not the model's memory — guarantees that tips never repeat and that an invocation yields exactly
one: a tip cannot be obtained without marking it as shown. The facts of a tip come only from the
catalog. Do not add keys, commands or flags from your own knowledge: that is exactly how invented
and outdated details end up in tips.

## State at invocation

```!
${CLAUDE_SKILL_DIR}/tip.sh list
```

Invocation argument: "$ARGUMENTS"

If the state block above is missing (shell execution in skills is disabled), run
`${CLAUDE_SKILL_DIR}/tip.sh list` yourself and work from its output.

## Steps

1. **Mode.**
   - the argument is a number (`42`, `#42`, `№42`) → `${CLAUDE_SKILL_DIR}/tip.sh show <number> <ticket>`,
     then reply in the format below; this is the only way to show a tip again;
   - `history` → print the result of `${CLAUDE_SKILL_DIR}/tip.sh history` as a table, no tip;
   - `lang <code>` (or a request such as "tips in Russian") → `${CLAUDE_SKILL_DIR}/tip.sh lang <code>`,
     confirm in one line, no tip; `lang` alone shows the current language, `lang auto` forgets the choice;
   - `refresh`, or an `EXHAUSTED` line in the state → follow `REFRESH.md` in the skill directory;
   - otherwise the normal flow, steps 2–4.
2. **Choose** one id from the unseen list:
   - a topic argument → the closest tip in that topic (the topic is the third column; the user's
     word may be in any language: "клавиши" → `keys`, "hooks" → `config`/`extend`);
   - no argument → the tip most useful right now: go by what this session is doing (the task,
     recent friction, the tools in use) and by the signals line;
   - an empty session → any tip from a topic that is not in the "recently shown" line.
3. **Take it.** `${CLAUDE_SKILL_DIR}/tip.sh take <id> <ticket>` prints the tip's number and text and
   marks it as shown. On `REFUSED`, do what the message says. The command runs once per invocation.
4. **Reply** in the format below.

If there are no unseen tips for the user's topic, say so in one sentence, name the topics that
still have some and suggest `/tip refresh`. Do not make up a tip instead.

## Language

Reply in the language of the `lang:` line (the `reply-lang` that `take` prints) — not in the
language of this file and not by guessing. The catalog text arrives in that language; when `take`
reports `text-lang: en (no … translation yet)`, translate the tip faithfully as you reply.

| | `en` | `ru` |
|---|---|---|
| Title | `**Tip of the day #<n>: <title>**` | `**Совет дня №<n>: <заголовок>**` |
| Action | `**Try it now:**` | `**Попробуй сейчас:**` |
| Footer | `*<topic> · #<n> · shown N of M*` | `*<тема> · №<n> · показано N из M*` |
| Refresh reminder | `The CLI was updated (X → Y): /tip refresh adds what is new` | `CLI обновился (X → Y): /tip refresh добавит новинки` |
| Address | — | informal «ты» |

For any other catalog language translate these labels the same way.

**Offering a language — once.** When the state has an `offer-lang: pending` line and either it
names a language the system locale suggests, or the user is writing to you in an available language
other than the current one, end your reply with one line in that language, e.g. «Советы доступны
и по-русски: `/tip lang ru`», then run `${CLAUDE_SKILL_DIR}/tip.sh lang-offered` so it is never
repeated. Otherwise leave it pending. The locale never switches the language by itself.

## Reply format

Four parts, in this order, labels from the table above:

1. The title with the tip's number — the number is permanent, and the tip can be requested by it.
2. Two to four sentences: what it is and why it matters. Retell the tip's text; when it connects
   to what is happening in the session, say why it is useful here. Claim only what you verified
   about the user's settings and files: read `settings.json`, a hook or CLAUDE.md before you
   refer to it, and before suggesting that they set something up, check that it is not already
   there.
3. The action line: one concrete action from the tip's "try it" line; substitute real file,
   branch and command names from the current project when you know them.
4. The footer, in italics: N is "shown" from the state plus one (no plus one for a repeat), M is
   "tips". When the state has a `refresh:` line, add the refresh reminder on the next line.

## tip.sh reference

| Command | What it does |
|---|---|
| `list` | state, language, signals, a ticket and the unseen tips with their numbers |
| `take <id\|number> <ticket>` | a new tip: number, text, marked as shown; the ticket is single-use |
| `show <number> <ticket>` | a tip by number, including one already shown |
| `history` | shown tips: number, date, topic, title |
| `lang [code\|auto]` | show, save or forget the tip language |
| `lang-offered` | record that the one-time language offer was made |
| `status` | versions, language and counts by topic |
| `changelog` | changelog entries newer than the last verified version |
| `refreshed` | record that the catalog is verified against the installed CLI |
| `number` | give permanent numbers to new tips and copy them to the translations |
| `lint` | catalog check: unique ids and numbers, metadata, translations in sync |
| `reset` | clear the shown history — only when the user asks for it directly |

## Common mistakes

| Mistake | Instead |
|---|---|
| A "bonus" or a second tip in the same reply | One invocation, one tip; the next one comes with the next `/tip` |
| Adding a key or a flag "from memory" | Only what `take` printed; if you doubt a tip, suggest `/tip refresh` |
| Reading `decks/**/*.md` directly, bypassing `take` | The tip would not be marked as shown and would repeat |
| Silently starting over on `EXHAUSTED` | `REFRESH.md` first; `reset` only if the user asked |
| Replying in the conversation's language when `lang:` says otherwise | The `lang:` line decides; offer the switch once instead |
