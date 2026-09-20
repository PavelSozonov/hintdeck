# hintdeck — repository rules

This is a public repository.

## Language

- English everywhere: documentation, README, code comments, script messages, commit messages,
  pull requests and issues.
- The only non-English content is the translated tip catalogs under
  `plugins/hintdeck/skills/tip/decks/<deck>/<lang>/` for `<lang>` other than `en`, plus the few
  localized reply labels quoted in the skills.

## Commits

- Conventional Commits: `<type>(<scope>): <subject>`, with an English body that explains what
  changed and why. No `Co-Authored-By` or other trailers.

## Branches and releases

- `main` is the release branch: the Claude plugin directory mirrors it and installs read it. It is
  protected — never commit or push to it directly. Work on a branch, open a pull request, merge by
  squash once CI is green.
- The clone that the personal `/tip` symlinks point to stays on `main`; develop in a separate
  worktree (`git worktree add ../hintdeck-dev -b <branch> origin/main`).
- A release is a version bump: installed users receive a change under `plugins/hintdeck/` only when
  `version` in `plugins/hintdeck/.claude-plugin/plugin.json` changes. A maintainer's own change bumps
  it and adds a `CHANGELOG.md` entry; a contributor's pull request gets the `skip-release` label
  instead, and a later release pull request bumps the version and turns "Unreleased" into that version.
- Pull requests are squash-merged: the title becomes the commit subject and the description becomes
  the commit body, so write the description as a commit message — plain prose, no headings,
  checklists or attribution lines. CI checks both (`scripts/check-commit-msg.sh --pr`).

## Catalog

- `decks/<deck>/en/` is canonical: it owns ids, numbers (`n`) and metadata. Every change to an
  English tip is mirrored in every translation in the same commit.
- Never write or change `n` by hand, and never reuse a number: run `tip.sh number`.
- A tip needs a primary source (official docs, changelog, `claude --help`) and a `verified:` version.

## Before committing

```bash
pre-commit run --all-files   # whitespace, shellcheck, tip.sh lint --strict, language policy
tests/smoke.sh               # the guarantees of tip.sh
claude plugin validate .
```

State (`~/.claude/hintdeck/`) is never committed. The full workflow is in `CONTRIBUTING.md`.
