---
name: audit
description: Audits an existing application against the app-standards rules, saves the findings with evidence for later fixing, and reports them by severity without changing any project files.
argument-hint: "[folder to audit]"
disable-model-invocation: true
---

# Standards Audit

Load the `standards` skill from this plugin, then read `${CLAUDE_PLUGIN_ROOT}/skills/standards/references/audit-and-fix.md` and run **Stage 1: Audit** only.

- Audit the folder in `$ARGUMENTS` if given, otherwise the current project root.
- In agent mode, give the `standards-reviewer` agent the target folder, the tags and exceptions, the skill directory `${CLAUDE_PLUGIN_ROOT}/skills/standards`, and audit mode.
- Run the reviewer in the foreground and wait for its result.
- In chat mode, run `${CLAUDE_PLUGIN_ROOT}/skills/standards/scripts/lint.js --scan <folder>` and work through the verification checklist yourself.
- Save the findings to `.app-standards/audit.json`. That file, and adding `.app-standards/` to `.gitignore`, are the only changes this command makes.

Then report:

**Summary:** findings per severity, tags audited, and whether the audit was independent.

**Findings,** grouped by severity, then by skill section. For each: its ID, the file and line, the rule broken (with its section number), why it matters in one sentence, and the fix.

**Approved exceptions:** listed separately, not counted as findings.

**Unverified checks:** every check that could not be run, and why.

End by telling the user that `/app-standards:fix` will fix these in phases, asking any needed decisions first.
