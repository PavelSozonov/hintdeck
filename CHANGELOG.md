# Changelog

Versions follow [semantic versioning](https://semver.org). The version lives in
`plugins/hintdeck/.claude-plugin/plugin.json`; installed users receive an update only when it changes.

## [Unreleased]

Changes merged with the `skip-release` label are collected here until the next version bump.

## [0.1.3] - 2026-10-14

### Changed
- The plugin folder is now self-contained for the Claude plugin directory, which reads nothing
  outside it: it carries its own `README.md` (generated from the repository README), a `LICENSE`
  and the demo images in `assets/`.
- `tip-slides` ships an identical copy of `tip.sh` instead of a wrapper that ran the `tip` skill's
  script, so that no script runs another file. Behaviour is unchanged.
- The README states what the plugin runs, reads, writes and fetches.

## [0.1.2] - 2026-10-14

### Security
- `tip.sh take` and `show` removed `<tickets>/<ticket>` without checking the ticket, so a ticket
  such as `../../file` deleted any file the user could write. A ticket must now have the exact form
  `list` issues (`t` followed by digits), and it is removed only when it is a regular file, not a
  symlink, whose canonical directory is the tickets directory; tickets are created without
  following an existing file or symlink.
- A language code from `/tip lang`, `HINTDECK_LANG`, the saved choice or a project's `language`
  setting, and the `HINTDECK_DECK` name, may no longer contain a path: `..` or `/` made the script
  read tips from, and keep state in, directories outside its own.

### Added
- Smoke tests for path traversal through tickets, language codes and deck names.

## [0.1.1] - 2026-09-21

### Changed
- `tip.sh lint` exits non-zero when the catalog is broken, and `lint --strict` also fails on tips
  that have no translation. It also checks that `.last-number` is not behind the numbers in use.
- The version the catalog was verified against ships with the catalog
  (`decks/<deck>/.verified-version`) instead of living in the user's state, so a fresh install
  knows when the CLI has moved past the catalog.
- Reply rules: check the user's settings before suggesting that they set something up.

### Added
- Pre-commit hooks, a CI pipeline and release checks (permanent numbers, version bump, changelog).
- `SECURITY.md`, and troubleshooting, privacy and support sections in the README.

## [0.1.0] - 2026-09-20

### Added
- `tip`: one doc-verified tip per call, never repeated, picked for the current session, with
  permanent numbers (`/tip 42`), history and a changelog-driven `refresh`.
- `tip-slides`: the same tip as a deck of one to five slides with purposeful visuals.
- A catalog of 147 tips verified against Claude Code 2.1.278, in English and Russian; the tip
  language resolves from `HINTDECK_LANG`, `/tip lang`, Claude Code's `language` setting, then English.
