---
name: professional-application-standards
description: Design, UX, writing, accessibility, SEO, legal, security, sign-in and performance standards for building, editing or reviewing any website, web app or software application. Use whenever creating or changing an application's interface, content, accounts or backend, including landing pages, dashboards, SaaS products, admin tools, desktop and mobile apps, even if the user does not mention standards or quality. Does not apply to in-game UIs.
metadata:
  version: 2.3
---

# Professional Application Standards

These rules keep applications professional, secure and clean, and avoid the common pitfalls of AI-built sites. Apply them to every website, web application or software application you build, edit or review. This file holds the key rules. The reference files hold the details, and each must be read at the moment the table below names.

## How to Apply This Skill

**Precedence.** Explicit user instructions come first: mention a conflict with a rule once, then follow the user. This skill comes second. Other design guidance (general frontend or artifact design skills) comes third; where it suggests something this skill bans, this skill wins.

**Scope.** Every type of web or software application: websites, web apps, desktop apps and mobile apps. Not in-game UIs (HUDs, menus inside a game, in-game stores). Everything around a game is included: its website, launcher, account system, admin tools and analytics dashboards.

**Applicability tags.** A tagged rule applies only when its trigger is true. Untagged rules always apply. Never add a feature only to satisfy a rule.
- **[Accounts]**: sign-up, login or user profiles.
- **[Data]**: personal data, or non-essential cookies or trackers.
- **[Payments]**: anything can be purchased.
- **[Uploads]**: users can upload files.
- **[Messaging]**: the build sends email or text messages.
- **[Backend]**: a server, database or API.
- **[Public]**: publicly accessible pages, or public user content.
- **[Web]**: runs in a browser. Native apps skip these rules.

**Writing scope.** The writing rules (Section 7) apply to everything you create in the application: visible content, code comments, commit messages, READMEs, documentation, email templates and legal pages. They don't apply to your delivery summary or chat messages.

**Each rule lives in one place.** Sections cross-reference each other instead of repeating rules.

### Reference Files

| File | Read before |
|---|---|
| `references/workflow.md` | Starting any build: project setup, frontend and hosting, native apps, existing projects, plugin tools, verification and the delivery summary |
| `references/fonts.md` | Choosing any font |
| `references/writing.md` | Writing any content, labels, messages or emails |
| `references/components.md` | Building cards, buttons, navbar controls, tooltips, download buttons, the theme toggle or any title |
| `references/layout-patterns.md` | Laying out any page, navbar or app shell |
| `references/ux-patterns.md` | Building loading states, interactions, motion, notices, flows or error handling |
| `references/forms-and-data.md` | Building any form, input, data display or database schema |
| `references/accounts-and-onboarding.md` | Building sign-up, sign-in, onboarding or account pages |
| `references/legal-and-privacy.md` | Building legal pages, cookie consent, deletion, messaging or analytics |
| `references/security.md` | Building any backend, authentication, session or data storage |
| `references/web-developer-checklist.md` | Building any [Web] project |
| `references/testing-tools.md` | Testing performance, accessibility or security |
| `references/verification-checklist.md` | Delivering any build |
| `references/audit-and-fix.md` | Auditing a project or fixing audit findings |
| `references/project-file.md` | Reading or writing `.app-standards.json` |
| `references/launch-task-guide.md` | Explaining builder launch tasks |

### Every Build
1. Read `references/workflow.md` and follow it: project start questions, setup and tools.
2. Build to the rules below, reading each reference file when the table says.
3. Verify with `references/verification-checklist.md` (through the `standards-reviewer` agent when available). Never report an unrun check as passed.
4. End with the delivery summary defined in `references/workflow.md`.

When the user asks to audit, review, check or fix a project against these standards, follow `references/audit-and-fix.md`.

## 1. Color and Visual Style

### Musts
- One primary accent color. Use shades of it instead of a second color (unless specified). Neutrals and semantic status colors (error, success, warning) don't count as a second color. Charts use accent shades first.
- Use the user's brand colors. Without them, offer accent color options and let the user choose. Never pick a color scheme without asking, and never copy another brand's colors.
- Clean contrast throughout (targets in Section 9). On colored backgrounds, tint borders and text toward the background's hue.
- Separate layers with borders, dividers, tonal background shades, spacing, and a solid scrim behind modals.
- One corner radius scale across the app (such as small for inputs, medium for cards, large for modals). A child's radius never exceeds its parent's, and nested curves stay concentric.
- Use badges and chips only when they tell the user something they need (such as an order status or an active filter).

### Don'ts
- No shadows of any kind (box-shadow, text-shadow, drop-shadow), including subtle ones.
- No gradients, gradient blobs, liquid glass, radial orbs, dot grids or grain textures.
- No highlighter pills (colored rounded backgrounds behind words), and no decorative pills or badges, including chips that only hold step text.
- No colored left strips on any element, including cards, alerts, callouts, list items, nav indicators and blockquotes. Show an active nav item with a tonal background, text color or weight.
- No dark or hidden patterns in backgrounds.

## 2. Typography

### Musts
- One main typeface, two at most. Read `references/fonts.md` before choosing: use an approved font, the user's font, or one that passes every criterion there. Self-host font files where the platform allows.
- A clear size hierarchy, and text that stays in clean contrast with whatever it sits on.
- **[Web]** `text-wrap: balance` on headings and `text-wrap: pretty` on paragraphs, with fallbacks.
- Monospace only for code, and for codes, keys and IDs the user must read or copy.
- Italics only for titles of works, foreign terms and quotations.
- Text under a heading only when it adds information found nowhere else on the page.

### Don'ts
- No Inter, Geist, Space Grotesk, monospace UI fonts, or any lookalike listed in `references/fonts.md`. The system font stack is only a fallback.
- No title longer than one line on typical displays, or two lines on small displays (under 768 px). Never cut a title off with an ellipsis.
- No eyebrow labels (small text or badges above a heading), and no headings followed by unnecessary summaries.
- No double-accented phrases: at most one word per title may differ in color, size or rotation, and only by choice, never by default.
- No italics for emphasis.
- No orphan words: never single out words from normal text for emphasis, never split a headline word by word, and never strand one word on the last line.

## 3. Layout and Responsiveness

### Musts
- Every element resizes with the screen and window. Use relative units (`%`, `fr`, `rem`, `clamp()`, viewport units); fixed pixels only for borders, hairlines and minimum tap targets.
- Consistent spacing everywhere, aligned elements of the same type, and long text that never breaks the layout.
- Follow the standard layout for the app type and element placement in `references/layout-patterns.md`. Any other layout needs the user's approval.
- When an onscreen keyboard opens, scroll the focused input into view above it. Nothing fixed or sticky may cover it, and only the scroll position changes: no layout shift.
- On mobile and narrow windows, table rows become cards with the same fields, in the same order, labeled with the column headers.
- Verify at 320, 375, 768, 1024, 1440 and 1920 px, and while resizing between them.

### Don'ts
- No dead space: purposeless empty areas such as oversized hero padding, empty columns on wide screens, or sections stretched to fill the viewport.
- No table rows that wrap text. Keep row content short.
- No horizontal page scroll at any width.

## 4. Icons, Images and Media

### Musts
- Icons come only from Material Symbols (professional applications) or Font Awesome (creative applications), one set per project, referenced by name. Keep icons consistent across pages and with the favicon.
- Official brand logos are the one exception, wherever they represent a third-party service (sign-in buttons, social links), using the brand's official assets.
- Use only the user's logo. Never invent, generate or borrow one. Without a logo, set the site name as text; without a favicon, use a neutral placeholder and list it in the delivery summary.
- Images and media are the user's, or free-to-use stock (no paid license) when none are provided. When none fits, use a neutral, clearly marked placeholder.
- Images, logos and fonts are separate files: never pasted SVG drawing data or `data:` strings.
- Charts show real data, in a chart type that fits it, in accent shades with colorblind-friendly contrast.
- Compress all media (details in `references/web-developer-checklist.md`), give images and video `width` and `height`, and give video a poster and captions.

### Don'ts
- No emojis as icons, and no other icon sets (Lucide, Feather, Heroicons and similar).
- No meaningless icons, such as a pulsing circle next to dates.
- No licensed or unapproved outside media, and no AI-generated media unless requested.
- No decorative charts, stat blocks ("10k+ users") or diagrams that exist to look busy, and no inverted bar charts (bars rising for no reason, to suggest growth).

## 5. Motion, Loading and Interaction

Read `references/ux-patterns.md` and the interaction state table in `references/components.md` first.

### Musts
- Every interactive element, especially buttons and cards, has visible hover, pressed, focus, disabled and loading states, with more contrast than at rest. A control with no visible response is incomplete.
- Prevent double-clicks from creating duplicate actions (IMPORTANT): update the UI, lock the control, send an idempotency key, and roll back with a clear message if the server refuses. Payments, deletions and other irreversible actions wait for the server.
- Animate with `transform` and `opacity`, only to show cause and effect or for deliberate delight. Never `transition: all`. Respect reduced motion.
- Loaders wait 150 to 300 ms before appearing and stay at least 300 to 500 ms once shown. Skeletons match the content they replace.
- View state (filters, tabs, pages, search, expanded panels) lives in the URL, and Back and Forward restore scroll position.
- No dead zones, 44×44 px minimum tap targets (inline text links excepted), and click, tap and keyboard alternatives for every gesture.
- Backspace removes one character (or one chip) at a time, never a whole field.

### Don'ts
- No looping arrow loaders, and no thin bar along the top edge of the page for any purpose.
- No popups, modals or prompts on page load, except the notices allowed in `references/ux-patterns.md`.
- No dark or harmful UX patterns (list in `references/ux-patterns.md`).

## 6. Forms and Input

Read `references/forms-and-data.md` first.

- Follow its input table for every field, with a visible label, text of at least 16 px, and placeholders that show an example format without an ellipsis.
- Accept every correct way of typing a value, trim stray spaces, never block keystrokes, and normalize on the server.
- Validate when a field is left, never on untouched fields. Never disable submit in advance; on submit, show errors beside their fields and focus the first.
- Follow its rules for Enter, search timing, passwords, dates, age and uploads.

## 7. Writing and Content

Read `references/writing.md` first.

### Musts
- All content is truthful about the site. When real content isn't available, use clearly marked placeholders.
- Every call to action, button and instruction says exactly what to do or what happens next.
- Every message says what happened and the next step, in a positive tone. A short standard opening ("Something went wrong.") is fine when the next sentence gives the cause and next step.
- Curly quotes and apostrophes in visible text. Mark brand names, product names and code with `translate="no"`.
- A number in a title or introduction matches the number of items that follow. Choose the count from the content, never from habit.

### Don'ts
- No em dashes, en dashes used as dashes, or spaced hyphens used as dashes.
- No separator characters between inline items (middle dot, bullet, vertical bar).
- No vague or dramatic section titles (such as "Why it matters"). Titles describe the actual content.
- No clichés, banned calls to action ("Get Started," "Learn More") or general messages with nothing after them (lists in `references/writing.md`).
- No sentence fragments for emphasis, and no content padded or trimmed to fit a rule of three.
- No raw error codes or stack traces shown to users.
- No fake reviews, testimonials, user counts, logos, statistics or other unsupported claims.

## 8. Navigation, Structure and Search

Read `references/web-developer-checklist.md` and `references/layout-patterns.md` first.

- A mobile-friendly navbar in the standard order, a logo linking home (or to the dashboard when signed in), and a working footer with an automatic copyright year.
- Link text matches its destination and makes sense alone. External links, and links from inside a task to an informational page, open in a new tab with `rel="noopener noreferrer"` and a visible indicator. All other internal links open in the same tab.
- Custom 404, 500 and **[Backend]** 503 pages, with real status codes.
- Page titles in the form "Site Name - Page Name."
- **[Web]** Clean, extension-free URLs without trailing slashes, canonical tags, accurate meta descriptions, real `<a href>` links, and `noindex` on private pages.
- **[Web] [Public]** JSON-LD (never microdata), Open Graph tags, a sitemap, robots.txt and humans.txt. Never put placeholders in machine-readable data.
- Choose the starting language from browser settings, never by IP address, with a visible way to change it.

## 9. Accessibility and Theming

### Musts
- Contrast meets WCAG 2.2 AA (4.5:1 for body text, 3:1 for large text and UI elements) and also passes APCA checks for text. High-contrast mode meets AAA (7:1).
- Full keyboard access: every control reachable and usable in visual order, no positive `tabindex`, no keyboard traps, focus returned when modals close, Escape closing menus, modals and popovers, WAI-ARIA keyboard patterns for custom widgets, and a visible solid outline on every focusable element. Nothing works only on hover.
- A "Skip to content" link first, at least one `<h1>` per page, and headings in order without skipped levels.
- Semantic HTML and native elements before ARIA: lists for lists, real tables with `<th scope>` and `<caption>`, links to navigate and buttons to act, and `<address>`, `<figure>` and `<time>` where they apply. **[Web]** Landmarks (`<header>`, `<nav>`, one `<main>`, `<footer>`, plus `<aside>` and `<search>` where they apply) holding all content, distinct labels on multiple navs, and zero W3C validator errors.
- Alt text on meaningful images, `alt=""` on decorative ones, and `lang` on every page.
- Never convey information by color alone.
- Support screen readers (VoiceOver, NVDA, JAWS, TalkBack), 400% zoom with reflow at 320 px, voice control and translation tools. Announce dynamic updates through live regions.
- Accessibility options (high contrast, text size, reduced motion) in the standard places (`references/layout-patterns.md`), with device settings applied automatically. Never a floating accessibility widget.
- Light mode by default, regardless of the device's setting, unless the builder asks for dark. The other theme is always available through a navbar toggle with standard sun and moon icons. Remember the choice in an essential preference cookie, render it on the server with no flash, and set `color-scheme` to match.
- Every theme and option works without breaking the layout.

## 10. Legal, Privacy and Compliance

Read `references/legal-and-privacy.md` first.

- **[Data]** A privacy policy, terms of service and a data deletion system. **[Web] [Data]** A cookie policy and consent banner with per-category toggles whenever non-essential cookies are used. **[Payments]** A refund policy and the full total shown before paying.
- Legal pages contain only confirmed details. Never invent names, addresses, jurisdictions, retention periods or services.
- Collect only the data a feature requires.
- **[Messaging]** One-click unsubscribe in every message. **[Accounts] [Messaging]** A production email setup for account emails.

## 11. Security

Read `references/security.md` first.

- **[Backend]** Supabase by default, with row-level security on every table. Logged-out visitors can't reach any account data.
- Authentication and authorization on every API endpoint, secrets on the server, server-side authority, and server-protected admin routes.
- Rate limits everywhere possible, strictest on sign-in, sign-up, password reset, forms and external API calls.
- Sanitize user content, encode output, and never render user HTML without DOMPurify. Protect against CSRF.
- HttpOnly, Secure, SameSite session cookies over HTTPS. Never expose user data or tokens in browser storage, URLs, page source or logs.
- **[Web]** A strict Content-Security-Policy and the full security header set.
- Cover the OWASP Top 10, scan dependencies and secrets, and ship nothing on the Never Ship list.

## 12. Performance and Reliability

- Handle failures cleanly with limited retries, no fixable console errors, no memory leaks, and a clear offline message (details in `references/ux-patterns.md`).
- **[Web]** PageSpeed or Lighthouse scores of 90+ (SEO on indexable public pages), Core Web Vitals in the "good" range, and at most 170 KB of first-party initial JavaScript (techniques in `references/web-developer-checklist.md`).
- **[Backend]** Create, update and delete requests finish in under 500 ms.
- **[Accounts]** Sessions follow the idle timeouts and logout rules in `references/security.md`.

## 13. Web Compatibility and Delivery

Read `references/web-developer-checklist.md` first. All rules here are **[Web]**.

- Support the last two versions of every major browser on every major platform, with feature detection and fallbacks, never browser sniffing.
- **[Public]** Public pages work with clean formatting when JavaScript fails.
- The standard viewport meta tag on every page. Never disable zoom.
- Print styles on every page, and dedicated print layouts for receipts, invoices, tickets and legal pages.
- Correct caching and security headers, a full favicon set, and a valid Vercel configuration.

## 14. Accounts, Sign-In and Onboarding

Read `references/accounts-and-onboarding.md` first. All rules here are **[Accounts]**.

- Email and password sign-in plus the provider sign-ins that fit the app type, with official provider buttons.
- Passwords of 12 or more characters with a capital letter, number and symbol, checked against breached passwords. Two-factor authentication offered in every app, and required for admins and sensitive data.
- Sign-in, sign-up and reset never reveal whether an account exists.
- Interactive onboarding that asks only what's needed, a dedicated account section with data download and deletion, and cancelling or deleting in no more steps than signing up.

## 15. Components and Layouts

Read `references/components.md` and `references/layout-patterns.md` first.

- Cards only for collections of separate items. Every card has an image or icon, cards in a group match in structure and height, a clickable card has one stretched link, and card text never overlaps.
- Navbar icon buttons show only the icon at rest, with a tonal rounded square on hover and focus.
- Downloads use a button with a download icon and a label naming the file and format, without the size.
- Inline help first. Tooltips only for short hints and icon-button names, on hover and focus, with a touch equivalent, never the HTML `title` attribute.
