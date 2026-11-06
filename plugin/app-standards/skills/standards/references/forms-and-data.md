# Forms and Data

Read this before building any form, input, data display or database schema.

## Input Reference

| Field | `type` | `inputmode` | `autocomplete` | `enterkeyhint` | `spellcheck` |
|---|---|---|---|---|---|
| Email | email | | email | next | false |
| Phone | tel | | tel | next | false |
| Website | url | | url | next | false |
| Full name | text | | name | next | false |
| First / last name | text | | given-name / family-name | next | false |
| Street address | text | | address-line1 | next | false |
| Postal code (US only) | text | numeric | postal-code | next | false |
| Postal code (international) | text | | postal-code | next | false |
| Card number | text | numeric | cc-number | next | false |
| Card expiry | text | numeric | cc-exp | next | false |
| Card security code | text | numeric | cc-csc | next | false |
| One-time code | text | numeric | one-time-code | done | false |
| Quantity or age | number | | | next | |
| Birthday | date | | bday | next | |
| Search | search | | off | search | false |
| Username | text | | username | next | false |
| New password | password | | new-password | done | |
| Current password | password | | current-password | go | |
| Message, comment or description | textarea | | off | (see Enter Key) | true |

- The last field in a form uses `enterkeyhint="send"`, `"go"` or `"done"` to match its action.
- Never use `type="number"` for digit-only values that aren't quantities (ZIP codes, card numbers, phone numbers).
- Every field has a visible label. Placeholder text never replaces a label.
- Placeholders show an example of the expected format (such as "name@example.com"). They never end with an ellipsis.
- A checkbox or radio and its label share one generous click area. Clicking a label focuses or toggles its control, with no dead space between them.
- Fields that aren't for signing in (such as search) never use reserved names like `password`, so password managers don't offer to fill them. One-time code fields use `autocomplete="one-time-code"` and always accept pasting.
- Set `background-color` and `color` explicitly on native `<select>` elements, which avoids a dark-mode contrast bug on Windows.
- Input and textarea text is never smaller than 16px (smaller text makes iPhones zoom the page on focus).

## Flexible Input Formats
Accept every correct format, then normalize on the server.

| Field | Accepted examples | Stored as |
|---|---|---|
| Phone | (555) 123-4567, 555-123-4567, 555.123.4567, 555 123 4567, +1 555 123 4567 | E.164 (+15551234567), parsed with libphonenumber-js or similar |
| Card number | 4242 4242 4242 4242, 4242424242424242 | Never stored by the app; handled by the payment provider |
| Email | " Name@Example.com " | See email storage in `accounts-and-onboarding.md` |
| Dates typed as text | 10/20/2026, 2026-10-20, Oct 20 2026 (following the user's locale) | ISO 8601 |
| Postal code | 12345, 12345-6789, "sw1a 1aa" | Uppercased and trimmed for the country |

- Trim leading and trailing spaces from every text value before validating it. Some keyboards and text replacements add a trailing space, and the user should never see an error caused by one.
- Never block keystrokes. A numbers-only field still accepts any typing, then explains what's wrong.
- Format values for display after the user leaves the field, not while typing.
- Backspace removes exactly one character at a time in every field, including masked and formatted fields (phone, date, card), even when the field formats while typing. It never clears a whole field.
- In chip or tag inputs, Backspace removes one chip at a time, never all of them.

## Validation
- Validate each field when the user leaves it. Once an error shows, re-check live as the user types to fix it.
- Never show errors on fields the user hasn't touched.
- Show each error next to its field. When the form is submitted with errors, move focus to the first one.
- Password fields validate on every keystroke, with the requirement checklist underneath (requirements in `accounts-and-onboarding.md`) and a show/hide toggle.
- Validate on the server as well. Client validation is only for fast feedback.

## Submitting
- Never disable the submit button before submission. Clicking it on an incomplete form shows what's missing.
- Disable it only while the request is in progress, with a spinner in the button and an idempotency key (see `ux-patterns.md`).

## Enter Key
- In a form with a single text field, Enter submits.
- In a form with several fields, Enter in the last field submits.
- Textareas follow the convention for their purpose:
  - **Message and prompt composers** (chat, comments in a conversation, AI prompts): Enter sends; Shift + Enter adds a new line.
  - **Long-form text** (descriptions, notes, articles, bios): Enter adds a new line; ⌘ + Enter (Mac) or Ctrl + Enter (Windows and Linux) submits.
- Show the shortcut near the field when it isn't obvious, with the right key symbol for the platform.

## Search
- Results appear 300 ms after the last keypress.
- Pressing Enter searches immediately and cancels any pending delayed search.

## Dates
- Use the native date input for simple dates.
- Use a custom picker only for ranges or bookings, and it must be fully keyboard and screen reader accessible.

## Age and Birthday
- **[Accounts]** Collect age at sign-up, or a full birthday for apps handling sensitive data (health, financial, precise location, government ID, or anything involving minors).
- The minimum age follows the regions the builder gives in the legal questions (some regions set the age of digital consent at up to 16). Default to 13 when no region is known.
- Sign-up methods that skip the field (such as Google) collect it as the first onboarding step, and the app stays locked until it is provided.

## Uploads
- **[Uploads]** Enforce a file size limit (10 MB per file unless specified).
- Check file format and size in the browser for fast feedback, then again on the server to block dangerous files.

## Data Display
- Format dates, numbers and currency with the `Intl` APIs in the user's locale.
- Never show ambiguous dates such as 10/11/26. Write "Oct 11, 2026" or follow the user's locale.
- Show currency with its symbol or code. Within one context, use either 0 or 2 decimal places for every price, never a mix.
- Put machine-readable values in `<time datetime>` and `<data value>`.
- Right-align numeric table columns and use tabular figures.
- Use one display format for each data type across the whole application.

## Data Storage
Backend and database formatting must be as clean as the frontend.
- Store timestamps as `timestamptz` in UTC. Convert to the user's time zone only for display.
- Store money as integer minor units (cents) or `numeric`, always with a currency code. Never as floating point.
- Store phone numbers in E.164.
- Use consistent `snake_case` names for tables and columns.
- Use foreign keys, `NOT NULL`, `CHECK` and unique constraints so invalid data cannot be saved.
- Use enums or lookup tables for fixed values such as statuses.
- Make every schema change through a versioned migration.
- API responses use one consistent JSON shape across all endpoints, with ISO 8601 dates and no fields the screen doesn't need.
