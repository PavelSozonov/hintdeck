<!-- The title becomes the squash commit subject: <type>(<scope>): <subject> -->

## What and why

## Checklist

- [ ] `pre-commit run --all-files` and `tests/smoke.sh` pass
- [ ] Changes under `plugins/hintdeck/` bump `version` in `plugin.json` and add a `CHANGELOG.md` entry
- [ ] New or changed tips link their primary source, and every translation is updated
- [ ] Numbers were issued by `tip.sh number`, not written by hand
