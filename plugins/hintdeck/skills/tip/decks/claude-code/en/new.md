# new — recent additions from the changelog

## new-send-now — Ctrl+Enter sends the message queue immediately
<!-- n: 138; since: 2.1.275; verified: 2.1.278 -->
Queued messages used to wait for their moment. Now `Ctrl+Enter` (or `Ctrl+X Ctrl+S`) interrupts the current turn and sends the whole queue at once. Sent and queued messages show in grey until the model receives them.

**Try it:** during a long turn type a clarification, press `Enter`, then `Ctrl+Enter`.

## new-agents-md — Claude Code reads AGENTS.md when the project has no CLAUDE.md
<!-- n: 139; since: 2.1.277; verified: 2.1.278 -->
In a project without a CLAUDE.md, `AGENTS.md` — the shared instruction file for different coding agents — is now picked up instead. The behaviour is controlled under "Project instructions" in `/config`. If you kept a CLAUDE.md wrapper only to import AGENTS.md, you no longer need it.

**Try it:** in a repository with an AGENTS.md, check with `/context` that the file loaded.

## new-skills-sync — Skills and plugins from your claude.ai account arrive in the terminal
<!-- n: 140; since: 2.1.275; verified: 2.1.278 -->
Skills and plugins enabled on your claude.ai account now sync into terminal sessions signed in with the same account. Shell commands embedded in such skills are not run on your machine. Opt out with `"syncClaudeAiSkills": false` or `"syncClaudeAiPlugins": false` in your settings.

**Try it:** `/skills` — see which skills came from your account and decide whether you want them in the terminal.

## new-plugin-eval — claude plugin eval runs a plugin's eval suite
<!-- n: 141; since: 2.1.269; verified: 2.1.278 -->
`claude plugin eval` runs a plugin's eval suite against Claude Code and returns scored, reproducible results — JSON plus an HTML report. Start with `claude plugin eval init`; help is `claude plugin eval --help`. It lets you measure whether a skill got better after an edit instead of judging by eye.

**Try it:** `claude plugin eval --help`.

## new-max-effort-level — maxEffortLevel caps the effort level
<!-- n: 142; since: 2.1.267; verified: 2.1.278 -->
The `maxEffortLevel` setting — top-level or per model under `modelSettings` — caps the reasoning level on every provider; a lower level can still be chosen. Insurance against an expensive level left on by accident.

**Try it:** decide whether your most expensive model needs a cap and add `maxEffortLevel` to its `modelSettings`.

## new-time-format — The time format in the transcript is configurable
<!-- n: 143; since: 2.1.257; verified: 2.1.278 -->
New "Time format" (`timeFormat`) and `timeZone` settings: 12-hour, 24-hour, 24-hour UTC or your own strftime pattern — for the turn-end clock and the timestamps in the transcript view (`Ctrl+O`).

**Try it:** `/config` → Time format → 24-hour.

## new-config-mouse — The mouse now works in /config
<!-- n: 144; needs: fullscreen; since: 2.1.271; verified: 2.1.278 -->
In fullscreen mode the `/config` panel understands the mouse: the wheel scrolls the list, a click on a value changes the setting, and the row under the pointer is highlighted.

**Try it:** open `/config` and change any setting with a click.

## new-mcp-disconnect-notice — A notification when an MCP server drops for good
<!-- n: 145; since: 2.1.273; verified: 2.1.278 -->
When an MCP server disconnects mid-session and automatic reconnection gives up, Claude Code now shows a notification pointing at `/mcp`. Before, the only sign was tools that suddenly went missing.

**Try it:** when you see that notification — `/mcp reconnect <server>`.

## new-plugin-install-marketplace — /plugin install can add the marketplace for you
<!-- n: 146; since: 2.1.275; verified: 2.1.278 -->
`/plugin install <plugin> --marketplace <source>` offers to add the marketplace before installing the plugin — no need to register it separately first.

**Try it:** when installing a plugin from a new source, use `--marketplace` in a single command.

## new-system-prompt-snapshot — --system-prompt-snapshot off helps you iterate on a system prompt
<!-- n: 147; since: 2.1.267; verified: 2.1.278 -->
By default a conversation reuses the system prompt recorded on its first request. `--system-prompt-snapshot off` rebuilds it on every request — convenient while you tune `--append-system-prompt` text and continue the same conversation with `--continue`.

**Try it:** `claude -c --append-system-prompt "<new wording>" --system-prompt-snapshot off`.
