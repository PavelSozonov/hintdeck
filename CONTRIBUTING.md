# Contributing

Thanks for helping. New tips, corrections and translations are all welcome.

## How changes reach users

- **`main` is the release branch.** The Claude plugin directory mirrors it automatically, and every
  `/plugin marketplace add PavelSozonov/hintdeck` install reads it. It is protected: no direct
  pushes, changes land through pull requests with green checks, history stays linear.
- **A release is a version bump.** `plugins/hintdeck/.claude-plugin/plugin.json` sets an explicit
  `version`, and Claude Code offers an update only when that version changes. Until it is bumped,
  a change on `main` reaches new installs only.
- **Contributors do not bump the version.** Two pull requests bumping the same number would only
  conflict. A maintainer adds the `skip-release` label to your pull request, which turns the version
  check off, and later opens a release pull request that bumps the version and moves the collected
  notes in `CHANGELOG.md` from "Unreleased" to the new version (PATCH for fixes and catalog updates,
  MINOR for new features, MAJOR for breaking changes). Changes outside `plugins/hintdeck/` (README,
  CI, docs) never need a bump.

## Workflow

1. Branch from `main`: `git switch -c <type>/<short-topic>` — for example `feat/tips-2-1-290`.
2. Install the hooks once per clone: `pre-commit install` (needs [pre-commit](https://pre-commit.com)).
3. Make the change. Commit as you like: pull requests are squash-merged, so your individual commits
   do not reach `main`. (If you installed the hooks, the local `commit-msg` hook still asks for
   [Conventional Commits](https://www.conventionalcommits.org); `git commit --no-verify` skips it.)
4. Open a pull request. Its **title** becomes the commit subject on `main` and its **description**
   becomes the commit body, so CI checks both: the title is `<type>(<scope>): <subject>`, the
   description is plain English prose that says what changes and why — no headings, checklists or
   attribution lines.
5. A maintainer merges with "Squash and merge" once the checks are green.

If you use the skills from a clone through symlinks (`~/.claude/skills/tip -> <clone>/…`), keep
that clone on `main` and develop in a separate worktree, otherwise your own `/tip` runs unreleased
code: `git worktree add ../hintdeck-dev -b <branch> origin/main`.

## Checks

| Check | Locally | In CI |
|---|---|---|
| Whitespace, JSON/YAML, large files, shellcheck | pre-commit | `lint` |
| Catalog: unique ids and numbers, translations in sync (`tip.sh lint --strict`) | pre-commit | `lint` |
| Language policy: English outside the translated catalogs | pre-commit | `lint` |
| Commit subject and body | commit-msg hook (optional) | `release-rules`: the pull request title and description |
| `tests/smoke.sh`: one tip per call, no repeats, numbers, languages, filters | pre-push hook | `smoke` on Ubuntu (gawk and mawk) and macOS (BWK awk, bash 3.2) |
| `claude plugin validate` for the marketplace and the plugin | `claude plugin validate .` | `plugin-validate` |
| Permanent numbers; version bump and changelog entry unless labelled `skip-release` | `scripts/check-release.sh origin/main` | `release-rules` |

Run everything by hand with `pre-commit run --all-files && tests/smoke.sh`.

## Adding or changing a tip

The format and the rules are in [`REFRESH.md`](plugins/hintdeck/skills/tip/REFRESH.md). In short:

- `decks/<deck>/en/` is canonical. Write the tip there, then add the translation with the same id
  and metadata to every other language directory in the same pull request.
- Never write or change `n` by hand, and never reuse a number — people refer to tips by number.
  Run `plugins/hintdeck/skills/tip/tip.sh number`; CI checks that numbers are stable.
- Link the primary source (official docs, changelog, `claude --help`) in the pull request. Tips
  without one are not accepted.

## Adding a language

Create `decks/<deck>/<lang>/` with the same file names and translate as much as you like:
untranslated tips fall back to English at run time. Note that `lint --strict` requires every tip
to be translated, so a partial language needs a follow-up change to the check before it can merge.
Also teach `normalize_lang` in `tip.sh` the names of the language, and add its reply labels to the
"Language" table in the `tip` skill.

## The demo in the README

`docs/demo/tip.gif` is a recording of a real session. `docs/demo/make-gif.sh` re-records it on an
isolated state; review every frame for personal details before committing a new recording.
