# context — context, memory, CLAUDE.md

## ctx-clear-between-tasks — /clear between unrelated tasks
<!-- n: 79; verified: 2.1.278 -->
The most common anti-pattern is the kitchen-sink session: you start one task, ask about something unrelated, then go back to the first. The context fills with irrelevant material, quality drops, and every further message pays for that ballast. Run `/clear` between unrelated tasks; `/rename` first, so you can find the conversation through `/resume`.

**Try it:** when a task is done — `/rename <what was done>` and `/clear`.

## ctx-two-corrections-rule — Two failed corrections in a row mean it is time to start over
<!-- n: 80; verified: 2.1.278 -->
If you have corrected Claude twice on the same issue and the result is still wrong, the context is already cluttered with failed attempts. Better to `/clear` and write a new, more specific prompt that uses what you learned. A clean session with a better prompt almost always beats a long one with accumulated corrections.

**Try it:** on the third correction of the same thing, stop and rewrite the original prompt.

## ctx-claude-md-scopes — CLAUDE.md has four scopes, and subdirectory files load lazily
<!-- n: 81; verified: 2.1.278 -->
Instructions are read from several places: `~/.claude/CLAUDE.md` (personal, all projects), `./CLAUDE.md` or `./.claude/CLAUDE.md` (the project, in git), `./CLAUDE.local.md` (personal for the project, in `.gitignore`); organizations can add a managed policy file above them. Files above the working directory load at launch; CLAUDE.md files in subdirectories load only when Claude reads files there.

**Try it:** move your personal sandbox URLs and test data from the shared CLAUDE.md to `CLAUDE.local.md`.

## ctx-imports — CLAUDE.md can import files with @path
<!-- n: 82; verified: 2.1.278 -->
A line such as `@docs/git-instructions.md` in CLAUDE.md loads that file into the context at launch; relative paths resolve from the importing file, and imports nest up to four levels. To mention a path without importing it, wrap it in backticks. Personal instructions shared by every worktree of a repository are best kept at home: `@~/.claude/my-project.md`.

**Try it:** replace a README excerpt pasted into CLAUDE.md with `@README.md`.

## ctx-rules-paths — Rules in .claude/rules/ can load only for the files they concern
<!-- n: 83; skip-if: rules; verified: 2.1.278 -->
Instead of one huge CLAUDE.md, keep `.claude/rules/*.md`, one file per topic. With `paths: ["src/api/**/*.ts"]` in a rule's frontmatter it enters the context only when Claude reads matching files — less noise, less spend. Rules without `paths` load at launch just like CLAUDE.md.

**Try it:** move the testing section of CLAUDE.md into `.claude/rules/testing.md` with `paths` set to the tests directory.

## ctx-prune-claude-md — A long CLAUDE.md is followed worse than a short one
<!-- n: 84; verified: 2.1.278 -->
As CLAUDE.md grows, important rules drown in the noise and Claude misses half of them. Prune it regularly: if Claude does the right thing without the instruction, delete it; if a rule must always hold, turn it into a hook. `/doctor` flags CLAUDE.md content that can be derived from the code itself.

**Try it:** reread your CLAUDE.md and delete three items Claude follows anyway.

## ctx-auto-memory — A project's auto memory lives in ~/.claude/projects/…/memory
<!-- n: 85; verified: 2.1.278 -->
Claude keeps its own notes between sessions: the directory `~/.claude/projects/<project>/memory/` holds a `MEMORY.md` index and one file per memory. Only the first 200 lines or 25KB of the index load at the start of every conversation; the other files are read on demand. The memory is shared by all worktrees of a repository and is local to the machine. Review and edit it with `/memory`.

**Try it:** open `/memory` and check for stale entries.

## ctx-subagents-for-research — Hand research to subagents to save your own context
<!-- n: 86; verified: 2.1.278 -->
While exploring a codebase Claude reads many files, and all of them settle in your context. A subagent works in a separate window and returns only a summary. The wording is simple: "Use subagents to investigate how our auth handles token refresh". The main conversation stays clean for the implementation.

**Try it:** start your next "how does X work here" question with "use subagents to find out…".

## ctx-scope-investigation — An unscoped "investigate" eats your context
<!-- n: 87; verified: 2.1.278 -->
Asking Claude to "look into X" with no boundaries leads to hundreds of files read. Set a scope: which directories to look at, which question to answer, what form the result should take. Or give the investigation to a subagent so it never reaches the main context.

**Try it:** instead of "see how billing works" — "in src/billing/ find where VAT is calculated and name the function and the file".

## ctx-compact-skills — After compaction skills are trimmed to 5,000 tokens each
<!-- n: 88; verified: 2.1.278 -->
During auto-compaction invoked skills return to the context only in part: the first 5,000 tokens of each are kept, within a shared budget of 25,000 tokens filled from the most recently invoked one. If you invoked many skills, early ones can drop out entirely. If a long skill "stopped working" after compaction, just invoke it again.

**Try it:** in a long session, re-invoke your key skill after a compaction.

## ctx-autocompact-window — /autocompact sets the auto-compaction threshold
<!-- n: 89; verified: 2.1.278 -->
`/autocompact 500k` sets how full the context window gets before auto-compaction kicks in; `auto` returns to the window tuned for your model. The value is saved to your user settings. For a single run use `claude --autocompact 500k`. With no argument the command shows the current window. With a 1M-token window an earlier threshold makes long sessions noticeably cheaper.

**Try it:** `/autocompact` — look at the current value.

## ctx-cli-over-mcp — CLI tools are lighter on context than MCP servers
<!-- n: 90; verified: 2.1.278 -->
MCP tool definitions are deferred by default (only names enter the context), yet tools like `gh`, `aws` and `gcloud` are still cheaper: they add no tool listings at all — Claude simply runs the commands. Disable servers you don't use through `/mcp`, and see what takes up space in `/context`.

**Try it:** `/mcp` — disable the servers you have not used this week.

## ctx-instructions-vs-enforcement — CLAUDE.md explains; hooks and permissions enforce
<!-- n: 91; verified: 2.1.278 -->
CLAUDE.md tells Claude how things are done in your project so it makes good decisions — but that is no guarantee. Anything that must never happen (editing protected files, dangerous commands) is enforced by permission rules and hooks: they apply regardless of what the model decides.

**Try it:** find a rule with the word "never" in your CLAUDE.md and consider whether it belongs in a deny rule or a hook.
