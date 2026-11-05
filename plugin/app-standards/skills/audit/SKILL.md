---
name: audit
description: Audits an existing application against the app-standards rules and produces a findings report ordered by severity, without changing any files.
argument-hint: "[folder to audit]"
disable-model-invocation: true
---

# Standards Audit

Review a project against the app-standards rules and report what breaks them. This command only reports. Fix nothing unless the user asks afterward.

## 1. Set the target
- Audit the folder in `$ARGUMENTS` if given, otherwise the current project root.
- Read `.app-standards.json` if it exists. If it doesn't, infer the applicability tags from the code (sign-in code means Accounts, a payment SDK means Payments, and so on), say which tags you inferred, and suggest running `/app-standards:new-app` afterward to record them.

## 2. Run the review
Delegate the review to the `standards-reviewer` agent. Give it:
- The target folder.
- The applicability tags and any approved exceptions from the project file.
- The standards skill directory: `${CLAUDE_PLUGIN_ROOT}/skills/standards`
- The lint script path: `${CLAUDE_PLUGIN_ROOT}/hooks/scripts/lint.js`

If agents are not available in this environment, load the `standards` skill and run `${CLAUDE_PLUGIN_ROOT}/skills/standards/references/verification-checklist.md` yourself, and say in the report that the review was not independent.

## 3. Report
Present the reviewer's findings in this format:

**Summary:** the number of findings at each severity, the tags audited, and whether the review was independent.

**Findings,** grouped by severity, then by skill section:
- **Critical:** security or privacy exposure, data loss, payments.
- **High:** accessibility blockers, legal requirements, broken functionality or links.
- **Medium:** rule violations users can see (design, writing, layout).
- **Low:** polish and consistency.

For each finding: the file and line, the rule broken (with its section number), why it matters in one sentence, and the fix.

**Approved exceptions:** listed separately, not counted as findings.

**Unverified checks:** every check that could not be run, and why.

Then ask whether the user wants the findings fixed, and in what order.
