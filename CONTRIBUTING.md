# Contributing

Thanks for helping. New tips, corrections and translations are all welcome.

## How changes reach users

- **`main` is the release branch.** The Claude plugin directory mirrors it automatically, and every
  `/plugin marketplace add PavelSozonov/hintdeck` install reads it. It is protected: no direct
  pushes, changes land through pull requests with green checks, history stays linear.
- **A release is a version bump.** `plugins/hintdeck/.claude-plugin/plugin.json` sets an explicit
  `version`, and Claude Code offers an update only when that version changes. A change under
  `plugins/hintdeck/` that does not bump the version never reaches installed users, so CI rejects it.
  Bump PATCH for fixes and catalog updates, MINOR for new features, MAJOR for breaking changes, and
  add a `CHANGELOG.md` entry. Changes outside `plugins/hintdeck/` (README, CI, docs) need no bump.

## Workflow

1. Branch from `main`: `git switch -c <type>/<short-topic>` — for example `feat/tips-2-1-290`.
2. Install the hooks once per clone: `pre-commit install` (needs [pre-commit](https://pre-commit.com)).
3. Make the change. Commit messages follow [Conventional Commits](https://www.conventionalcommits.org):
   `<type>(<scope>): <subject>` with a body that explains what changed and why. English, no trailers.
4. Open a pull request. Its title becomes the squash commit subject, so it follows the same format.
5. Merge with "Squash and merge" once the checks are green.

If you use the skills from a clone through symlinks (`~/.claude/skills/tip -> <clone>/…`), keep
that clone on `main` and develop in a separate worktree, otherwise your own `/tip` runs unreleased
code: `git worktree add ../hintdeck-dev -b <branch> origin/main`.

## Checks

| Check | Locally | In CI |
|---|---|---|
| Whitespace, JSON/YAML, large files, shellcheck | pre-commit | `lint` |
| Catalog: unique ids and numbers, translations in sync (`tip.sh lint --strict`) | pre-commit | `lint` |
| Language policy: English outside the translated catalogs | pre-commit | `lint` |
| Commit message format | commit-msg hook | `release-rules` (also the pull request title) |
| `tests/smoke.sh`: one tip per call, no repeats, numbers, languages, filters | pre-push hook | `smoke` on Ubuntu (gawk and mawk) and macOS (BWK awk, bash 3.2) |
| `claude plugin validate` for the marketplace and the plugin | `claude plugin validate .` | `plugin-validate` |
| Permanent numbers, version bump, changelog entry | `scripts/check-release.sh origin/main` | `release-rules` |

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
