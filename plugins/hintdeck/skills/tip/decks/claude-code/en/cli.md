# cli — launch flags, headless mode, pipes

## cli-pipe — You can pipe data into claude -p
<!-- n: 63; verified: 2.1.278 -->
Non-interactive mode reads stdin, so Claude fits into a pipeline like any other tool: `cat build-error.txt | claude -p 'concisely explain the root cause' > out.txt`. Piped stdin is capped at 10MB; for larger inputs write the data to a file and reference the path in the prompt.

**Try it:** `git diff | claude -p 'find the risky spots in this diff'`.

## cli-json-schema — claude -p can return JSON that matches your schema exactly
<!-- n: 64; verified: 2.1.278 -->
`--output-format json` returns the result with metadata: session id, usage, `total_cost_usd`. Add `--json-schema '<schema>'` and the `structured_output` field holds an object valid against your JSON Schema. That turns Claude into a predictable step of a script.

**Try it:** `claude -p "list the functions in main.py" --output-format json --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}},"required":["functions"]}'`.

## cli-continue — claude -c continues the most recent conversation in this directory
<!-- n: 65; verified: 2.1.278 -->
`claude -c` picks up the latest conversation of the current directory; `claude -r <name|id> "query"` resumes a specific one with a new message. It works non-interactively too: `claude -c -p "check for type errors"` adds a turn to the same session. `-c` skips sessions created with `claude -p`.

**Try it:** in the morning, instead of retelling yesterday — `claude -c`.

## cli-from-pr — claude --from-pr finds the session that created a pull request
<!-- n: 66; needs: git; verified: 2.1.278 -->
Sessions are linked automatically to the PRs Claude created in them. `claude --from-pr 123` opens the list of sessions linked to that PR (it takes a number or a GitHub, GitLab or Bitbucket URL) — handy for getting the context back when review comments arrive.

**Try it:** when a review lands on a PR made with Claude, run `claude --from-pr <number>`.

## cli-bare — --bare makes scripted calls start faster
<!-- n: 67; verified: 2.1.278 -->
`claude --bare -p "..."` skips auto-discovery of hooks, skills, commands, subagents, plugins, MCP servers, auto memory and CLAUDE.md — a scripted call starts faster and does not depend on your personal configuration. Claude still has Bash, file read and file edit.

**Try it:** time `claude -p "2+2"` against `claude --bare -p "2+2"`.

## cli-safe-mode — --safe-mode starts a session with every customization off
<!-- n: 68; verified: 2.1.278 -->
When Claude Code acts strangely, `claude --safe-mode` starts without CLAUDE.md, skills, plugins, hooks, MCP, custom commands and agents, themes, keybindings and the status line; authentication, model selection and permissions work as usual. If the problem is gone, one of those surfaces is the cause. For a fully clean run: `cd /tmp && CLAUDE_CONFIG_DIR=/tmp/claude-clean claude`.

**Try it:** next time something is inexplicably off, start with `claude --safe-mode`.

## cli-budget-limits — A headless run can be capped by budget and by number of turns
<!-- n: 69; verified: 2.1.278 -->
`claude -p` has safety stops: `--max-budget-usd 2` stops the work once the amount is spent (subagent spend counts), and `--max-turns 10` limits the agentic turns and exits with an error when exceeded. They are a must for scripts and CI, where nobody is watching the screen.

**Try it:** add `--max-budget-usd` to any script of yours that calls `claude -p`.

## cli-settings-inline — --settings overrides settings for a single session
<!-- n: 70; verified: 2.1.278 -->
`claude --settings ./exp.json` or `claude --settings '{"effortLevel":"low"}'` overrides the given keys for this session only; the rest still come from your files. `--setting-sources user,project` chooses which settings files are read at all.

**Try it:** test an experimental setting through `--settings` without touching `settings.json`.

## cli-system-prompt — --append-system-prompt adds rules, --system-prompt replaces everything
<!-- n: 71; verified: 2.1.278 -->
`--append-system-prompt "..."` appends text to the default system prompt — a safe way to set rules for one run; the `-file` variant reads the text from a file. `--system-prompt` replaces the whole prompt, built-in instructions included — rarely needed, and only deliberately.

**Try it:** `claude --append-system-prompt "Reply with a diff only" -p "rename foo to bar in utils.py"`.

## cli-tools-restrict — --tools and --disallowedTools restrict the tools of a run
<!-- n: 72; verified: 2.1.278 -->
`--tools "Bash,Edit,Read"` leaves only the listed built-in tools (`""` means none). `--disallowedTools "mcp__*"` removes every MCP tool from the context, while a rule like `Bash(rm *)` keeps the tool and denies matching calls. `--allowedTools "Bash(git log *)"` lists what runs without asking.

**Try it:** for a safe analysis — `claude --tools "Read" -p "describe the architecture"`.

## cli-debug-filter — --debug takes a category filter
<!-- n: 73; verified: 2.1.278 -->
`claude --debug='mcp,startup'` enables debugging for the categories you need; the filter binds only in the `=` form. The session log is at `~/.claude/debug/<session-id>.txt`, and `--debug-file <path>` writes it to a file of your choice.

**Try it:** when an MCP server offers no tools, run `claude --debug=mcp` and read the log.

## cli-install-version — claude install installs a specific version
<!-- n: 74; verified: 2.1.278 -->
`claude update` moves to the latest version, and `claude install <version>` installs a specific one: `claude install 2.1.118`, `claude install stable`, `claude install latest`. Useful for rolling back when a fresh release breaks your workflow.

**Try it:** `claude --version`, and compare it with the top entry in `/release-notes`.

## cli-project-purge — claude project purge deletes a project's local state
<!-- n: 75; verified: 2.1.278 -->
`claude project purge [path]` deletes all local Claude Code state for a project: transcripts, task lists, debug logs, file-edit history, prompt history and the entry in `~/.claude.json`. `--dry-run` previews what would go; without a path you pick from an interactive list.

**Try it:** `claude project purge --dry-run` on a long-abandoned project.

## cli-fallback-model — --fallback-model sets backup models for overload
<!-- n: 76; verified: 2.1.278 -->
`--fallback-model` takes a comma-separated list: when the primary model is overloaded or unavailable, Claude Code tries the next ones in order. To make the chain permanent there is the `fallbackModel` setting.

**Try it:** add `--fallback-model sonnet` to a long overnight `claude -p`.

## cli-permission-prompts-none — --permission-prompts none is for runs with nobody at the keyboard
<!-- n: 77; verified: 2.1.278 -->
In a headless run where nobody can answer, `--permission-prompts none` automatically denies anything that would prompt, while the active permission mode (auto mode included) keeps deciding as usual. The run will not hang waiting for an answer. Available since 2.1.259.

**Try it:** add the flag to a cron or CI script that calls `claude -p`.

## cli-auth-status — claude auth status is handy in scripts
<!-- n: 78; verified: 2.1.278 -->
`claude auth status` prints the authentication state as JSON and exits 0 when logged in and 1 when not; `--text` gives a readable form. For CI there is `claude setup-token`: it issues a long-lived OAuth token and prints it without saving it anywhere.

**Try it:** `claude auth status --text`.
