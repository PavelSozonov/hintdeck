# config — settings, permissions, hooks, terminal

## cfg-notifications — Get notified when Claude finishes or waits for you
<!-- n: 92; skip-if: notifications; verified: 2.1.278 -->
When Claude finishes a task or stops on a permission prompt while you are away from the terminal, it sends a notification. By default desktop notifications work only in Ghostty, Kitty and iTerm2 (in iTerm2 enable "Send escape sequence-generated alerts" in the profile). In other terminals set `"preferredNotifChannel": "terminal_bell"` in `~/.claude/settings.json`, or add a `Notification` hook with your own command — on macOS `osascript -e 'display notification …'` does the job.

**Try it:** add `preferredNotifChannel` or a `Notification` hook and start a long task, then switch to another window.

## cfg-keybindings — Your own keyboard shortcuts live in ~/.claude/keybindings.json
<!-- n: 93; skip-if: keybindings; verified: 2.1.278 -->
`/keybindings` creates and opens `~/.claude/keybindings.json`. The format is a `bindings` array of blocks, each with a `context` (`Chat`, `Global`, `Transcript`, `Confirmation` and others) and a map from keystrokes to actions: `"ctrl+e": "chat:externalEditor"`. A `null` value unbinds a key. Changes apply without a restart. The word editing shortcuts (`Ctrl+W`, `Alt+B`, `Alt+F`, `Alt+D`) cannot be remapped — the file has no actions for them.

**Try it:** `/keybindings` — and bind the external editor to a key you like.

## cfg-permission-rules — In Bash rules put the * after the subcommand
<!-- n: 94; verified: 2.1.278 -->
A permission rule is `Tool` or `Tool(specifier)`; a `*` in a Bash rule matches any text, spaces included. What limits the rule is everything before the first `*`: `Bash(git log *)` allows only `git log`, while `Bash(git *)` allows every git command, push included. Note that a command written another way (`git -C . push`) is not matched by a rule on `git push`.

**Try it:** open `/permissions` and check for rules as broad as `Bash(git *)`.

## cfg-param-rules — Deny rules can match tool parameters
<!-- n: 95; verified: 2.1.278 -->
Deny and ask rules can match a top-level parameter of any built-in tool: `Agent(model:opus)` — subagent calls that request Opus, `Agent(isolation:worktree)` — subagents in a worktree, `Bash(run_in_background:true)` — background commands. The value supports `*`. A tool's primary field (the Bash command, the file path) cannot be matched this way — use the regular syntax for that.

**Try it:** if you don't want expensive subagents, add the ask rule `Agent(model:opus)`.

## cfg-hook-reinject — A SessionStart hook with the compact matcher restores context after compaction
<!-- n: 96; verified: 2.1.278 -->
Compaction can lose important details. A `SessionStart` hook with `"matcher": "compact"` fires after every compaction, and whatever its command prints to stdout is added to Claude's context. Instead of an `echo` with a reminder you can use any command, such as `git log --oneline -5`.

**Try it:** add such a hook with a reminder of the project's key commands and the current task.

## cfg-stop-hook-gate — A Stop hook won't let the turn end until your check passes
<!-- n: 97; verified: 2.1.278 -->
A `Stop` hook runs your check script and blocks the turn from ending until the script passes — a deterministic gate, unlike asking "don't forget to run the tests". After 8 consecutive blocks Claude Code ends the turn anyway to avoid a loop. A lighter, single-session alternative is `/goal`.

**Try it:** if Claude keeps "finishing" with red tests, add a Stop hook that runs them.

## cfg-settings-precedence — Whose settings.json wins
<!-- n: 98; verified: 2.1.278 -->
Settings merge across several scopes: managed settings apply first (when present), then the closer scope wins — local → project → user. Command-line flags and environment variables are one more layer on top. `/status` shows which sources are active, and `claude doctor` from the shell finds broken settings files without starting a session.

**Try it:** `/status` — look at the list of active settings sources.

## cfg-output-limits — The amount of command output Claude sees inline is configurable
<!-- n: 99; verified: 2.1.278 -->
Claude does not receive long command output in full: past a threshold it goes to a file and the conversation keeps a preview. The `bashOutputMaxChars` and `taskOutputMaxChars` settings raise that threshold for regular and background commands — up to 128K characters (since 2.1.261). Useful when the whole test log matters, not just its beginning.

**Try it:** if Claude "does not see" the end of a long output, raise `bashOutputMaxChars` in `settings.json`.

## cfg-auto-mode-config — claude auto-mode config shows the auto mode rules in effect
<!-- n: 100; needs: auto-mode; verified: 2.1.278 -->
`claude auto-mode config` prints the effective auto mode configuration with your settings applied, and `claude auto-mode defaults` prints the built-in classifier rules as JSON (`--label <prefix>` narrows them). `/auto-mode-setup` drafts `autoMode.environment` entries from your project and recent sessions, and `claude auto-mode reset` removes the `autoMode` section from your user settings.

**Try it:** `claude auto-mode config` — check what the classifier knows about your environment.

## cfg-option-as-meta — Enable Option as Meta to make the Alt shortcuts work
<!-- n: 101; needs: macos; verified: 2.1.278 -->
On macOS the `Alt` shortcuts (`Alt+B`, `Alt+F`, `Alt+D`, `Alt+Y`, `Alt+P`) need the terminal to send Option as Meta; without it they type special characters. How to enable it for your terminal is covered in the "Enable Option key shortcuts on macOS" section of the terminal-config docs page. After that `Option+Enter` for a newline works too.

**Try it:** press `Alt+B` in a line with text: if the cursor jumps back a word, you are set.

## cfg-cleanup-period — Transcripts and rewind snapshots live for about 30 days
<!-- n: 102; verified: 2.1.278 -->
Claude Code deletes old session transcripts and checkpoint file snapshots on a schedule — by default after about 30 days; `cleanupPeriodDays` sets the period. After that a `/rewind` to an old point can answer "No files were restored". Auto memory files are exempt from the sweep.

**Try it:** if you come back to sessions months later, increase `cleanupPeriodDays` in your settings.

## cfg-vim-mode — The input has a vim mode
<!-- n: 103; verified: 2.1.278 -->
The prompt input can work in vim mode: NORMAL and INSERT, navigation, text objects, visual mode. Turn it on in `/config` → Editor mode; the separate `/vim` command was removed in 2.1.92.

**Try it:** `/config`, find Editor mode and switch to vim for a day.
