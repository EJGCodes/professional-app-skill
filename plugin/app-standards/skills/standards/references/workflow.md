# Workflow

Read this at the start of every build: a new project, a change to an existing one, or a review. It covers how to set up, which tools to use, and how to deliver.

## Project Start
At the start of a new project, ask the builder (together with any other setup questions):
- The details needed for legal pages (listed in `legal-and-privacy.md`).
- Brand colors. If the user has none, show a few accent color options as swatches and wait for a choice. If the user doesn't answer, pick one, say which and why, and record it in the project file.
- The default theme: light unless the builder wants dark. The other theme is always available.
- A logo and favicon. Without a logo, set the site name as text in the site's typeface. Without a favicon, use a generic neutral placeholder and list it under "Open content placeholders."
- Whether the application is creative, if unclear.
- Which frontend to use, if unclear (see Frontend and Hosting).

If the builder does not answer the legal questions, build with labeled placeholder fields and ask again after the first build is done. Never ask for personal information about team members.

## Creative Applications
Creative applications are those whose main purpose is art, design, media, games, entertainment or personal expression. If unclear, ask. Several rules differ for them: the icon set (Font Awesome), a more personal tone on error pages, and longer sessions.

## Frontend and Hosting
- Leave the frontend choice open unless the user specifies one, with one requirement: **[Web] [Public]** public pages must be server-rendered or statically generated, so search engines and social preview bots can read them. A client-only app is allowed only for pages behind login.
- Recommend **Next.js, SvelteKit or Nuxt** for apps with accounts or a backend, and **Astro** for content-focused public sites.
- When the app has accounts and the user still chooses a client-only frontend, follow the client-side rules in `security.md` and note the tradeoff in the delivery summary.
- **[Web]** Host on Vercel unless the user specifies otherwise. Always write the header, redirect and clean URL configuration for whichever host is used.

## Native and Desktop Applications
- Skip rules tagged **[Web]**.
- Follow the intent of every other rule through the platform's equivalent: native animation APIs instead of CSS transforms, the OS keychain instead of HttpOnly cookies, platform accessibility APIs instead of ARIA, platform text layout controls instead of `text-wrap`, a settings screen instead of an `/account` page, and each platform's native provider sign-in flow.
- Verify with the platform tools in `testing-tools.md`.

## Platform Limits
- Some environments cannot support every rule (for example, a single-file HTML page has no server for headers or a sitemap).
- Never fake compliance. Implement the closest version the platform allows, and list what could not be implemented in the delivery summary.

## Existing Projects
- Apply every rule to anything new you build or change.
- Do not rewrite existing code only to fix rule violations unless asked.
- After completing your edits, list existing violations in the delivery summary and recommend that the user fix them.

## Plugin Tools
When this skill is installed as part of the app-standards plugin, these tools are also available:
- **Project file:** `.app-standards.json` in the project root records the project's tags, app type, frontend, host, brand choices and approved rule exceptions. Read it at the start of any work on the project. When the user explicitly overrides a rule, record the exception there. Format in `project-file.md`.
- **Lint hook:** after each file edit, a hook may report possible violations. Fix each one, or, if the user explicitly approved it, record it as an exception in the project file.
- **End-of-turn check:** lists any dashes, separator characters, banned fonts, encoded images or pasted icon drawings, and banned section titles left in files changed during the turn. Fix every one before finishing. After two attempts, the check lets the turn end, and anything still open goes in the delivery summary.
- **Commands:** `/app-standards:new-app` (project setup), `/app-standards:audit` (find problems and save them), `/app-standards:fix` (fix saved problems in phases, auditing first if needed) and `/app-standards:launch-tasks` (builder launch checklist).
- **Agents:** `standards-reviewer` (read-only; audits and verifies) and `standards-fixer` (fixes one phase of findings at a time).

## Verification
- Before delivering, run every applicable check in `verification-checklist.md`.
- When the `standards-reviewer` agent is available, delegate verification to it in build review mode instead of checking your own work. Give it the project folder, the applicable tags, and this skill's directory. Fix what it reports, then run it once more. Stop after two rounds and list anything still open in the delivery summary.
- Without the agent, also run this skill's lint script on the project: `node scripts/lint.js --scan <project folder>` from this skill's directory (`bash scripts/lint.sh` reads one file at a time when Node isn't available).
- If a check cannot be run in the current environment, list it under "Unverified checks." Never report an unrun check as passed.

## Delivery Summary
End every build with a summary using these headings. Omit any heading with nothing to report.
- **Not implemented**: applicable rules the platform could not support, and why.
- **Unverified checks**: checks that could not be run.
- **Open legal fields**: placeholder fields the builder still needs to complete, with a recommendation for legal review before launch.
- **Open content placeholders**: marked content (such as "[Customer quote]") that must be replaced before launch.
- **Builder launch tasks**: every applicable task from `web-developer-checklist.md`, explained using `launch-task-guide.md`.
- **Security issues needing attention**: audit or scan findings that could not be fixed.
- **Existing violations**: rule breaks in code you did not write, with a recommendation to fix them.
- **Notes**: anything else the builder needs to know.
