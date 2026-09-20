# practices — ways of working

## prac-verification — Give Claude a check it can run by itself
<!-- n: 129; verified: 2.1.278 -->
Claude stops when the work looks done. Without a runnable check that is the only signal it has, and you become the verification loop. Give it something that returns pass or fail — tests, a build, a linter, a script that diffs against a fixture, a screenshot against a design — and the loop "do → check → fix" closes without you. It is the difference between a session you watch and one you can walk away from.

**Try it:** add to your next task: "after implementing, run <command> and iterate until it passes".

## prac-evidence — Ask for evidence, not assertions
<!-- n: 130; verified: 2.1.278 -->
Instead of "everything works", ask Claude to show it: the test output, the command it ran and what it returned, a screenshot. Reviewing evidence is faster than re-running the verification yourself, and it works for sessions you were not watching.

**Try it:** end a prompt with "finally, show the verification command and its full output".

## prac-explore-plan-code — Research and plan first, code second
<!-- n: 131; verified: 2.1.278 -->
Separate research and planning from implementation — that way you don't end up solving the wrong problem. In plan mode Claude reads the code and proposes a plan without changing anything; you adjust the plan until it suits you, and only then give the go-ahead. A wrong approach is cheaper to catch in a plan than in dozens of changed files.

**Try it:** start your next task that spans more than one file with `/plan <description>`.

## prac-interview — For a large feature, let Claude interview you first
<!-- n: 132; verified: 2.1.278 -->
Start with a brief description and ask: "Interview me in detail using the AskUserQuestion tool… then write a complete spec to SPEC.md". Claude asks about what you had not considered: implementation, edge cases, tradeoffs. When the spec is ready, start a fresh session to implement it: clean context plus a written specification.

**Try it:** "I want to build <feature>. Interview me in detail using AskUserQuestion, skip the obvious questions, and at the end write the spec to SPEC.md".

## prac-self-contained-spec — A good spec is self-contained and ends with a verification step
<!-- n: 133; verified: 2.1.278 -->
A useful specification names the files and interfaces involved, states plainly what is out of scope, and ends with an end-to-end verification step that proves the feature works. Time spent making the spec precise pays off more than time spent watching the implementation.

**Try it:** add "Out of scope" and "How to verify end to end" sections to your task template.

## prac-specific-prompts — Put the verification criteria right in the prompt
<!-- n: 134; verified: 2.1.278 -->
Compare "write an email validation function" with "write validateEmail; examples: user@example.com is true, invalid is false, user@.com is false; run the tests after implementing". For bugs — the full error text and the demand "fix the root cause, don't suppress the error". Being specific saves iterations and tokens.

**Try it:** in your next bug prompt paste the exact error text and add "address the root cause and confirm the build succeeds".

## prac-course-correct — Correct early: Esc interrupts without losing context
<!-- n: 135; verified: 2.1.278 -->
The best results come from tight feedback loops. When you see Claude going the wrong way, press `Esc`: the action stops, the work done so far is kept, the context stays, and you can redirect. Waiting for the turn to end and then rewinding costs more.

**Try it:** at the first sign of a wrong direction press `Esc` and redirect in one sentence.

## prac-rich-context — Give material, not a retelling
<!-- n: 136; verified: 2.1.278 -->
Reference files with `@` instead of describing where the code lives — Claude reads the file before replying. Paste screenshots, give documentation URLs (frequently used domains can be allowlisted through `/permissions`), pipe data in. Or simply tell Claude to fetch the context itself with commands.

**Try it:** instead of "in the file with the logger settings" write `@src/logging/config.py`.

## prac-keep-running — /goal, /loop or a Stop hook: choosing what keeps the work going
<!-- n: 137; verified: 2.1.278 -->
Three ways to keep a session from stopping differ in what starts the next turn. `/goal` — a separate model checks the condition after every turn; it lasts one session. `/loop` — the next turn starts on a timer. A `Stop` hook — your script decides deterministically and lives in the settings for every session. Auto mode alone only removes prompts within a turn and never starts a new one — it and `/goal` complement each other.

**Try it:** for "get the tests green" use `/goal`; for "watch the deploy" use `/loop`.
