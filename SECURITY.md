# Security policy

## Reporting a vulnerability

Please report security issues privately through GitHub:
**[Report a vulnerability](https://github.com/PavelSozonov/hintdeck/security/advisories/new)**
(the repository's *Security* tab → *Report a vulnerability*).

Do not open a public issue for a vulnerability. You can expect an acknowledgement within a few
days; fixes are released as a new plugin version and noted in the advisory.

## Scope and what the plugin does

hintdeck is two skills and one bash script (`plugins/hintdeck/skills/tip/tip.sh`). It ships no MCP
servers, hooks, binaries or background processes.

- **Files it writes:** only its own state under `~/.claude/hintdeck/` (or `HINTDECK_STATE_DIR`):
  the shown history, the chosen tip language, single-use tickets and locally generated slide decks.
- **Files it reads:** the tip catalog in the plugin directory, and — to skip tips about features
  you already use — the presence of a few keys in your Claude Code `settings.json` and of files
  such as `keybindings.json`, `CLAUDE.md`, `.mcp.json`. Their contents are not stored or sent anywhere.
- **Network:** none during normal use. Only `/tip refresh` downloads the public Claude Code
  changelog and documentation from `code.claude.com`, at the user's request.
- **Data collection:** none. There is no telemetry and no remote service.
