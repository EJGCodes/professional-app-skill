# app-standards

Rules that hold every website, web app and software application Claude builds to one professional standard. They cover design, UX, writing, accessibility, SEO, legal and privacy, security, sign-in and performance.

The rules come in two forms:

- `plugin/app-standards/` is a Claude plugin. It contains the rules plus three commands, a reviewer agent that checks finished builds, and hooks that flag rule violations as files are edited.
- `skill/professional-application-standards/` is a standalone skill with the same rules and none of the extras. Use it where plugins can't be installed.

Install one or the other. Installing both loads the same rules twice.

Version 2.0.0. Release history is in [CHANGELOG.md](CHANGELOG.md).

## Why it exists

AI-built sites tend to share the same problems: gradient blobs and drop shadows, the same few fonts, vague buttons like "Get Started," invented testimonials, missing legal pages, tokens in localStorage, and forms that fight the user. These rules replace those defaults with specific requirements Claude can check, and the plugin makes Claude verify the work before handing it back.

## What the plugin includes

| Component | Name | What it does |
|---|---|---|
| Skill | `standards` | The full rule set in 14 sections, with 12 reference files Claude reads only when a task needs them |
| Command | `/app-standards:new-app` | Asks the project-start questions, recommends a stack and writes the project file |
| Command | `/app-standards:audit` | Reviews an existing project and reports violations by severity, without changing files |
| Command | `/app-standards:launch-tasks` | Writes `LAUNCH-CHECKLIST.md` with the launch tasks only you can do, and explains each one |
| Agent | `standards-reviewer` | A read-only reviewer that checks builds against the checklist, separately from the session that built them |
| Hook | Lint | Runs after each file edit and flags problems such as banned fonts, shadows, gradients, unsafe HTML and tokens in browser storage |
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

Each rule has an applicability tag (such as Accounts, Payments or Web), so a static landing page never gets login rules and a native app skips web-only rules.

## Installing the plugin

### Claude Code

Claude Code runs every part of the plugin, including the hooks and the reviewer.

To try it for one session without installing:

```bash
claude --plugin-dir plugin/app-standards
```

To install it from this folder so it loads in every session:

```bash
/plugin marketplace add ./plugin/app-standards
/plugin install app-standards@app-standards-marketplace
```

To install it from GitHub, push the contents of the `plugin/app-standards` folder to a repository, so that its hidden `.claude-plugin` folder sits at the top of the repository. Then run:

```bash
/plugin marketplace add <owner>/<repo>
/plugin install app-standards@app-standards-marketplace
```

On Claude Code 2.1.275 or later, one command does both:

```bash
/plugin install app-standards --marketplace <owner>/<repo>
```

The hidden `.claude-plugin` folder inside `app-standards` holds two files: `plugin.json`, which describes the plugin, and `marketplace.json`, which lets Claude Code install it from a folder or repository.

### Claude app and Cowork

1. Open the `plugin/app-standards` folder, select everything inside it (including the hidden `.claude-plugin` folder), and compress it into a zip file.
2. Rename the file to `app-standards.plugin`.
3. In Claude, open Customize, go to the Plugins tab and upload the file.

In regular chat, the skill and commands work. The hooks and reviewer run in Cowork and Claude Code. Sharing an uploaded plugin with other people requires a Team or Enterprise plan.

## Installing the standalone skill

In the Claude app, open the `skill` folder and compress the `professional-application-standards` folder itself into a zip file. Then open Customize, go to the Skills tab and upload it.

In Claude Code, copy the `skill/professional-application-standards` folder into `~/.claude/skills/` to use it in every project, or into a project's `.claude/skills/` folder to use it in that project only.

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

### Auditing an existing project

Run `/app-standards:audit`, or `/app-standards:audit src` to check one folder. The report lists findings from Critical to Low, with the file, line, rule and fix for each. Nothing changes until you ask for fixes.

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

It never holds legal business details, personal information or secrets. The full format is in [project-file.md](plugin/app-standards/skills/standards/references/project-file.md).

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

The hook only reports to Claude. It never blocks an edit or changes a file. It skips `node_modules`, build output, lockfiles and minified files. It only sees files Claude writes with its edit tools, not files created through shell commands; the reviewer catches those at the end of a build. Checks that would go off during normal work (clichés, `console.log`, button wording) are left to the reviewer.

To scan a whole project from a terminal:

```bash
node plugin/app-standards/hooks/scripts/lint.js --scan path/to/project
```

## Where each part runs

| Part | Claude chat | Cowork | Claude Code |
|---|---|---|---|
| Rules (skill) | Yes | Yes | Yes |
| Commands | Yes | Yes | Yes |
| Reviewer agent | No (Claude checks its own work instead) | Yes | Yes |
| Lint and session hooks | No | Yes | Yes |

## Folder layout

```
.
├── README.md
├── CHANGELOG.md
├── LICENSE
├── plugin/
│   └── app-standards/                       the plugin
│       ├── .claude-plugin/                  (hidden) plugin.json and marketplace.json
│       ├── skills/
│       │   ├── standards/                   the rules and 12 reference files
│       │   ├── new-app/
│       │   ├── audit/
│       │   └── launch-tasks/
│       ├── agents/standards-reviewer.md
│       └── hooks/
│           ├── hooks.json
│           └── scripts/                     lint and session start, in Node and bash
└── skill/
    └── professional-application-standards/  the standalone skill
        ├── SKILL.md
        └── references/
```

## Security

The hooks run on your computer with your permissions. Both scripts only read files and print messages. They make no network requests and write nothing. As with any plugin, read `plugin/app-standards/hooks/scripts/` before installing.

## Contributing

Suggestions and fixes are welcome through issues and pull requests. When changing a rule:

- Keep each rule in one section and refer to it from other sections.
- Add or update its check in `verification-checklist.md`.
- If a pattern search can check the rule without false alarms, add it to both `lint.js` and `lint.sh`.
- Make the same change in both copies of the rules: `plugin/app-standards/skills/standards/` and `skill/professional-application-standards/`. The two copies differ only in the `name` line of `SKILL.md`.
- Update the version in `plugin.json` and in both `SKILL.md` files, and add an entry to `CHANGELOG.md`.

## License

[MIT](LICENSE)
