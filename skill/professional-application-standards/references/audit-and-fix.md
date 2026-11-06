# Audit and Fix

Read this before auditing a project or fixing audit findings. This one procedure serves every environment:
- The plugin's `/app-standards:audit` and `/app-standards:fix` commands run it.
- Without the plugin, run it when the user asks to audit, review, check or fix a project against these standards.

The procedure has three main stages: **audit**, **plan**, and **fix in phases**, followed by a final report and cleanup. The findings file is the source of truth throughout. Never work from memory of earlier messages when the file holds the answer.

## Choose the Mode

Check once, at the start:
- **Agent mode:** the `standards-reviewer` and `standards-fixer` agents are available (the app-standards plugin in Claude Code or Cowork). Each phase runs in a fresh fixer agent, and the reviewer verifies it.
- **Chat mode:** no agents are available (regular chat, or the standalone skill). Phases run in the conversation, one phase per turn, verified with the lint script and a rule re-check.

Tell the user which mode is running, in one line.

## The Findings File

All audit and fix state lives in `.app-standards/audit.json` in the project root.
- Create the `.app-standards/` folder if needed, and add `.app-standards/` to the project's `.gitignore` (create the file if it doesn't exist).
- Only the main session writes this file. Agents return results; the main session records them.
- In chat mode, the file lives in the workspace with the project files.

```json
{
  "schemaVersion": 1,
  "createdAt": "2026-11-05T21:30:00Z",
  "tags": ["Web", "Public", "Accounts"],
  "independent": true,
  "decisions": [
    {
      "id": "D1",
      "question": "Which approved font replaces Inter?",
      "answer": "Source Sans 3",
      "appliesTo": ["F4", "F9"]
    }
  ],
  "phases": [
    {
      "id": "P1",
      "severity": "critical",
      "sections": [11],
      "findings": ["F1", "F2"],
      "status": "pending"
    }
  ],
  "findings": [
    {
      "id": "F1",
      "severity": "critical",
      "section": 11,
      "rule": "Sensitive data in browser storage",
      "file": "src/lib/auth.ts",
      "line": 42,
      "evidence": "localStorage.setItem('auth_token', session.token)",
      "fix": "Move the session to an HttpOnly cookie with @supabase/ssr",
      "status": "open",
      "note": ""
    }
  ],
  "unverified": ["Screen reader testing (manual)"]
}
```

**Finding statuses:**

| Status | Meaning |
|---|---|
| `open` | Found and not yet fixed |
| `fixed` | Fixed and confirmed by verification |
| `still-open` | A fix was attempted but verification did not confirm it |
| `skipped` | The user chose to keep it; an exception is recorded in `.app-standards.json` |
| `needs-decision` | Fixing it requires a choice that was not settled in planning |
| `needs-re-audit` | Its evidence is no longer in the file, so it cannot be fixed safely |

**Phase statuses:** `pending`, `done`.

## Stage 1: Audit

1. If `.app-standards/audit.json` already exists, ask whether to reuse it or run a fresh audit. Recommend a fresh audit when any project file changed after `createdAt`.
2. Read `.app-standards.json` for tags and exceptions. If it doesn't exist, infer the tags from the code and say which you inferred.
3. Find the problems:
   - **Agent mode:** delegate to the `standards-reviewer` agent in audit mode, in the foreground. It returns findings as JSON.
   - **Chat mode:** run `scripts/lint.js --scan <project>` from this skill's directory (or `scripts/lint.sh` without Node), then work through `verification-checklist.md` section by section.
4. **Every finding needs evidence:** the file, the line, and the exact text (or exact missing element) that breaks the rule. Drop any finding without evidence. Never record a finding from memory or assumption.
5. Number findings `F1`, `F2` and so on, assign severity and section, and write the file with every finding `open`.
6. Report a short summary: findings per severity, tags audited, unverified checks, and whether the audit was independent (`true` only in agent mode).

Severity:
- **Critical:** security or privacy exposure, data loss, payments.
- **High:** accessibility blockers, legal requirements, broken functionality or links.
- **Medium:** rule violations users can see (design, writing, layout).
- **Low:** polish and consistency.

## Stage 2: Plan

1. Group open findings into phases: by severity first (Critical, then High, Medium, Low), then by skill section within each severity. A phase holds at most 15 findings and touches at most 10 files; split larger groups.
2. Find every judgment call: a replacement font, which icon set, whether to remove decorative content, new wording for a vague title, a layout change, an accent color. Ask the user all of them at once, using AskUserQuestion when available. Record each answer as a decision linked to its findings.
3. Ask which findings the user wants to keep as they are. Mark those `skipped` and record each as an exception in `.app-standards.json`.
4. Tell the user how many phases there are, what each covers, and how the run will proceed in this mode.

## Stage 3: Fix in Phases

### Every phase, in every mode
1. Read the phase's findings and linked decisions from the file. Read nothing else from earlier work.
2. Reread the SKILL.md sections and reference files for the phase's sections only.
3. Before each edit, find the finding's evidence text in its file. If it isn't there, mark the finding `needs-re-audit` and move on. Never guess where it moved.
4. Fix only the findings in the phase. No unrelated changes, refactors or cleanup.
5. If a fix needs a choice that no decision covers, mark it `needs-decision` and move on. Never make the choice silently.
6. Make small targeted edits. Never reprint whole files into the conversation.
7. Verify (below), update each finding's status and the phase's status in the file, and give the user a summary of three lines or fewer: fixed, still open, and the next phase.

### Agent mode
- `/app-standards:fix` with no argument runs every pending phase automatically, one after another, in a single turn. Do not end the turn until every pending phase is done or blocked.
- Run every agent in the foreground (`run_in_background: false`) and wait for its result before the next step. Never start a fixer or reviewer in the background, and never run two phases at once: phases can touch the same files.
- For each phase, start a fresh `standards-fixer` agent with only: the project folder, the phase's findings (with evidence), the linked decisions, the section numbers, and this skill's directory. It returns one result per finding.
- Then run the `standards-reviewer` agent in verify mode on the phase's findings and the files the fixer touched. Only the reviewer can confirm a finding `fixed`. A finding the fixer reports fixed but the reviewer doesn't confirm becomes `still-open`.
- Keep only the short results in the main conversation.

### Chat mode
- Run **one phase per turn**, then stop and wait. The user continues with `/app-standards:fix next` or by saying "next."
- Verify with `scripts/lint.js` on the files the phase changed, then check each finding against its rule and evidence. Mark results as not independent.
- After about 8 phases in one conversation, suggest continuing in a new chat: give the user the updated `.app-standards/audit.json` and the changed files, and one line to paste with them ("Attach these files and run `/app-standards:fix next`," or "continue the app-standards fixes" without the plugin).

## Stage 4: Final Report

Build the report from the findings file, never from memory:
- Counts per status, and per severity for anything not `fixed`.
- Every `still-open`, `needs-decision` and `needs-re-audit` finding, with its file and the reason.
- Exceptions recorded during the run.
- Any new problems verification found, as new findings.
- Unverified checks.
- Whether verification was independent. When it wasn't, recommend a fresh audit (in a new chat, where possible) before shipping.
- In chat mode, send the changed files (or the whole project as a zip) for the user to download. Never include `.app-standards/audit.json` in what you send.

## Stage 5: Cleanup

Clean up only after the final report is written, because the report is built from the findings file.

- **Every finding is `fixed` or `skipped`:** delete `.app-standards/audit.json`, and the `.app-standards/` folder if it is now empty. Keep the `.gitignore` entry for future audits. Say in one line that the findings file was removed.
- **Any finding is `open`, `still-open`, `needs-decision` or `needs-re-audit`:** keep the file, because it holds the evidence and decisions needed to finish later. Say in one line that it was kept and why, and that `/app-standards:fix clear` (or asking to clear the audit) removes it.
- **On a linked computer where deleting needs permission:** request it once. If the user declines, tell them where the file is so they can delete it themselves.
- **In chat mode:** the file exists only in your workspace. Leave it out of everything you send, and nothing reaches the user's computer.

## Command Arguments

| Command | Action |
|---|---|
| `/app-standards:fix` | Audit if needed, plan, then run all phases (agent mode) or the first phase (chat mode) |
| `/app-standards:fix next` | Run the next pending phase only |
| `/app-standards:fix phase P3` | Run one specific phase |
| `/app-standards:fix critical` (or `high`, `medium`, `low`) | Plan and run only that severity |
| `/app-standards:fix section 7` | Plan and run only that skill section |
| `/app-standards:fix status` | Show progress from the file without changing anything |
| `/app-standards:fix clear` | Delete the findings file now, whatever its contents (confirm first if findings are still open) |
