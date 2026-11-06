---
name: fix
description: Finds and fixes app-standards violations in phases, auditing first if needed, with every judgment call asked up front, every fix verified against saved findings, and the findings file removed once everything is resolved.
argument-hint: "[next | status | clear | phase <id> | critical | high | medium | low | section <number>]"
disable-model-invocation: true
---

# Standards Fix

Load the `standards` skill from this plugin, then read and follow `${CLAUDE_PLUGIN_ROOT}/skills/standards/references/audit-and-fix.md` exactly.

- The arguments are `$ARGUMENTS`. Match them to the Command Arguments table in that file. With no arguments, run the whole procedure: audit if needed, plan, then fix.
- When the procedure says to run the lint script, use `${CLAUDE_PLUGIN_ROOT}/skills/standards/scripts/lint.js`.
- When passing this skill's directory to an agent, use `${CLAUDE_PLUGIN_ROOT}/skills/standards`.
- Run every agent in the foreground and wait for it. In agent mode, keep going until every pending phase is done or blocked before ending the turn.
- `status` only reads `.app-standards/audit.json` and reports progress. It changes nothing.
- `clear` deletes `.app-standards/audit.json`. If findings are still open, say how many and confirm with the user first.
- After the final report, always run the cleanup stage.
