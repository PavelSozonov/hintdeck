# Changelog

Versions follow [semantic versioning](https://semver.org). The version lives in
`plugins/hintdeck/.claude-plugin/plugin.json`; installed users receive an update only when it changes.

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
