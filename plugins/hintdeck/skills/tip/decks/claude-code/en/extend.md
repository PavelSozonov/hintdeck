# extend — skills, subagents, MCP, plugins

## ext-skill-dynamic-context — A skill can inject command output before Claude ever sees it
<!-- n: 104; verified: 2.1.278 -->
A construct like !`gh pr diff` in SKILL.md runs when the skill is invoked, so Claude receives the actual data rather than the command. For several lines there is a fenced code block opened with three backticks and `!`. Important: a command with a non-zero exit code aborts the whole skill invocation — append `|| true` where a failure is acceptable.

**Try it:** add a line with !`git status --short` to one of your skills so it always sees the state of the tree.

## ext-skill-allowed-tools — allowed-tools spares a skill the permission prompts
<!-- n: 105; verified: 2.1.278 -->
The `allowed-tools` frontmatter field lets the listed tools run without asking during the turn that invokes the skill; the grant clears with your next message. `${CLAUDE_SKILL_DIR}` is substituted both in the body and in the rules: `allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/run.sh *)` — and a script from the skill's directory runs without a prompt.

**Try it:** add `allowed-tools` to a skill that keeps asking permission for the same commands.

## ext-skill-manual-only — disable-model-invocation removes a skill's description from the context
<!-- n: 106; verified: 2.1.278 -->
With `disable-model-invocation: true` only you can invoke the skill, through `/name` — and its description stops taking up context. It suits actions with side effects (deploy, commit, sending messages). The opposite is `user-invocable: false`: only Claude sees the skill, and it is absent from the `/` menu.

**Try it:** mark the skills you only ever run by hand.

## ext-skill-arguments — Skills take positional and named arguments
<!-- n: 107; verified: 2.1.278 -->
`$ARGUMENTS` is everything typed after the skill name; `$0`, `$1` are individual arguments (quotes join words into one). An `arguments: [issue, branch]` frontmatter field gives you named `$issue` and `$branch`, and `argument-hint: "[issue-number]"` shows a hint during autocomplete.

**Try it:** add `argument-hint` to a skill of yours that takes arguments.

## ext-skill-fork — context: fork runs a skill in a separate subagent
<!-- n: 108; verified: 2.1.278 -->
A skill with `context: fork` in its frontmatter runs in a forked subagent, and the `agent:` field picks the agent type, for example `Explore`. Read-heavy skills (a PR summary, an audit) don't clutter the main conversation — only the result comes back. By default such a skill runs in the background; `background: false` waits for the result in the same turn.

**Try it:** add `context: fork` to a skill that reads many files to produce a short answer.

## ext-skill-stack — Several skills can be invoked in one message
<!-- n: 109; verified: 2.1.278 -->
`/write-tests /fix-issue 123` loads both skills and passes the trailing `123` as `$ARGUMENTS` to each. The first skill plus up to five more are expanded; expansion stops at the first token that is not an inline skill (a forked skill such as `/code-review` stops it too).

**Try it:** invoke two of your skills back to back at the start of one message.

## ext-skill-model-effort — A skill can have its own model and effort
<!-- n: 110; verified: 2.1.278 -->
The `model:` and `effort:` frontmatter fields override the model and the reasoning level for the rest of the current turn; with your next prompt the session settings return. A routine skill (formatting, a summary, a reminder) has no business running on the most expensive model at maximum effort.

**Try it:** add `model: sonnet` and `effort: low` to a skill that does simple mechanical work.

## ext-skill-paths — paths limits when a skill activates on its own
<!-- n: 111; verified: 2.1.278 -->
The `paths` frontmatter field is a list of glob patterns: Claude loads the skill automatically only when working with matching files. The format is the same as for rules in `.claude/rules/`. It is the cure for a skill that triggers too often.

**Try it:** add `paths: ["**/*.tf"]` to a skill that only concerns Terraform.

## ext-subagent-mention — An @-mention guarantees that a specific subagent runs
<!-- n: 112; verified: 2.1.278 -->
Naming a subagent in the text is only a suggestion — the decision stays with Claude. Type `@` and pick the agent from the list (you get `@"code-reviewer (agent)" look at the auth changes`) and it is guaranteed to run. To make an agent the main one for a whole session: `claude --agent <name>`.

**Try it:** type `@` and see which agents are listed next to the files.

## ext-adversarial-review — Before calling it done, have a subagent review the diff in a fresh context
<!-- n: 113; verified: 2.1.278 -->
A reviewer subagent sees only the diff and your criteria, not the reasoning that produced the code — so it judges the result on its own terms. Name what to check, what to check it against (for example PLAN.md) and what counts as a finding. A reviewer asked to find gaps will always find some; to avoid over-engineering, ask only for what affects correctness and the stated requirements.

**Try it:** "Use a subagent: review the diff against PLAN.md, report only gaps in the requirements, not style".

## ext-mcp-debug — An MCP server is connected but offers no tools: what to check
<!-- n: 114; verified: 2.1.278 -->
`/mcp` shows the status of every server. The usual causes: a server from the project's `.mcp.json` never got its one-time approval; `command` or `args` contain relative paths (they resolve against the directory Claude Code was launched from, not the location of `.mcp.json`); the server started but returned zero tools — Reconnect helps. Next step: `claude --debug=mcp` and the log under `~/.claude/debug/`.

**Try it:** `/mcp` — make sure every server is connected and lists a non-zero number of tools.

## ext-subagent-haiku — A cheap model is enough for simple subagents
<!-- n: 115; verified: 2.1.278 -->
A subagent's definition can set its model: for simple tasks — searching, mechanical checks — `model: haiku` is noticeably cheaper and faster, and the strong model stays with the main conversation.

**Try it:** check the `model` field in your subagent definitions (`~/.claude/agents/`, `.claude/agents/`).
