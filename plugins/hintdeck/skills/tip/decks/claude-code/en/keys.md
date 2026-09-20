# keys — keyboard shortcuts and input

## keys-stash-prompt — Ctrl+S stashes a half-written prompt
<!-- n: 1; verified: 2.1.278 -->
You are writing a long prompt and suddenly need to ask something else — don't delete what you typed. `Ctrl+S` puts the text aside and clears the input; pressing `Ctrl+S` again on an empty prompt brings it back together with the cursor position and any pasted content.

**Try it:** type a few words, press `Ctrl+S`, send a different question, then press `Ctrl+S` again.

## keys-external-editor — Ctrl+G opens the prompt in your own editor
<!-- n: 2; verified: 2.1.278 -->
`Ctrl+G` (or the readline binding `Ctrl+X Ctrl+E`) opens the current prompt in your default editor — handy for long task descriptions. If you turn on "Show last response in external editor" in `/config`, Claude's previous reply appears above the prompt as `#` comments; the block is stripped when you save.

**Try it:** press `Ctrl+G`, write a multi-line task, save and close the editor.

## keys-double-esc-draft — Esc Esc clears the input without losing it
<!-- n: 3; verified: 2.1.278 -->
Double `Esc` behaves differently depending on the input. With text in the prompt it clears the text and saves it to history, so `Up` brings it back. With an empty prompt it opens the rewind menu (`/rewind`). So "the rewind menu did not open" usually means there was still text in the input.

**Try it:** type something, press `Esc Esc`, then `Up`.

## keys-history-search — Ctrl+R searches your prompt history, including other projects
<!-- n: 4; needs: fullscreen; verified: 2.1.278 -->
`Ctrl+R` opens a search over the prompts you have typed. In the fullscreen renderer it is a dialog: type to filter, `Up`/`Down` move through matches, and `Ctrl+S` cycles the scope — this session, this project, all projects. `Enter` or `Tab` places the match in the input.

**Try it:** press `Ctrl+R`, type a word from a prompt you wrote in another project, and press `Ctrl+S` twice.

## keys-kill-ring — Deleted text can be pasted back with Ctrl+Y
<!-- n: 5; verified: 2.1.278 -->
`Ctrl+K` (to end of line), `Ctrl+U` (to start of line) and `Ctrl+W` (back to whitespace) don't just delete text, they store it. `Ctrl+Y` pastes the last deletion, and `Alt+Y` right after pasting cycles through earlier deletions (on macOS `Alt+Y` needs "Option as Meta" in your terminal).

**Try it:** type a phrase, cut it with `Ctrl+U`, type something else and bring the cut text back with `Ctrl+Y`.

## keys-ctrl-w-path — Ctrl+W deletes a whole path, Option+Delete goes word by word
<!-- n: 6; needs: macos; verified: 2.1.278 -->
`Ctrl+W` ignores punctuation and deletes back to whitespace: one press removes all of `src/utils/foo.ts` or `--flag=value`. The word shortcuts (`Option+Delete`, `Alt+B`, `Alt+F`, `Alt+D`) treat a word as letters and digits only, so they stop at `/`, `.` and `_`. This is how it works from version 2.1.261.

**Try it:** type a file path and compare one `Ctrl+W` with several presses of `Option+Delete`.

## keys-undo-input — Ctrl+_ undoes the last edit in the input
<!-- n: 7; verified: 2.1.278 -->
Deleted part of your prompt by accident, or pasted the wrong thing? `Ctrl+_` (also `Ctrl+Shift+-`) restores the previous text together with the cursor position.

**Try it:** type a phrase, delete a word with `Ctrl+W` and press `Ctrl+_`.

## keys-multiline — A newline without any terminal setup: Ctrl+J
<!-- n: 8; verified: 2.1.278 -->
`Ctrl+J` inserts a line break in any terminal with no configuration; so does `\` followed by `Enter`. `Shift+Enter` works out of the box in iTerm2, WezTerm, Ghostty, Kitty, Warp, Apple Terminal and Windows Terminal, and `/terminal-setup` enables it for VS Code, Cursor, Alacritty and Zed.

**Try it:** type a line, press `Ctrl+J`, and continue on the second line.

## keys-paste-image — An image from the clipboard can be pasted straight into the prompt
<!-- n: 9; verified: 2.1.278 -->
`Ctrl+V` (also `Cmd+V` in iTerm2) pastes an image from the clipboard and puts an `[Image #N]` chip in the input that you can refer to by position. A screenshot of an error or a mockup often explains the task better than a paragraph of description.

**Try it:** take a screenshot to the clipboard (`Cmd+Ctrl+Shift+4`), press `Ctrl+V` and add "what is wrong in [Image #1]?".

## keys-shell-mode — `!` runs a command directly, and Claude reacts to its output right away
<!-- n: 10; verified: 2.1.278 -->
Input that starts with `!` runs as a shell command directly, without the model interpreting or approving it; the command and its output land in the context. Claude responds to the output automatically — `! npm test` gets you an explanation of the failures without a second prompt. `Tab` completes from earlier `!` commands in the project. If you don't want the automatic response, set `"respondToBashCommands": false` in `settings.json`.

**Try it:** `! git status` — and see what Claude says about the state of the branch.

## keys-queue-messages — You can queue messages while Claude is working
<!-- n: 11; verified: 2.1.278 -->
Pressing `Enter` while Claude works does not interrupt the turn, it queues the message. A regular message reaches the model as soon as the current tool calls finish — within the same turn; slash and `!` commands wait for the turn to end. Changed your mind? `Up` from the first line of the input takes the queue back into the input for editing.

**Try it:** during a long task type a clarification and press `Enter`, then `Up` to take it back.

## keys-permission-comment — Tab lets you explain a denial in a permission prompt
<!-- n: 12; skip-if: auto-mode; verified: 2.1.278 -->
On a permission prompt, move to **Yes** or **No** and press `Tab` to open a comment field. "No" with a comment sends the model the reason, and it keeps working with your note in mind; "No" without a comment in the main conversation simply stops the turn. "Yes" with a comment runs the action and passes the note along after the result.

**Try it:** on the next prompt pick No, press `Tab` and write how to do it differently.

## keys-shift-tab-modes — Shift+Tab cycles through the permission modes
<!-- n: 13; verified: 2.1.278 -->
`Shift+Tab` goes round: `default` (shown as Manual in the mode indicator) → `acceptEdits` → `plan` → and, when available, `bypassPermissions` and `auto`. From `auto` the first press returns to `default`. To start in a given mode use the flag: `claude --permission-mode plan`.

**Try it:** before a non-trivial task press `Shift+Tab` until you reach plan, and ask for a plan first.

## keys-model-switch — Option+P switches the model without clearing your prompt
<!-- n: 14; needs: macos; verified: 2.1.278 -->
`Option+P` opens the model picker on top of the text you have typed, and `Option+O` toggles fast mode. If the shortcut types a character instead of acting, your terminal does not have "Option as Meta" enabled (the terminal-config docs page has an "Enable Option key shortcuts on macOS" section for each terminal).

**Try it:** type a prompt, press `Option+P`, pick a lighter model for a routine task and send.

## keys-transcript-search — Ctrl+O opens a transcript you can search like less
<!-- n: 15; needs: fullscreen; verified: 2.1.278 -->
`Ctrl+O` shows the detailed transcript: tool calls, plus a timestamp and the model on every reply. In fullscreen it has navigation: `/` searches, `n`/`N` jump to the next and previous match, `{`/`}` jump between your prompts, `g`/`G` go to the top and bottom. `[` writes the conversation into the terminal's native scrollback (so `Cmd+F` works), and `v` opens it in `$EDITOR`.

**Try it:** `Ctrl+O`, then `/` and a word from an old reply; `q` exits.

## keys-background-ctrl-b — Ctrl+B sends a long-running command to the background
<!-- n: 16; verified: 2.1.278 -->
When Claude has started a long Bash command or an agent, `Ctrl+B` moves it to the background — the conversation goes on, and the output is written to a file Claude reads later. In tmux press it twice (it is the tmux prefix). The same works for commands started with `!`. `/tasks` lists background work.

**Try it:** `! sleep 60`, press `Ctrl+B` and open `/tasks`.

## keys-mouse-fullscreen — In fullscreen the mouse expands tool output and opens files
<!-- n: 17; needs: fullscreen; verified: 2.1.278 -->
In the fullscreen renderer a click on a collapsed tool result expands it, a click in the input places the cursor, and `Cmd`-click on a URL or a file path opens it. Text you select with the mouse is copied on release. For your terminal's native selection hold `Option` in iTerm2, `Fn` in Terminal.app, `Shift` in most others.

**Try it:** click the collapsed output of any command, then `Cmd`-click a file path printed after an edit.

## keys-help-panel — `?` on an empty prompt shows every keyboard shortcut
<!-- n: 18; verified: 2.1.278 -->
Typing `?` into an empty input opens the shortcut help panel; in the transcript viewer (`Ctrl+O`) in fullscreen it shows the shortcuts for that mode. It is the quickest way to check which key does what in your exact version.

**Try it:** clear the input and press `?`.

## keys-suspend — Ctrl+Z suspends Claude Code, fg brings it back
<!-- n: 19; verified: 2.1.278 -->
On macOS and Linux `Ctrl+Z` suspends the process and hands you the shell — you can run something quickly in the same terminal and return with `fg` without losing the session.

**Try it:** `Ctrl+Z`, run `git log -3 --oneline`, then `fg`.

## keys-prompt-suggestions — Tab accepts the greyed-out suggestion for your next prompt
<!-- n: 20; verified: 2.1.278 -->
After a reply Claude Code may show a suggested next prompt in grey. `Tab` or `Right` places it in the input, `Enter` sends it; start typing and it disappears. Suggestions reuse the warm prompt cache, so they cost very little. Turn them off in `/config` (Prompt suggestions).

**Try it:** look for the grey suggestion after the next reply and press `Tab`.

## keys-stop-agents — Ctrl+X Ctrl+K stops every background subagent
<!-- n: 21; verified: 2.1.278 -->
If a session has spawned background subagents you no longer need, `Ctrl+X Ctrl+K` stops them all at once; press it twice within three seconds to confirm. It also turns off artifact auto-replies for the rest of the session.

**Try it:** remember this one for the day `/tasks` shows more agents than you expected.

## keys-todo-toggle — Ctrl+T shows Claude's task checklist
<!-- n: 22; verified: 2.1.278 -->
`Ctrl+T` shows and hides the checklist Claude keeps for multi-step work (up to five items at a time); it survives context compaction. It is not the background-task list — that is `/tasks`. One catch: the checklist tools are not given to every model by default, and on the others the list stays empty until you set `CLAUDE_CODE_ENABLE_TODO_TOOLS=1`.

**Try it:** press `Ctrl+T` on a multi-step task; if it is empty, restart with `CLAUDE_CODE_ENABLE_TODO_TOOLS=1 claude`.
