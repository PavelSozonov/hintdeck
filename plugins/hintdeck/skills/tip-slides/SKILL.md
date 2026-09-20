---
name: tip-slides
description: Use when the user wants a Claude Code tip presented as slides or visually — "/tip-slides", "tip of the day as slides", "show me a tip visually", "make slides for tip #42", "совет дня слайдами", "/tip-slides <topic>", "/tip-slides 42"
argument-hint: "[topic | tip number]"
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/tip.sh *)
---

# tip-slides — tip of the day as a slide deck

## Overview

The same tip the `tip` skill gives (shared catalog, shared shown history, shared numbers), laid
out as a deck of one or more slides. The guiding principle: **every slide and every visual element
answers a specific question the reader has.** A slide that answers no question is not made; a
visual without which the tip is understood just as fast is not drawn.

Facts come only from the tip text that `tip.sh` printed. A diagram or a table must not contain
keys, commands, flags or steps that are not in the tip.

## State at invocation

```!
${CLAUDE_SKILL_DIR}/tip.sh list
```

Invocation argument: "$ARGUMENTS"

If the state block above is missing, run `${CLAUDE_SKILL_DIR}/tip.sh list` yourself.

## Steps

1. **Get the tip** — one per invocation:
   - the argument is a number → `${CLAUDE_SKILL_DIR}/tip.sh show <number> <ticket>` (an already
     shown tip is fine);
   - otherwise choose an id from the unseen list (the topic from the argument; with no argument,
     what is useful for the current session; in an empty session, a topic that is not in the
     "recently shown" line) and run `${CLAUDE_SKILL_DIR}/tip.sh take <id> <ticket>`;
   - `EXHAUSTED` → say there are no unseen tips left and suggest `/tip refresh`.
2. **Plan the deck** with "How many slides" and "Does it need a visual" — before creating anything.
3. **Build the deck** — section "Publishing".
4. **Reply** — section "Reply format".

Everything the reader sees — slide text, labels, the reply — is in the language of the `lang:`
line (`reply-lang` in the `take` output); see "Language" in the `tip` skill for the labels and for
the one-time language offer.

## How many slides

The content of the tip decides the number of slides, not a wish to "make a presentation":

| What the tip contains | Slides |
|---|---|
| One fact or one action (a key, a command, a setting) | 1 |
| A fact plus a mechanism to understand (order of events, what goes where) | 2: the point → how it works |
| A choice between options or modes | 2–3: the point → comparison → when to pick which |
| A procedure of several steps | 2–4: the point → steps (a slide per meaningful stage, not per line) |

The upper bound is 5. The first slide is always `#<number> · <title as a statement>` with the point
in one or two sentences. The last content element of the deck is always the "try it now" block
with the exact action; in a one-slide deck it sits on that slide. Every slide title is a statement,
not a heading ("`Ctrl+S` stashes the prompt and brings it back", not "Description").

## Does it need a visual

For each slide ask the questions in the left column. A "yes" → the matching form. No "yes" at all
→ a text slide, and that is a perfectly good result.

| Question about the slide's content | Form | What it must show |
|---|---|---|
| Does the reader have to press specific keys? | Keys as keycaps, in the order pressed | The exact combination and sequence |
| Does the reader type a command or need to see its result? | A terminal block with the exact command | What to type; output only if the tip describes it |
| Does the order of events or the path of data matter? | A linear left-to-right flow | The stages and what happens at each, forks included |
| Are 2–4 options compared on shared attributes? | A comparison table | Attributes in rows, options in columns, differences visible without reading paragraphs |
| Is there nesting, levels or precedence? | A layered diagram (general → specific, weak → strong) | Who overrides whom, and in which order |
| Is there a "before → after"? | Two columns | The same structure left and right, the difference highlighted |
| Are there numeric thresholds or limits? | A scale with marks | The tip's values, to scale |

The control question for every visual: "would the reader understand the tip just as fast without
it?" If yes, remove it. Icons, illustrations, emoji and background effects always answer "yes".

Color carries meaning (the difference, the current state) rather than decoration: one accent color
per deck. Commands and keys are set in a monospace face.

## Series look

Every deck looks like part of one series and is built for a dark theme — the look is not
reinvented each time:

| Role | Value |
|---|---|
| Slide background / panel / line | `#161618` / `#232328` / `#3a3a40` |
| Text / muted text | `#f1efe9` / `#a09b91` |
| Accent (the only one) / "try it now" block | `#6ea0ff` / background `#1d2740` with an accent left border |
| Typefaces | `IBM Plex Sans` (text and headings) + `JetBrains Mono` (keys, commands); both cover Cyrillic |
| Sizes on the 1920×1080 canvas | 76 (tip title) · 56 (slide title) · 36 (the point) · 30 (body) · 24 (labels, the minimum) |
| Keycap | a painted block: panel background, 2px line border, thicker bottom border, rounded, bold monospace |
| Footer line | `Tip of the day #<number> · <topic>` (translated to the reply language), size 24, muted |

The Slides artifact type accepts only fixed hex colors, so the palette there is always dark. The
HTML template of the fallback path switches between light and dark with the system theme — leave
its tokens alone.

## Publishing

1. The main path is the `Artifact` tool: call `action: "quickstart"` with `intent: "slides"`,
   create an artifact from the Slides type it names, titled `Tip #<number> — <short title>` (in the
   reply language), and fill it strictly by the instructions that creating the type returns. Do not
   ask for a design system — "Series look" replaces it. Build diagrams by the type's own references
   (`artifact-type/reference/diagrams.md`, and `diagram-recipes.md` when needed): boxes and labels
   are separate `<p>` elements with exact coordinates inside one host, lines are `<x-connector>`,
   there is no text inside `<svg>`; a `<span>` can change color only, so a keycap is its own
   painted `<p>`, never a fragment of a line.
2. When the session has no `Artifact` tool (as in `claude -p`), copy
   `${CLAUDE_SKILL_DIR}/deck-template.html` to `<slides dir>/<number>-<id>.html`, where
   `${CLAUDE_SKILL_DIR}/tip.sh slides-dir` prints the slides directory, and fill it in: keep the
   styles, color tokens and navigation script as they are and use the ready-made classes (`.keys`,
   `.term`, `table`, `.cols`, `.diagram`, `.try`), so that all decks look like one series. Check
   each slide with a screenshot (a `#2` in the address opens the second slide), then open the file
   with `open`. For a complex diagram in HTML load the `artifact-diagramming` skill, for a numeric
   scale `dataviz`.

The tip is already marked as shown in step 1; if publishing fails, say so and name the number so
the deck can be rebuilt with `/tip-slides <number>`.

## Reply format

Brief, in the reply language, in this order:

1. The title: `**Tip of the day #<number>: <title>**`.
2. One or two sentences with the point.
3. `**Try it now:**` the action from the tip, with real names from the current project when you
   know them. Claim only what you verified about the user's settings and files, and do not
   suggest setting up something they already have.
4. The link to the deck (or the file path) and the number of slides.
5. A `Visuals:` line — one item per visual element: its form and which question from the table it
   answers; or "none — the tip is a single fact, a diagram would add nothing".
6. The footer in italics: `<topic> · #<number> · shown N of M`.

## Common mistakes

| Mistake | Instead |
|---|---|
| Splitting a short tip into 4 slides "to look solid" | One fact, one slide |
| A diagram that repeats the slide's text in boxes | A diagram earns its place by showing order, a fork or nesting the text does not show |
| Adding a step or a key to a diagram "for completeness" | Only what the tip's text contains |
| A title slide, a "Thank you" slide, a table of contents | There are none: the first slide already carries the point |
| Two tips in one deck | One invocation, one tip |
