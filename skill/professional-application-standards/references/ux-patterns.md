# UX Patterns

Read this before building loading states, interactions, notices or flows.

## Loaders
Use only these:
- **Skeleton screens** for loading content. Skeletons match the dimensions of the content they replace so nothing shifts when it arrives. Server-rendered content does not need skeletons.
- **A simple circular spinner** inside a button for short actions.
- **A determinate progress bar** for measurable progress, such as uploads or onboarding steps. It sits within the content, never as a strip along the top edge of the page. Step counts ("Step 2 of 4") live inside the progress component, never in a separate chip or above a heading.

Every loader:
- Waits 150 to 300 ms before appearing, so fast responses show no loader at all.
- Once shown, stays visible for at least 300 to 500 ms, so it never flickers. (React's `<Suspense>` handles this.)
- Appears only while something is loading.
- Is replaced by the content or a clear error message when loading ends.
- Never blocks interaction with content that has already loaded.

Banned: looping arrow indicators, and any thin bar or line along the top edge of the page.

## Action Handling
1. Update the UI immediately (optimistic update).
2. Lock the control while the request runs.
3. Send an idempotency key so the server rejects duplicates.
4. If the server refuses, roll back the UI, preserve the user's input, and show a clear message.

Payments, deletions and other irreversible actions wait for the server before updating the UI.

## Interaction States
Every interactive element has distinct hover, active/pressed, focus-visible, disabled and loading states, as defined in `components.md`.

## No Dead Zones
- Anything that looks interactive is interactive, across its whole visible area.
- Never leave gaps inside a control (between an icon and its text, or a checkbox and its label) that don't respond to clicks.

## State in the URL
- Store view state in the URL: filters, sorting, tabs, pagination, search terms, expanded panels, and any other state a user would expect to survive a refresh or to share. In React apps, a URL-state library such as nuqs makes this simple.
- Refresh, sharing a link, and the Back and Forward buttons all return the user to the same view.
- Back and Forward restore the previous scroll position.

## Autofocus
- On desktop, a page whose main purpose is a single input (search, sign-in, a one-field form) focuses it on load.
- Never autofocus on mobile: the keyboard opening causes layout shift.

## Dragging and Gestures
- While something is being dragged, turn off text selection and make the rest of the page `inert`, so selection and hover effects don't happen at the same time.
- Every drag, swipe, pinch or path-based action also works with a click or tap control and with the keyboard, unless the gesture is the point of the feature (such as drawing).

## Keyboard Shortcuts
- Shortcuts work on non-QWERTY keyboard layouts.
- Show platform-specific symbols: ⌘ and ⌥ on Mac, Ctrl and Alt on Windows and Linux.
- Never override standard browser or system shortcuts.

## Motion
- Animate movement and scaling with CSS `transform`, and fades with `opacity`. Simple color transitions are allowed. JavaScript is only a helper, never the main source of an animation.
- Animate only when it clarifies cause and effect (such as interaction states and items entering or leaving) or adds deliberate, occasional delight. Never animate just to decorate.
- Choose easing for what is changing: ease-out for things entering or responding to input, ease-in for things leaving, and a gentler curve for large movements.
- Start motion from where it physically comes from: set `transform-origin` so a menu grows from its button and a tooltip from its anchor.
- Never use `transition: all`. List only the properties being animated (usually `opacity` and `transform`).
- To animate SVG, put the parts in a `<g>` wrapper, animate the wrapper, and set `transform-box: fill-box` and `transform-origin: center` (this avoids a Safari bug).
- To scale or move text, animate a wrapper element, not the text itself, so the text stays sharp. If it still blurs, add `will-change: transform` to the wrapper.
- With reduced motion on, provide a version without movement (fades or instant changes).

## User-Error Safeguards
- Minimum tap targets of 44×44 px. Links inside running text are exempt.
- A short delay before hover menus close.
- Invisible triangles (safe zones) that keep submenus open while the pointer moves toward them.
- Undo for destructive actions where possible, and confirmation for irreversible ones.
- Warnings before leaving a page with unsaved changes.
- Saved drafts for long forms: on the server for logged-in users, in memory only for logged-out users.
- User input preserved when a submission fails.
- Flexible input formats (see `forms-and-data.md`).

## Allowed Notices
Nothing appears on page load except these state-triggered notices:

| Notice | Trigger | Form |
|---|---|---|
| Cookie consent | First visit with non-essential cookies | Non-blocking bar at the bottom of the screen |
| Email verification reminder | Signed in with an unverified email | Inline non-modal banner |
| Offline message | Connection lost | Inline non-modal banner |
| Idle warning | 2 minutes before idle logout | Modal (it needs a response) |

- No notice ever covers a focused input.
- No notice is a thin strip along the top edge of the page.
- The PWA install option, when a PWA exists, sits in a menu and never appears as a prompt.

## Dark and Hidden UX Patterns
Never use:
- Pre-checked opt-in boxes.
- Confirmshaming (such as "No thanks, I don't like saving money").
- Hidden or hard-to-find cancel, unsubscribe or account deletion options.
- Fake urgency, countdowns or scarcity.
- Visually weaker "reject" or "decline" buttons.
- Trick questions and double negatives.
- Items or add-ons sneaked into a cart.
- Ads disguised as content or navigation.

## Harmful or Unnecessary UX
Never use:
- Popups, newsletter modals or permission prompts on page load.
- Auto-playing media with sound. Only muted, non-essential loops may play automatically, and any motion that plays automatically for more than 5 seconds next to other content has a pause, stop or hide control.
- Forced account creation just to browse.
- Disabled paste in any field, including passwords.
- Scroll-jacking.
- Infinite scroll that makes the footer unreachable.
- Product tours that start on their own. A guided tour is allowed only when the user starts it, and it must be keyboard accessible and close with Escape.

## Offline and Slow Networks
- Detect when the connection drops and show the offline notice.
- Keep actions taken offline in memory, with a message that they will be lost if the tab closes. Never store them in browser storage.
- Retry automatically when the connection returns, following the retry rules below.

## Reliability
- Handle failed requests and API timeouts cleanly on both frontend and backend.
- Retry only safe requests, with increasing delays and at most three attempts. Then show a clear message with a manual retry option.
- Leave no fixable console errors behind.
- Prevent memory leaks: clean up event listeners, timers, observers and pending requests when a component or page closes.
- Cache repeat requests and handle them cleanly. Write efficient scripts and bundles, and optimize database queries.
