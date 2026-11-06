# Project File

Read this before reading or writing `.app-standards.json`. The file lives in the project root. `/app-standards:new-app` creates it; the lint hook, the reviewer agent and every later session read it.

## Format

```json
{
  "schemaVersion": 1,
  "appType": "professional",
  "platforms": ["web"],
  "tags": ["Web", "Public", "Accounts", "Backend", "Data", "Messaging"],
  "sensitiveData": false,
  "frontend": "Next.js",
  "host": "Vercel",
  "backend": "Supabase",
  "regions": ["United States"],
  "legalDetails": "pending",
  "brand": {
    "accentColor": "user-chosen",
    "logo": "provided",
    "favicon": "placeholder"
  },
  "exceptions": [
    {
      "rule": "banned-font",
      "value": "Inter",
      "reason": "User asked for Inter to match their existing brand",
      "date": "2026-10-21"
    }
  ]
}
```

## Fields

| Field | Values | Meaning |
|---|---|---|
| `schemaVersion` | `1` | Format version of this file |
| `appType` | `"professional"` or `"creative"` | Decides the icon set, 404 tone and session length |
| `platforms` | Any of `"web"`, `"desktop"`, `"ios"`, `"android"` | Where the application runs |
| `tags` | Any of `"Accounts"`, `"Data"`, `"Payments"`, `"Uploads"`, `"Messaging"`, `"Backend"`, `"Public"`, `"Web"` | Applicability tags that are true for this project |
| `sensitiveData` | `true` or `false` | Health, financial, precise location, government ID or anything involving minors |
| `frontend` | Framework name | The chosen frontend |
| `host` | Host name | The chosen host (Vercel by default) |
| `backend` | Backend name | The chosen backend (Supabase by default) |
| `regions` | List of countries or regions | Decides legal content and minimum age |
| `legalDetails` | `"provided"`, `"pending"` or `"declined"` | Whether the builder has answered the legal questions. When `"pending"`, ask again after the first build |
| `brand.accentColor` | `"user-chosen"` or `"claude-chosen"` | Whether the user picked the accent color. `"claude-chosen"` means the user didn't answer, so offer the options again at the next chance |
| `brand.logo` | `"provided"` or `"text"` | Whether the header uses the user's logo or the site name as text |
| `brand.favicon` | `"provided"` or `"placeholder"` | Whether the favicon is the user's or a generic placeholder |
| `exceptions` | List | Rule exceptions the user explicitly approved |

Never store legal business details, personal information or secrets in this file. Legal details go directly into the legal pages.

Audit findings and fix progress are kept separately, in `.app-standards/audit.json` (see `audit-and-fix.md`). That folder is listed in `.gitignore`.

## Exceptions

Each exception has:
- `rule`: a lint check ID from the table below, or a short name of the SKILL.md rule (such as `"single-accent-color"`).
- `value` (optional): limits the exception to one value, such as a font name. Without it, the whole rule is excepted.
- `paths` (optional): limits the exception to files whose path starts with one of these prefixes, relative to the project root.
- `reason`: what the user asked for, in plain words.
- `date`: when the user approved it.

Record an exception only when the user explicitly asks for something a rule bans. Never add one to silence a flag on your own.

## Lint Check IDs

| ID | What it flags |
|---|---|
| `banned-font` | Inter, Geist, Space Grotesk and their lookalikes in font declarations and imports |
| `shadow` | Box, text and drop shadows, including Tailwind shadow classes |
| `gradient` | CSS gradients and Tailwind gradient classes |
| `icon-set` | Lucide, Feather, Heroicons, Tabler, Phosphor, Radix and other non-approved icon packages |
| `dash` | Em dashes, and en dashes used as dashes |
| `zoom-disabled` | `user-scalable=no` or `maximum-scale=1` |
| `unsafe-html` | `innerHTML`, `dangerouslySetInnerHTML`, `v-html`, `{@html}`, `set:html`, `eval` and similar, without visible sanitization |
| `sensitive-storage` | Tokens or user data written to localStorage or sessionStorage |
| `csp-unsafe` | `'unsafe-inline'` or `'unsafe-eval'` in a script source |
| `number-input` | `type="number"` on ZIP, phone, card, code or PIN fields |
| `separator` | Middle dots, bullets and dot operators used as inline separators, including their HTML entities |
| `vague-title` | Banned vague or dramatic section titles in headings |
| `encoded-asset` | Images or fonts encoded as `data:` strings, and pasted SVG icon drawing data |
| `vercel-config` | A `vercel.json` that is not valid JSON, lacks the `$schema` line, or uses legacy properties |

The end-of-turn check requires fixes for `dash`, `separator`, `banned-font`, `encoded-asset` and `vague-title` in files changed during the turn. All other checks only flag.
