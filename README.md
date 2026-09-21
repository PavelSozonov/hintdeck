# hintdeck

**Tip of the day for [Claude Code](https://code.claude.com/docs)** — a deck of doc-verified tips you draw from one at a time. Never the same tip twice, picked for what you are doing right now.

Claude Code ships features faster than anyone reads changelogs. hintdeck turns the documentation into a habit: type `/tip`, learn one thing, try it in a minute.

<p align="center">
  <img src="docs/demo/tip.gif" width="900"
       alt="A Claude Code session: the user types /tip keys and gets tip of the day #2 — Ctrl+G opens the prompt in your own editor — with a one-line action to try and a footer showing the topic, the tip number and how many tips have been shown">
</p>

<p align="center"><em>The recording asks for a topic with <code>/tip keys</code>. A bare <code>/tip</code> picks for your session instead — see <a href="#how-a-tip-is-picked">How a tip is picked</a>.</em></p>

## What is inside

| Skill | What it does |
|---|---|
| `tip` | One tip per call: keyboard shortcuts, slash commands, CLI flags, context and memory, settings and hooks, skills/subagents/MCP, parallel work, ways of working, recent additions. |
| `tip-slides` | The same tip as a deck of 1–5 slides. A visual is added only when it answers a concrete question — which keys to press, in what order things happen, how the options differ. No decoration. |

<p align="center">
  <img src="docs/demo/slides-1.png" width="49%" alt="Slide 1 of the deck for tip #11: the title 'Enter while Claude works queues your message, it does not interrupt' with the Enter and Up keys drawn as keycaps">
  <img src="docs/demo/slides-2.png" width="49%" alt="Slide 2: a flow diagram of the current turn showing that a queued regular message reaches the model when the current tool calls finish, while slash and ! commands wait for the turn to end">
</p>

`/tip-slides 11` — a two-slide deck: the keys to press, then a flow showing *when* a queued message reaches the model, the one thing the text alone does not show. A tip that is a single fact gets a single slide and no diagram.

- **140+ tips and growing**, each verified against the official documentation and stamped with the CLI version it was checked on. `/tip refresh` adds tips for new releases and retires stale ones.
- **No repeats, one at a time** — enforced by a script, not by the model's memory.
- **Context-aware** — skips what you already use, hides what cannot apply to you, and matches the rest to what your session is doing: [How a tip is picked](#how-a-tip-is-picked).
- **Permanent numbers** — every tip has a number you can refer to and ask for again: `/tip 42`.
- **Multilingual** — English by default, Russian available: `/tip lang ru`.

## How a tip is picked

`/tip` does not draw at random. Three things narrow the deck, in this order:

1. **What you have seen.** A shown tip never comes back on its own; the history lives in `~/.claude/hintdeck/`.
2. **What you already use, and what cannot apply.** Before the model sees anything, a script reads a few facts about your setup and drops the tips they make pointless. You have a status line, so no tip about setting one up. You are not in a git repository, so no worktree tips. Your CLI is older than a feature, so that tip waits. This step is deterministic.
3. **What fits the moment.** The model reads the remaining titles against the conversation so far — the task, what went wrong recently, the tools in use — and takes the closest match. The reply then says why the tip matters *here*, and fills "Try it now" with details from your own work where it can.

A real exchange, two hours into a debugging session:

> *We have been debugging a flaky integration test for two hours in this session and the context is getting full of failed attempts and long logs. Before we continue: give me a tip of the day.*
>
> **Tip of the day #80: Two failed corrections in a row mean it is time to start over**
>
> If you've corrected Claude twice on the same issue and the result is still wrong, the context is already full of failed attempts. A clean session with a better prompt almost always beats a long one with piled-up corrections. That fits your flaky-test session: after two hours of dead ends and long logs, a fresh start would carry only what you've learned.
>
> **Try it now:** Write a short summary of what you know about the flaky test. Include what you've ruled out, the conditions that trigger the failure, and the current hypothesis. Then run `/clear` and start the next session with that summary as a new, more specific prompt.
>
> *context · #80 · shown 1 of 147*

Step 3 is the model's judgement, not a guarantee. In a fresh session there is nothing to go on yet, so `/tip` simply varies the topic; name one yourself (`/tip hooks`) to steer it. A one-off run from the shell, such as `claude -p "/tip" --model sonnet`, has no conversation either: it is cheaper and keeps the tip out of your working session's context, at the price of step 3.

## Install

As a plugin:

```
/plugin marketplace add PavelSozonov/hintdeck
/plugin install hintdeck@hintdeck
```

The skills are then `/hintdeck:tip` and `/hintdeck:tip-slides` — typing `/tip` and pressing `Tab` is enough.

As personal skills with the short names `/tip` and `/tip-slides`:

```bash
git clone https://github.com/PavelSozonov/hintdeck ~/.claude/hintdeck-src
ln -s ~/.claude/hintdeck-src/plugins/hintdeck/skills/tip        ~/.claude/skills/tip
ln -s ~/.claude/hintdeck-src/plugins/hintdeck/skills/tip-slides ~/.claude/skills/tip-slides
```

Requirements: `bash`, `awk`, `curl` (for `refresh` only). Tested on macOS with the system bash 3.2.

## Usage

| Call | Result |
|---|---|
| `/tip` | a new tip picked for the current session |
| `/tip hooks`, `/tip keys` | a new tip on a topic |
| `/tip 42` | tip #42 — including one you have already seen |
| `/tip history` | the tips shown so far, with numbers and dates |
| `/tip lang ru` | switch the tip language (`/tip lang` shows it, `/tip lang auto` forgets the choice) |
| `/tip refresh` | pull in new features from the changelog and re-check stale tips |
| `/tip-slides`, `/tip-slides <topic>`, `/tip-slides 42` | the same, as slides |

Topics: `keys` `commands` `cli` `context` `config` `extend` `parallel` `practices` `new`.

### Language

Tips come in English unless you choose otherwise. The language is resolved in this order: the `HINTDECK_LANG` environment variable, your saved choice (`/tip lang <code>`), Claude Code's own [`language` setting](https://code.claude.com/docs/en/settings-reference#language), then English. Your system locale never switches the language — at most the skill mentions once that another language is available. Switching keeps your history: ids and numbers are shared across languages.

## How it works

- **The script is the source of truth.** On every call the skill receives a single-use ticket and the list of unseen tips from `tip.sh`. `take` prints one tip, marks it as shown and burns the ticket — a second tip or a repeat is refused.
- **Filtering.** `skip-if` hides tips about features you already use, `needs` hides tips that don't apply to your environment, `since` hides features newer than your installed CLI. The model picks from what is left by looking at your session.
- **State** lives outside the repository in `~/.claude/hintdeck/` (shown history, language, local slide decks), so plugin updates never lose it. `tip` and `tip-slides` share it.
- **Verified facts only.** A tip enters the catalog when the docs (`https://code.claude.com/docs/en/*.md`), the changelog or `claude --help` confirm it. When answering, the model adds nothing "from memory".

Details: [`DESIGN.md`](plugins/hintdeck/skills/tip/DESIGN.md). Catalog maintenance: [`REFRESH.md`](plugins/hintdeck/skills/tip/REFRESH.md).

## Troubleshooting

| Symptom | Fix |
|---|---|
| `/tip` is not found right after installing | Run `/reload-plugins` (or `/reload-skills` for the symlink install), or restart Claude Code. |
| Tips arrive in the wrong language | `/tip lang` shows the current language and where it came from; `/tip lang en` or `/tip lang ru` sets it, `/tip lang auto` forgets the choice. |
| "No unseen tips left" | Run `/tip refresh` to pull in tips for newer releases, or ask for a tip again by number (`/tip 42`). To start the whole deck over, ask Claude to reset the tip history. |
| The skill reports that shell execution is disabled | Your settings have `disableSkillShellExecution`; the skill then runs `tip.sh list` itself as an ordinary tool call, and everything else works the same. |
| A tip looks outdated | Tips are stamped with the CLI version they were verified against. Update the plugin, or open an issue with the tip number. |
| `/tip-slides` produced an HTML file instead of a hosted deck | The session had no Artifact tool (for example `claude -p`); the deck is in `~/.claude/hintdeck/slides/`. |

## Privacy

hintdeck collects nothing and talks to no remote service. It keeps its state locally in `~/.claude/hintdeck/`, reads a few of your Claude Code settings only to skip tips about features you already use, and goes online only when you run `/tip refresh`, which downloads the public Claude Code changelog and documentation. Details: [`SECURITY.md`](SECURITY.md).

## Support

Questions, bugs and tip corrections: [GitHub Issues](https://github.com/PavelSozonov/hintdeck/issues). Security reports: see [`SECURITY.md`](SECURITY.md).

## Contributing

New tips, corrections and translations are welcome — see [`CONTRIBUTING.md`](CONTRIBUTING.md). `main` is the release branch that the plugin directory mirrors, so changes land through pull requests, and a change to the plugin ships only with a version bump. Release notes: [`CHANGELOG.md`](CHANGELOG.md).

## License

[MIT](LICENSE)

hintdeck is an independent community project. It is not affiliated with, sponsored by or endorsed by Anthropic. "Claude" and "Claude Code" are trademarks of Anthropic.
