---
name: launch-tasks
description: Writes LAUNCH-CHECKLIST.md listing the launch tasks only the builder can complete for this project, and explains how to complete each one.
disable-model-invocation: true
---

# Launch Tasks

Produce the checklist of tasks the builder must complete before launch, and explain each one.

## 1. Gather the project context
- Read `.app-standards.json` if it exists for the tags, host, backend and `legalDetails` status. If it doesn't exist, infer the tags from the code and say which you inferred.
- Read the Builder Launch Tasks section of `${CLAUDE_PLUGIN_ROOT}/skills/standards/references/web-developer-checklist.md`.
- Read `${CLAUDE_PLUGIN_ROOT}/skills/standards/references/launch-task-guide.md`.

## 2. Choose the applicable tasks
Include a task only when the project needs it. Check the code, not just the tags:
- Domain tasks list the actual subdomains the project uses.
- Provider tasks list only the sign-in providers the code configures.
- Legal and content tasks are included only when open fields or placeholders exist. Search for them and list each one with its file.
- The humans.txt and security.txt tasks are included only when those files exist or are required.
- Optional tasks are always listed last, under "Optional."

## 3. Write LAUNCH-CHECKLIST.md
Write the file in the project root. Group tasks under the same headings as the guide. For each task:

```markdown
- [ ] **Connect the domain and subdomains**
  - **Why:** Until the DNS records exist, visitors cannot reach the site at its real address.
  - **How:** In the Vercel project, open the domain settings and add example.com and app.example.com. Add the DNS records Vercel shows at your registrar.
  - **Done when:** Both addresses load over HTTPS and Vercel shows them as verified.
```

Fill in the project's real names (domain, subdomains, providers, file paths) wherever they are known. The file follows the writing rules in the standards skill. If the file already exists, keep completed checkboxes checked and update the rest.

## 4. Explain the tasks to the user
After writing the file, always send the user a message that:
- States how many tasks apply, and how many are optional.
- Explains each task in a sentence or two: what it is, and how they should complete it.
- Names any task that blocks launch (such as live payment keys or legal review) and suggests an order to work through them.
- Notes that the full steps are in `LAUNCH-CHECKLIST.md`.
