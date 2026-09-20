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

## Catalog

- `decks/<deck>/en/` is canonical: it owns ids, numbers (`n`) and metadata. Every change to an
  English tip is mirrored in every translation in the same commit.
- Never write or change `n` by hand, and never reuse a number: run `tip.sh number`.
- A tip needs a primary source (official docs, changelog, `claude --help`) and a `verified:` version.

## Before committing

```bash
plugins/hintdeck/skills/tip/tip.sh lint
claude plugin validate .
```

State (`~/.claude/hintdeck/`) is never committed.
