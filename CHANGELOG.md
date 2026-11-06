# Changelog

## 2.2

### New
- `/app-standards:fix` fixes audit findings in small phases, and runs an audit first when there isn't one, so a single command can find and fix problems.
- `standards-fixer` agent fixes one phase at a time in a fresh context, changing only the listed findings and never making judgment calls on its own.
- `audit-and-fix.md` reference: one procedure for every environment. Claude Code and Cowork run all phases automatically with fresh agents; regular chat runs one phase per message and suggests a new chat after about 8 phases.
- Findings are saved with evidence (file, line and exact text) to `.app-standards/audit.json`, which is added to `.gitignore`. Fixes locate each problem by its evidence and skip anything that moved or needs an unmade decision.
- Every judgment call is asked once, before any fixing starts.
- The standalone skill follows the same audit and fix procedure when asked, without slash commands.
- The findings file is deleted once every finding is fixed or kept on purpose, and kept when work remains. `/app-standards:fix clear` deletes it on demand.
- The plugin folder includes its own README, license and changelog, so it works as a repository on its own.

### Changed
- `/app-standards:audit` now saves its findings for `/app-standards:fix`.
- `standards-reviewer` has audit, verify and build review modes, returns structured results, and is the only one that can confirm a fix.
- The lint script moved into the standards skill (`skills/standards/scripts/`), so it is available in chat and in the standalone skill. The hooks call that copy.
- The lint skips the `.app-standards/` folder.

## 2.1

### New
- Section 15, Components and Layouts, with two reference files: `components.md` (cards, interaction states, titles, navbar icon buttons, theme toggle, download buttons, icons and image data) and `layout-patterns.md` (standard layouts by app type, navbar order and element placement).
- Card rules: when to use cards, an image or icon on every card, single-link clickable cards, equal-height grids, consistent padding, no overlapping text, and testing with longer text and larger text sizes.
- An interaction state table defining hover, pressed, focus, disabled and loading for every control.
- Brand colors and the logo are now project-start questions; Claude no longer picks a color scheme without asking.
- Titles stay on one line on typical displays and two lines at most on small ones, without ellipses.
- Writing rules for counts that match their titles, separator characters, and banned vague section titles.
- Rules against encoded images and fonts, and pasted SVG icon drawings.
- Accessibility settings and the theme toggle follow standard placement, with standard sun and moon icons and no floating widgets.
- Download buttons with a download icon and a file name and format label.
- Rewritten Vercel rules with a validated template, the `$schema` line, no legacy properties, and a build check.
- New lint checks: `separator`, `vague-title`, `encoded-asset` and `vercel-config`.
- End-of-turn check that requires fixes for dashes, separator characters, banned fonts, encoded assets and vague titles before a turn ends, with a two-attempt limit.
- `brand` fields in the project file, and launch tasks for checking deployed headers and replacing a placeholder favicon.

## 2.0

The standards skill is now the app-standards plugin.

### New
- `/app-standards:new-app` asks the project-start questions, recommends a stack and writes `.app-standards.json`.
- `/app-standards:audit` reviews an existing project and reports findings by severity without changing files.
- `/app-standards:launch-tasks` writes `LAUNCH-CHECKLIST.md` and explains how to complete each task.
- `standards-reviewer` agent verifies builds independently, read-only, with up to two fix rounds.
- Lint hook flags violations after each edit (Node.js, with a bash fallback), and supports a full-project scan.
- Session-start hook notes that the standards apply in application folders, and stays quiet in game engine projects.
- `.app-standards.json` project file records tags, stack choices and approved rule exceptions.
- Reference files: `project-file.md` and `launch-task-guide.md`.
- Builder launch tasks added for production environment variables, Supabase production settings, live payments, open legal fields and content placeholders.
- Marketplace file, README and MIT license for sharing.

### Changed
- The core skill is named `standards` inside the plugin. The standalone release keeps the name `professional-application-standards`.
- Verification is delegated to the reviewer agent when it is available.

## 1.1

### New
- Section 13: Web Compatibility and Delivery (browser support, no-JavaScript fallbacks, viewport, print styles, caching headers, favicon set and web manifest).
- Section 14: Accounts, Sign-In and Onboarding (email normalization, provider sign-in, password requirements, two-factor authentication, interactive onboarding, account section, data export, easy exit, security notifications).
- Reference files: `web-developer-checklist.md`, `writing.md`, `ux-patterns.md`, `forms-and-data.md`, `accounts-and-onboarding.md` and `legal-and-privacy.md`.
- Link behavior rules, clean URLs with no trailing slash or extensions, subdomain organization, JSON-LD structured data, Open Graph tags, humans.txt, security.txt, and 500 and 503 error pages.
- FAQ page recommendation.
- Input reference table, flexible input formats, data display formatting and backend data storage standards.
- Keyboard accessibility, landmarks, and screen reader support including JAWS.
- Strict CSP strategy, OWASP Top 10 coverage, email deliverability, analytics and offline rules.
- Account deletion 14-day grace period and legal record retention.
- Vercel as the default host.
- Delivery summary headings for "Open content placeholders" and "Builder launch tasks."
- A version number in the skill's frontmatter, and this changelog.

### Changed
- Public pages now require server rendering or static generation.
- Performance targets use the right measurement tool per page and platform; the SEO target applies only to indexable public pages.
- Official brand logos are allowed wherever they represent a third-party service.
- Monospace is allowed for codes, keys and IDs as well as code.
- Theme preference is stored in an essential cookie so server-rendered pages show the right theme with no flash.
- `supabase-security.md` is renamed to `security.md` and now holds all security rules; account rules moved to `accounts-and-onboarding.md`.
- SKILL.md now states the key rules for each section, with full details in the reference files.
- Description updated to cover SEO, sign-in and accounts.

## 1.0
- Initial release.
