# app-standards

Rules that hold every website, web app and software application Claude builds to one professional standard. They cover design, UX, writing, accessibility, SEO, legal and privacy, security, sign-in and performance.

This repository is a Claude plugin. Along with the rules, it adds four commands, a reviewer agent that checks work, a fixer agent that repairs audit findings, and hooks that flag rule violations as files are edited.

A standalone skill with the same rules, for places that can't install plugins, is published alongside this plugin as `professional-application-standards`.

Version 2.3. Release history is in [CHANGELOG.md](CHANGELOG.md).

## Why it exists

AI-built sites tend to share the same problems: gradient blobs and drop shadows, the same few fonts, vague buttons like "Get Started," invented testimonials, missing legal pages, tokens in localStorage, and forms that fight the user. These rules replace those defaults with specific requirements Claude can check, and the plugin makes Claude verify the work before handing it back.

## What the plugin includes

| Component | Name | What it does |
|---|---|---|
| Skill | `standards` | The full rule set in 15 sections, 16 reference files Claude reads only when a task needs them, and the lint script |
| Command | `/app-standards:new-app` | Asks the project-start questions, recommends a stack and writes the project file |
| Command | `/app-standards:audit` | Reviews an existing project, saves every finding with evidence, and reports them by severity without changing project files |
| Command | `/app-standards:fix` | Fixes saved findings in small verified phases, running an audit first if there isn't one |
| Command | `/app-standards:launch-tasks` | Writes `LAUNCH-CHECKLIST.md` with the launch tasks only you can do, and explains each one |
| Agent | `standards-reviewer` | A read-only reviewer that audits projects and verifies fixes, separately from the session that did the work |
| Agent | `standards-fixer` | Fixes one phase of findings at a time, starting fresh for each phase |
| Hook | Lint | Runs after each file edit and flags problems such as banned fonts, shadows, gradients, unsafe HTML and tokens in browser storage |
| Hook | End-of-turn check | Before Claude finishes a turn, requires fixes for dashes, separator characters, banned fonts, encoded images or pasted icon drawings, and vague section titles in the files it changed |
| Hook | Session start | In application folders, tells Claude the rules apply so it loads them before building |

## What the rules cover

1. Color and visual style: one accent color, and no shadows, gradients or decorative pills.
2. Typography: approved fonts only, a clear hierarchy, and no eyebrow labels or orphan words.
3. Layout: fully responsive, relative units, and tables that become cards on small screens.
4. Icons and media: Material Symbols or Font Awesome only, licensing rules and compression standards.
5. Motion and interaction: transform-based animation, double-click protection, honest loading states and no dark patterns.
6. Forms: correct input types, flexible input formats and clear validation.
7. Writing: no em dashes or clichés, specific calls to action and truthful content.
8. Navigation and search: link behavior, clean URLs, structured data, Open Graph and error pages.
9. Accessibility and theming: WCAG 2.2 AA, full keyboard support, landmarks and screen reader support.
10. Legal and privacy: legal pages, cookie consent, easy deletion and email deliverability.
11. Security: Supabase row-level security, a strict CSP, the OWASP Top 10 and nothing sensitive in the browser.
12. Performance: PageSpeed scores of 90 or more, a JavaScript budget, retries and offline handling.
13. Web compatibility: browser support, fallbacks when JavaScript fails, print styles and caching headers.
14. Accounts and onboarding: provider sign-in, two-factor authentication, interactive onboarding and an account section.
15. Components and layouts: cards, tooltips, interaction states for every control, navbar order and icon buttons, download buttons, and the standard layout for each app type.

Each rule has an applicability tag (such as Accounts, Payments or Web), so a static landing page never gets login rules and a native app skips web-only rules.

## Installing the plugin

### Claude Code

Claude Code runs every part of the plugin, including the hooks and both agents.

To try it for one session without installing, from a copy of this repository:

```bash
claude --plugin-dir path/to/app-standards
```

To install it from GitHub:

```bash
/plugin marketplace add <owner>/<repo>
/plugin install app-standards@app-standards-marketplace
```

On Claude Code 2.1.275 or later, one command does both:

```bash
/plugin install app-standards --marketplace <owner>/<repo>
```

The hidden `.claude-plugin` folder holds two files: `plugin.json`, which describes the plugin, and `marketplace.json`, which lets Claude Code install it from this repository.

### Claude app and Cowork

1. Select everything in this repository's folder (including the hidden `.claude-plugin` folder) and compress it into a zip file.
2. Rename the file to `app-standards.plugin`.
3. In Claude, open Customize, go to the Plugins tab and upload the file.

In regular chat, the skill and commands work. The hooks and agents run in Cowork and Claude Code. Sharing an uploaded plugin with other people requires a Team or Enterprise plan.

## Requirements

- Node.js 18 or later for the plugin's hooks. Without Node, the hooks fall back to bash and run a smaller set of checks.
- On Windows, Git for Windows (Git Bash), which Claude Code uses to run hook commands.
- Playwright (optional) for the reviewer's browser checks. Without it, those checks are reported as unverified.

## Using the plugin

### Starting a project

Run `/app-standards:new-app` with a short description:

```
/app-standards:new-app a booking site for a dog walking business with accounts and payments
```

Claude asks only what the description doesn't answer, recommends a stack and writes `.app-standards.json`. It doesn't build anything until you tell it to start.

### Building

Ask Claude to build or change the app as you normally would. The rules guide the work, the lint hook flags violations after each edit, and the reviewer checks the finished build before Claude reports back. Every build ends with a summary of anything not implemented, checks that couldn't run, open legal fields, placeholder content and launch tasks.

### Auditing and fixing an existing project

You can do this in two steps or one.

**Two steps:** run `/app-standards:audit` (or `/app-standards:audit src` for one folder) to see what's wrong, then run `/app-standards:fix` when you're ready.

**One step:** run `/app-standards:fix` on its own. It audits first, then fixes.

Either way, the fix works like this:

1. **Findings are saved with evidence.** Every problem is written to `.app-standards/audit.json` with its file, line and the exact text that breaks the rule. Nothing is recorded from memory, and the file is added to `.gitignore`.
2. **Decisions come first.** Claude groups the findings into small phases (Critical first, then High, Medium and Low) and asks every judgment call at once, such as which font replaces a banned one. Anything you want to keep is recorded as an exception.
3. **Fixes happen in phases.** Each phase rereads only the rules it needs, fixes only its listed findings, and skips anything whose evidence has moved or that needs a choice you haven't made, rather than guessing.
4. **Every phase is verified.** A finding counts as fixed only after it passes verification.
5. **The final report comes from the saved file,** listing what's fixed, what's still open and why.
6. **The findings file is removed when it's no longer needed.** Once every finding is fixed or kept on purpose, Claude deletes `.app-standards/audit.json`. If anything is still open, it keeps the file so you can finish later, and tells you so.

How the phases run depends on where you are:

| Where | How phases run | Verification |
|---|---|---|
| Claude Code or Cowork | All phases run automatically. Each one gets a fresh fixer agent, so your conversation stays short | The separate reviewer agent |
| Regular chat | One phase per message. Type `next` or run `/app-standards:fix next` to continue. After about 8 phases, Claude suggests continuing in a new chat with the saved file | The lint script plus a rule-by-rule check, marked as not independent |

Other options:

| Command | What it does |
|---|---|
| `/app-standards:fix next` | Runs only the next phase |
| `/app-standards:fix phase P3` | Runs one specific phase |
| `/app-standards:fix critical` | Fixes only one severity level (also `high`, `medium` or `low`) |
| `/app-standards:fix section 7` | Fixes only one section of the rules |
| `/app-standards:fix status` | Shows progress without changing anything |
| `/app-standards:fix clear` | Deletes the findings file now, asking first if anything is still open |

The standalone skill version follows the same process when you ask Claude to audit or fix a project, without the slash commands.

### Preparing for launch

Run `/app-standards:launch-tasks`. It writes `LAUNCH-CHECKLIST.md`, with each task's purpose, its steps and how to tell when it's done.

## The project file

`.app-standards.json` in a project's root records the choices that decide which rules apply:

```json
{
  "schemaVersion": 1,
  "appType": "professional",
  "platforms": ["web"],
  "tags": ["Web", "Public", "Accounts", "Backend", "Data"],
  "sensitiveData": false,
  "frontend": "Next.js",
  "host": "Vercel",
  "backend": "Supabase",
  "regions": ["United States"],
  "legalDetails": "pending",
  "exceptions": []
}
```

It never holds legal business details, personal information or secrets. The full format is in [project-file.md](skills/standards/references/project-file.md).

### Rule exceptions

Your instructions always come first. When you explicitly ask for something a rule bans, Claude records an exception so the hook and reviewer stop flagging it:

```json
{
  "rule": "banned-font",
  "value": "Inter",
  "reason": "Matches the existing brand",
  "date": "2026-10-21"
}
```

Leave out `value` to make an exception for the whole rule, or add `paths` to limit it to certain folders.

## Lint checks

| ID | Flags |
|---|---|
| `banned-font` | Inter, Geist, Space Grotesk and fonts that look like them |
| `shadow` | Box, text and drop shadows, including Tailwind classes |
| `gradient` | CSS gradients and Tailwind gradient classes |
| `icon-set` | Lucide, Feather, Heroicons, Tabler, Phosphor, Radix and similar packages |
| `dash` | Em dashes, and en dashes used as dashes |
| `zoom-disabled` | `user-scalable=no` or `maximum-scale=1` |
| `unsafe-html` | `innerHTML`, `dangerouslySetInnerHTML`, `v-html`, `eval` and similar, without sanitization |
| `sensitive-storage` | Tokens or user data written to localStorage or sessionStorage |
| `csp-unsafe` | `'unsafe-inline'` or `'unsafe-eval'` for scripts |
| `number-input` | `type="number"` on ZIP, phone, card or code fields |
| `separator` | Middle dots and bullets used to separate inline items |
| `vague-title` | Section titles such as "Why it matters" or "The bottom line" |
| `encoded-asset` | Images or fonts encoded into the code as `data:` strings, and pasted SVG icon drawings |
| `vercel-config` | A `vercel.json` that isn't valid JSON, lacks the `$schema` line, or uses legacy properties |
| `transition-all` | `transition: all`, which animates properties that were never meant to move |
| `title-tooltip` | The HTML `title` attribute used as a tooltip |
| `outline-removed` | A removed focus outline, which needs a visible replacement |

The hook only reports to Claude. It never blocks an edit or changes a file. It skips `node_modules`, build output, lockfiles and minified files. It only sees files Claude writes with its edit tools, not files created through shell commands; the reviewer catches those at the end of a build. Checks that would go off during normal work (clichés, `console.log`, button wording) are left to the reviewer.

The end-of-turn check is stricter for five of these: `dash`, `separator`, `banned-font`, `encoded-asset` and `vague-title`. If any remain in files Claude changed during the turn, Claude has to fix them, or record an exception you explicitly approved, before it can finish. After two attempts the check lets the turn end, and anything still open is listed in the build summary.

To scan a whole project from a terminal:

```bash
node skills/standards/scripts/lint.js --scan path/to/project
```

## Where each part runs

| Part | Claude chat | Cowork | Claude Code |
|---|---|---|---|
| Rules (skill) | Yes | Yes | Yes |
| Commands | Yes | Yes | Yes |
| Audit and fix | Yes, one phase per message | Yes, all phases automatically | Yes, all phases automatically |
| Reviewer and fixer agents | No (Claude checks its own work, with the lint script) | Yes | Yes |
| Lint, end-of-turn and session hooks | No | Yes | Yes |

## Folder layout

```
.
├── .claude-plugin/              (hidden) plugin.json and marketplace.json
├── skills/
│   ├── standards/               the rules, 16 reference files and the lint script
│   ├── new-app/
│   ├── audit/
│   ├── fix/
│   └── launch-tasks/
├── agents/                      standards-reviewer and standards-fixer
├── hooks/
│   ├── hooks.json
│   └── scripts/                 hook launcher and session start, in Node and bash
├── README.md
├── CHANGELOG.md
└── LICENSE
```

## Security

The hooks run on your computer with your permissions. The scripts read project files and print messages. They make no network requests. The only thing they write is a small list of the files edited in the current session, kept in your system's temporary folder so the end-of-turn check knows what to re-check. As with any plugin, read `hooks/scripts/` and `skills/standards/scripts/` before installing.

## Contributing

Suggestions and fixes are welcome through issues and pull requests. When changing a rule:

- Keep each rule in one section and refer to it from other sections.
- Add or update its check in `verification-checklist.md`.
- If a pattern search can check the rule without false alarms, add it to both `lint.js` and `lint.sh`.
- Make the same change in the standalone skill, which differs from `skills/standards/` only in the `name` line of `SKILL.md`.
- Update the version in `plugin.json` and in the `SKILL.md` files, and add an entry to `CHANGELOG.md`. Versions use two numbers (such as 2.2), with a third only for a fix to an existing release (such as 2.2.1).

## License

[MIT](LICENSE)
