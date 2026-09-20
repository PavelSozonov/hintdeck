# commands — slash commands

## cmd-btw — /btw asks a side question without cluttering the context
<!-- n: 23; verified: 2.1.278 -->
`/btw <question>` answers from what is already in the conversation, but neither the question nor the answer enters the history. It works even while Claude is busy with the main task. The answer has no tools — it is a question about what is already known. In the overlay `c` copies the answer as Markdown and `f` turns the question into a forked subagent with full tool access.

**Try it:** in the middle of a task ask `/btw what was the name of that config file?`.

## cmd-rewind-summarize — /rewind can compress just a part of the conversation
<!-- n: 24; verified: 2.1.278 -->
Besides restoring code and conversation, the `/rewind` menu (or `Esc Esc` on an empty prompt) offers "Summarize from here" and "Summarize up to here": the first compresses everything after the selected message, the second everything before it. It is a targeted `/compact`: you can fold a long-winded debugging stretch while keeping the original instructions intact. Highlight a Summarize option and type what the summary should focus on.

**Try it:** after a long debugging session open `/rewind`, select the message where it started and choose "Summarize from here".

## cmd-rewind-bash-blindspot — Rewind does not see changes made through Bash
<!-- n: 25; verified: 2.1.278 -->
Checkpoints track only edits made with Claude's file editing tools. Anything changed by shell commands — `rm`, `mv`, `cp`, `sed -i` — is not restored. A session keeps its 100 most recent checkpoints, and snapshots are deleted after about 30 days (`cleanupPeriodDays`). Bottom line: `/rewind` is a local undo; your safety net is git.

**Try it:** before a risky task make a commit or `git stash` instead of counting on `/rewind`.

## cmd-rewind-after-clear — After /clear the previous conversation is still in the rewind menu
<!-- n: 26; verified: 2.1.278 -->
If you ran `/clear` and realised it was too soon, open `/rewind`: the top entry reads `/resume <session-id> (previous session)` and restores the conversation that was active before the clear. It works until you exit Claude Code or resume a different session.

**Try it:** `/clear`, then `Esc Esc` — and look at the first line of the list.

## cmd-context — /context shows exactly what is eating your context
<!-- n: 27; verified: 2.1.278 -->
`/context` draws a grid of context-window usage broken down by category: system prompt, tools, MCP, subagents, memory files, skills, messages — plus optimization suggestions. In fullscreen the per-item breakdown is collapsed; `/context all` expands it. It is the first command to run when Claude seems not to "see" your CLAUDE.md or rules.

**Try it:** `/context all` — and find the heaviest category.

## cmd-compact-focus — /compact takes an instruction about what to keep
<!-- n: 28; verified: 2.1.278 -->
`/compact <instructions>` summarizes the history with a focus, for example `/compact Focus on the API changes`. A standing rule can live in CLAUDE.md under a `# Compact instructions` heading — say, "always keep the list of modified files and the test commands" — and auto-compaction will honour it.

**Try it:** in a long session run `/compact keep the list of modified files and the open questions`.

## cmd-clear-name — /clear <name> labels the conversation you are leaving
<!-- n: 29; verified: 2.1.278 -->
`/clear` starts a new conversation with an empty context; the previous one is saved and reachable through `/resume`. If you pass a name — `/clear release-notes-draft` — it labels the conversation you are leaving, which makes it easy to find later.

**Try it:** when you finish a task, leave with `/clear <short-task-name>` instead of a bare `/clear`.

## cmd-branch — /branch tries another approach without losing the current conversation
<!-- n: 30; verified: 2.1.278 -->
`/branch [name]` copies the conversation into a new branch and switches you into it; the original stays untouched and is reachable through `/resume`. "Allow for this session" grants and background tasks carry over into the branch. From the shell, `claude --continue --fork-session` does the same.

**Try it:** before a debatable refactoring run `/branch try-alt-approach`.

## cmd-diff — /diff shows the changes without leaving Claude Code
<!-- n: 31; verified: 2.1.278 -->
`/diff` shows the working-tree changes: Claude's edits and anything else uncommitted. In fullscreen, with a terminal at least 110 columns wide, it is a side panel that updates as work goes on. Select lines in it with the mouse and they attach to your next prompt. `Ctrl+X B` changes what it compares against: this session's changes → everything uncommitted → everything since your branch split from the default branch.

**Try it:** after some edits open `/diff`, select a couple of lines and ask "why this change?".

## cmd-copy — /copy copies a reply or a single code block
<!-- n: 32; verified: 2.1.278 -->
`/copy` puts Claude's last reply on the clipboard; `/copy 2` takes the one before it. When the reply contains code blocks you get a picker: an individual block or the whole reply. It is more reliable than mouse selection, which captures the terminal's hard line wraps.

**Try it:** after a reply with code run `/copy` and pick the block you need.

## cmd-export — /export saves the conversation to a text file
<!-- n: 33; verified: 2.1.278 -->
`/export notes.txt` writes the whole conversation as plain text to a file; with no argument it opens a dialog to copy to the clipboard or save to a file. Handy for attaching an investigation to a ticket or handing it to a colleague.

**Try it:** `/export debug-session.txt` at the end of a meaty debugging session.

## cmd-focus — /focus leaves only your prompt, a summary and the reply on screen
<!-- n: 34; verified: 2.1.278 -->
`/focus` turns on a quiet view: your last prompt, a one-line summary of tool calls with edit diffstats, and the final response. The setting persists across sessions; run `/focus` again to turn it off.

**Try it:** turn on `/focus` for a task with dozens of tool calls.

## cmd-recap — /recap gives one line on where you left off
<!-- n: 35; verified: 2.1.278 -->
When you come back to the terminal after at least three minutes away, Claude Code shows a short recap of the session on its own. `/recap` does the same on demand (up to 400 characters). The automatic one can be turned off in `/config` — "Session recap".

**Try it:** when you return to yesterday's session with `claude -c`, start with `/recap`.

## cmd-goal — /goal keeps Claude working until a condition is met
<!-- n: 36; verified: 2.1.278 -->
`/goal <condition>` starts the work and after every turn hands the condition to a separate evaluator model; Claude keeps going until it holds. The evaluator runs nothing itself and judges from the conversation, so the condition must be measurable and name its check: "`npm test` exits 0". You can bound it in the text: "or stop after 20 turns". Remove it with `/goal clear`.

**Try it:** `/goal all tests in tests/ pass and the linter is clean, or stop after 15 turns`.

## cmd-loop — /loop repeats a prompt on a schedule while the session stays open
<!-- n: 37; verified: 2.1.278 -->
`/loop 5m check whether the deploy finished` runs on a fixed interval (units `s`, `m`, `h`, `d`). Without an interval Claude picks the pause itself, from a minute to an hour. A bare `/loop` runs the built-in maintenance prompt: finish unfinished work and tend to the current branch's PR (reviews, CI, conflicts); a `loop.md` file replaces it. The prompt can be a skill too: `/loop 20m /review-pr 1234`.

**Try it:** `/loop check whether CI passed and address the review comments`.

## cmd-plan — /plan <description> starts planning a task right away
<!-- n: 38; verified: 2.1.278 -->
`/plan fix the auth bug` enters plan mode and starts on that task immediately — no cycling through modes with `Shift+Tab`. In plan mode Claude explores and proposes a plan without changing anything. Accepting the plan also gives the session a meaningful name.

**Try it:** start your next non-trivial task with `/plan <description>`.

## cmd-session-only-switch — `s` in /model and /effort changes the setting for this session only
<!-- n: 39; verified: 2.1.278 -->
`/model` and `/effort` confirmed with `Enter` save the choice as the default for new sessions. When you need a model or level just once, press `s` in the picker: the change applies to the current session only. The level is saved per model (the `modelSettings` key).

**Try it:** `/effort`, pick a lower level and confirm with `s` rather than `Enter`.

## cmd-effort — Lower effort is faster and cheaper on simple tasks
<!-- n: 40; verified: 2.1.278 -->
The effort level (`low` … `xhigh`, `max`) controls how much the model reasons at each step. For routine work — renames, small edits — a low level is noticeably faster and cheaper. `max` always applies to the current session only. From the shell: `claude --effort low`.

**Try it:** before a run of small edits do `/effort medium` and confirm with `s`.

## cmd-insights — /insights reports on how you work with Claude Code
<!-- n: 41; verified: 2.1.278 -->
`/insights` analyzes your recent sessions on this machine and writes an HTML report to `~/.claude/usage-data/report.html`: what you work on, where the friction is (misunderstood requests, buggy code) and which features to try. The analysis spends tokens from your plan.

**Try it:** run `/insights` and open the report in a browser.

## cmd-powerup — /powerup offers interactive lessons on features
<!-- n: 42; verified: 2.1.278 -->
`/powerup` opens short interactive lessons with animated demos of Claude Code features — a way to see a feature in action instead of reading about it.

**Try it:** run `/powerup` and take one lesson.

## cmd-release-notes — /release-notes shows the changelog by version without spending context
<!-- n: 43; verified: 2.1.278 -->
`/release-notes` opens a version picker and prints the notes into your transcript — without adding them to the context Claude sees. Useful after an update: `claude --version`, then see what changed.

**Try it:** `/release-notes` and open the latest version.

## cmd-usage — /usage shows session cost, plan limits and the cause of cache misses
<!-- n: 44; verified: 2.1.278 -->
`/usage` (aliases `/cost` and `/stats`) shows the session cost, plan limits and activity stats, and on paid plans a breakdown of what counts against your limits. Since 2.1.260 it also names the likely cause of prompt-cache misses — for example, tool definitions changed or the session sat idle past the TTL.

**Try it:** `/usage` in the middle of an expensive session.

## cmd-skill-doctor — /skill-doctor finds skills that only take up context
<!-- n: 45; verified: 2.1.278 -->
Every skill's description sits in the context all the time. `/skill-doctor` shows what each skill costs and how often it is used. In `/skills`, `t` sorts by token count and `Space` cycles a skill's visibility to the model and the `/` menu (plugin skills excepted). Unused plugins with many skills are a common source of waste.

**Try it:** `/skill-doctor`, then `/skills` and `t`.

## cmd-doctor — /doctor checks your installation and configuration and proposes fixes
<!-- n: 46; verified: 2.1.278 -->
`/doctor` checks installation health, broken settings files, unused skills, MCP servers and plugins, and CLAUDE.md content that Claude could derive from the code anyway — and proposes fixes, asking before it applies them. From the shell there is a read-only version: `claude doctor`.

**Try it:** `/doctor` — especially if you have not reviewed your plugins in a while.

## cmd-add-dir-cd — /add-dir grants access to a directory, /cd moves the session there
<!-- n: 47; verified: 2.1.278 -->
`/add-dir <path>` adds a directory for reading and editing files, but most `.claude/` configuration is not picked up from it. `/cd <path>` moves the session itself to another working directory and keeps the conversation. In both, `Tab` completes the path.

**Try it:** `/add-dir ../neighbouring-repo` when you need to check code that lives next door.

## cmd-rename-resume — Name your sessions and come back to them by name
<!-- n: 48; verified: 2.1.278 -->
`claude -n auth-refactor` sets a name at startup, `/rename <name>` does it mid-session; the name shows on the prompt bar and in the terminal title. To return: `claude -r auth-refactor` or `/resume auth-refactor`. If a live session already uses the name, the new one gets a two-word suffix.

**Try it:** `/rename <task-name>` now, and tomorrow `claude -r <task-name>`.

## cmd-resume-picker — The session picker has a preview and can search by PR link
<!-- n: 49; verified: 2.1.278 -->
In the `/resume` picker: `Space` previews the content, `Ctrl+R` renames, `Ctrl+A` shows sessions from all projects, `Ctrl+W` from all worktrees of the repository, `Ctrl+B` only the current git branch. Start typing to search; a pasted pull or merge request URL finds the session that created it.

**Try it:** `/resume`, then `Ctrl+B` and `Space` on any row.

## cmd-tasks — /tasks lists everything running in the background of this session
<!-- n: 50; verified: 2.1.278 -->
`/tasks` (alias `/bashes`) shows background shell commands and subagents, including finished ones; `Enter` on a subagent opens its transcript. Don't confuse it with `Ctrl+T`, which shows Claude's own task checklist.

**Try it:** ask for a long command to run in the background and open `/tasks`.

## cmd-subtask — /subtask hands a side task to a fork that knows the whole conversation
<!-- n: 51; verified: 2.1.278 -->
`/subtask <task>` starts a forked subagent: it inherits the entire conversation (system prompt, tools, history), works in the background and returns its result as a message. No need to re-explain the context. Forks show in a panel below the prompt: `Enter` opens the transcript so you can steer it, `x` stops it.

**Try it:** `/subtask draft unit tests for the changes made so far`.

## cmd-fork-bg — /bg sends the conversation to the background, /fork sends a copy of it
<!-- n: 52; verified: 2.1.278 -->
`/background` (alias `/bg`) moves the current conversation into a background session and frees the terminal; you can add an instruction: `/bg run the tests and fix the failures`. `/fork [prompt]` sends a copy to the background while you keep working here. Watch background sessions with `claude agents`. `Left` on an empty prompt backgrounds the session and opens that list in one step.

**Try it:** `/fork open a draft PR with the current changes`.

## cmd-code-review — /code-review, /simplify and /security-review look for different things
<!-- n: 53; verified: 2.1.278 -->
`/code-review [low…max] [--fix] [--comment] [pr#|branch|path]` looks for correctness bugs in the diff; `--fix` applies the findings, `--comment` posts them inline on the PR. `/simplify` is about quality — reuse, simplification, efficiency, level of abstraction — and does not hunt bugs. `/security-review` analyzes the branch's changes for vulnerabilities (it needs an `origin` remote).

**Try it:** before committing run `/code-review high`, then `/simplify`.

## cmd-statusline — /statusline is configured in plain language
<!-- n: 54; skip-if: statusline; verified: 2.1.278 -->
`/statusline <description>` generates a script in `~/.claude/` and wires it into your settings. The status line can show the model, context usage, cost and duration, plan limits, prompt-cache state and git status. With no arguments the command configures the line from your shell prompt.

**Try it:** `/statusline show the model and context percentage with a progress bar`.

## cmd-reload-skills — /reload-skills picks up skill edits without a restart
<!-- n: 55; verified: 2.1.278 -->
Edited or added a skill on disk? `/reload-skills` re-scans the skill and command directories and reports how many were added or removed. Plugins have the equivalent `/reload-plugins`.

**Try it:** run `/reload-skills` after editing any SKILL.md.

## cmd-config-inline — /config key=value changes a setting without the menu
<!-- n: 56; verified: 2.1.278 -->
`/config` accepts `key=value` pairs and changes the setting directly without opening the interface, for example `/config thinking=false`. You can pass several pairs at once.

**Try it:** `/config thinking=false`, then set it back.

## cmd-output-style — /output-style switches the style of replies
<!-- n: 57; skip-if: output-style; verified: 2.1.278 -->
`/output-style` lists the available output styles, `/output-style <name>` switches to one, for example `/output-style concise`. You can define your own styles as separate files. The command arrived in 2.1.269.

**Try it:** `/output-style` — look at the list and try one on the current task.

## cmd-permissions-denials — /permissions shows recent auto mode denials
<!-- n: 58; needs: auto-mode; verified: 2.1.278 -->
The `/permissions` dialog shows rules by scope, working directories and the recent denials of the auto mode classifier, and its Auto mode tab shows the classifier rules themselves. If you run it while Claude is working, the dialog opens right away and changes apply from the next tool call in the same turn.

**Try it:** after auto mode blocks something, open `/permissions` and look at the reason.

## cmd-rate-limit — When you hit a usage limit the session continues on its own after the reset
<!-- n: 59; verified: 2.1.278 -->
When a subscription limit stops Claude mid-task, the session waits and picks the task up by itself once the limit resets (since 2.1.234, in interactive sessions signed in with a claude.ai subscription). The main thing is to keep the session open. Cancel the wait with `Esc` on an empty prompt; the options are in `/rate-limit-options`. Permissions are still asked as usual when it continues, so the task can stop on a prompt.

**Try it:** next time you hit a limit, leave the terminal open and check the status line at the bottom.

## cmd-advisor — /advisor adds a second model as an advisor
<!-- n: 60; skip-if: advisor; verified: 2.1.278 -->
`/advisor opus` turns on the experimental advisor: at key moments — before committing to an approach, on a recurring error, before declaring "done" — the main model consults a stronger one that sees the whole conversation. It pays off when the main model is cheap and a wrong plan is expensive. Turn it off with `/advisor off`.

**Try it:** on a long refactoring with a lighter model, turn on `/advisor opus`.

## cmd-verify-run — /verify checks a change in the running app, not just with tests
<!-- n: 61; verified: 2.1.278 -->
`/run` launches your project's app and drives it to see a change working; `/verify` confirms the change does what it should — it builds, runs and observes the result instead of relying only on tests and type checks. `/run-skill-generator` teaches both, once, how to build and launch your particular project by writing a project skill.

**Try it:** `/run-skill-generator` in a project with a non-trivial launch.

## cmd-debug — /debug turns on debug logging in the middle of a session
<!-- n: 62; verified: 2.1.278 -->
Debug logging is off by default. `/debug [description of the problem]` enables it on the fly and asks Claude to diagnose using the log — no need to restart with `claude --debug` and reproduce the situation again.

**Try it:** when Claude Code itself behaves oddly, run `/debug <what exactly is wrong>`.
