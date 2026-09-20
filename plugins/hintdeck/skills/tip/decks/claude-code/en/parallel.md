# parallel — worktrees, background sessions, parallel work

## par-worktree-flag — claude -w starts a session in an isolated worktree
<!-- n: 116; needs: git; verified: 2.1.278 -->
`claude -w feature-auth` creates a git worktree at `.claude/worktrees/feature-auth/` on a new branch `worktree-feature-auth` and starts in it, so the edits of parallel sessions never collide. Without a name one is generated. On exit a clean worktree is removed automatically; if it holds work, Claude asks whether to keep or remove it. Add `.claude/worktrees/` to `.gitignore`.

**Try it:** open a second terminal and run `claude -w <task-name>` next to your main session.

## par-worktree-pr — claude -w "#1234" opens a worktree right on a pull request
<!-- n: 117; needs: git; verified: 2.1.278 -->
Instead of a name `--worktree` accepts a number with a hash, a GitHub PR URL or a GitLab MR URL: Claude Code fetches the head commit from `origin` and creates the worktree `.claude/worktrees/pr-<number>`. Quote the argument, or the shell treats `#` as a comment. Convenient for reviewing someone else's PR without touching your working tree.

**Try it:** `claude -w "#<PR number>"` and ask for a walkthrough of the changes.

## par-worktreeinclude — .worktreeinclude copies .env into every new worktree
<!-- n: 118; needs: git; skip-if: worktree-include; verified: 2.1.278 -->
A worktree is a fresh checkout, so gitignored files like `.env` are missing from it. A `.worktreeinclude` file in the project root (`.gitignore` syntax) lists what to copy into each new worktree; only files that both match a pattern and are gitignored get copied. It applies to subagent worktrees too.

**Try it:** create `.worktreeinclude` with the lines `.env` and `.env.local`.

## par-worktree-baseref — A worktree branches from main by default, not from your branch
<!-- n: 119; needs: git; skip-if: worktree-config; verified: 2.1.278 -->
A new worktree branches from the default branch on the remote (`"fresh"`), so your unpushed commits are not in it. The setting `"worktree": {"baseRef": "head"}` makes it branch from your local `HEAD` — needed when subagents in worktrees must see work in progress. You cannot name an arbitrary branch; for that, create the worktree with git yourself.

**Try it:** if isolated agents "don't see" your latest commits, set `baseRef: "head"`.

## par-worktree-tmux — claude -w name --tmux opens the worktree in its own pane
<!-- n: 120; needs: git; verified: 2.1.278 -->
`claude -w feature-auth --tmux` creates a tmux session for the worktree; in iTerm2 native panes are used, and `--tmux=classic` selects traditional tmux. Each parallel task gets its own window.

**Try it:** `claude -w experiment --tmux`.

## par-bg — claude --bg starts a task in the background and returns your shell at once
<!-- n: 121; verified: 2.1.278 -->
`claude --bg "investigate the flaky test X"` starts a background session and prints its id and the management commands. The prompt is the positional argument; the flag cannot be combined with `-p`. From there: `claude agents` for an overview, `claude attach <id>` to attach, `claude logs <id>` for recent output, `claude stop <id>` to stop it.

**Try it:** `claude --bg "find and list the TODOs in src/"`, then `claude agents`.

## par-agent-view — claude agents is the control panel for parallel sessions
<!-- n: 122; verified: 2.1.278 -->
`claude agents` opens agent view: a table of background sessions showing whether each is working, waiting on you, or done. The prompt at the bottom dispatches a new session, `Space` peeks and lets you reply without attaching, `Enter` or `Right` attaches fully, `Left` on an empty prompt detaches again. In a regular session the `←` hint in the footer counts the background agents waiting for your answer.

**Try it:** `claude agents` and dispatch two independent tasks from there.

## par-bg-exec — claude --bg --exec runs a plain shell command in the background
<!-- n: 123; verified: 2.1.278 -->
`claude --bg --exec 'pytest -x'` starts not a Claude session but the command itself as a PTY-backed background job — it shows up and is managed in the same place as the other background sessions.

**Try it:** `claude --bg --exec '<a long-running project command>'` and look at it in `claude agents`.

## par-color-rename — /color and /rename keep parallel sessions apart
<!-- n: 124; verified: 2.1.278 -->
`/color <color>` tints the prompt bar of the current session (`red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan`; no argument picks a random one), and `/rename` shows the session name on the prompt bar and in the terminal title. Together they tell you at a glance which window you are in.

**Try it:** in each parallel session run `/rename <task>` and `/color <color>`.

## par-cross-session — Sessions on the same machine can message each other
<!-- n: 125; verified: 2.1.278 -->
In sessions with cross-session messaging enabled, type `@` and at least one letter: along with files, the suggestions list your other live sessions on this machine, and you can ask Claude to message the one you pick. `/list-agents` (also `/peers`) shows who can be messaged: subagents, agent team teammates and other sessions.

**Try it:** `/list-agents` with two sessions open.

## par-batch — /batch splits a large change across parallel agents
<!-- n: 126; needs: git; verified: 2.1.278 -->
`/batch <instruction>` researches the codebase, splits the work into 5–30 independent units and presents a plan. Once approved, each unit gets a background subagent in its own worktree: it implements the unit, runs the tests and opens a pull request. Example: `/batch migrate src/ from JavaScript to TypeScript`.

**Try it:** start your next mechanical many-file migration with `/batch` and look at the plan.

## par-workflows — Workflows orchestrate dozens of agents from a script
<!-- n: 127; verified: 2.1.278 -->
A dynamic workflow is a JavaScript script that Claude writes and a runtime executes: the loop, the branching and the intermediate results live in the script rather than in the model's context, so it scales to dozens or hundreds of agents and a run can be resumed. It fits a codebase-wide audit, a migration of hundreds of files, research with cross-checked sources. See one in action with the bundled `/deep-research <question>`; progress is in `/workflows`.

**Try it:** `/deep-research <a question that needs several sources cross-checked>`.

## par-fan-out-script — A loop over claude -p handles uniform per-file work
<!-- n: 128; verified: 2.1.278 -->
A do-it-yourself fan-out: have Claude save the list of files to `files.txt`, then `for file in $(cat files.txt); do claude -p "Migrate $file … Return OK or FAIL" --allowedTools "Edit,Bash(git commit *)"; done`. Refine the prompt on the first 2–3 files before running the full list. `--allowedTools` limits what can happen unattended.

**Try it:** run such a loop on three files before you run it on a hundred.
