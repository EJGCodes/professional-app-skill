---
name: new-app
description: Sets up a new application project under the app-standards rules by asking the project-start questions, recommending a stack and writing the .app-standards.json project file.
argument-hint: "[short description of the app]"
disable-model-invocation: true
---

# New App Setup

Set up a new project so every later session builds it to the app-standards rules.

## 1. Load the standards
Load the `standards` skill from this plugin. Then read:
- `${CLAUDE_PLUGIN_ROOT}/skills/standards/references/project-file.md`
- The Legal Questions section of `${CLAUDE_PLUGIN_ROOT}/skills/standards/references/legal-and-privacy.md`

## 2. Check for an existing project file
If `.app-standards.json` already exists in the project root, read it, show the user its current settings, and ask only what they want to change. Otherwise continue.

## 3. Ask the setup questions
Use the description in `$ARGUMENTS` (if given) to skip anything it already answers. Ask the rest in as few rounds as possible, using AskUserQuestion when available:
1. **Platforms:** web, desktop, iOS, Android.
2. **Features:** accounts, payments, file uploads, email or text messages, public pages or public user content. Derive the applicability tags from the answers. Add `Backend` when any feature needs a server or database, and `Data` when personal data or non-essential cookies are involved.
3. **Sensitive data:** health, financial, precise location, government ID, or anything involving minors.
4. **App type:** professional or creative. Ask only if the description doesn't make it clear.
5. **Frontend:** recommend per the Frontend and Hosting rules in the standards skill, and let the user choose.
6. **Host:** Vercel unless the user prefers another.
7. **Regions:** where the app operates or has users.
8. **Legal details:** ask whether the user wants to provide them now (legal business name, address, contact email, third-party services, retention periods, and refund terms if payments apply). Never ask for personal information about team members. If the user skips, record `"legalDetails": "pending"`.

## 4. Recommend the stack
Summarize the recommended stack (frontend, backend, host, email provider if messaging applies, payment provider if payments apply) with one line on why each fits.

## 5. Write the project file
Write `.app-standards.json` in the project root following `project-file.md`. Do not store legal details, personal information or secrets in it.

## 6. Confirm and stop
Tell the user:
- The settings recorded.
- Which rule groups apply because of their answers (for example, "Accounts rules apply: social sign-in, two-factor authentication and an account section").
- That nothing has been built yet.

Ask whether to start building. Scaffold the project only when the user says to, and then follow the standards skill for every file.
