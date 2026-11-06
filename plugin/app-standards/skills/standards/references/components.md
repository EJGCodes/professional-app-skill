# Components

Read this before building cards, buttons, navbar controls, download buttons, the theme toggle, or any title. Every component also follows the color, typography and spacing rules in SKILL.md.

## Interaction States

Every interactive element has every state below that applies to it. A component with no visible hover, pressed and focus response is incomplete.

| Component | Hover | Pressed | Keyboard focus | Disabled | Loading |
|---|---|---|---|---|---|
| Primary button | Darker shade of the accent | Scales to about 0.97 | Solid outline with an offset | Faded, `not-allowed` cursor | Spinner replaces the label; width stays the same |
| Secondary button | Tonal background appears or darkens | Scales to about 0.97 | Solid outline with an offset | Faded, `not-allowed` cursor | Spinner |
| Icon button | Tonal rounded square appears behind the icon | Scales to about 0.95 | Solid outline around the rounded square | Faded | Spinner in place of the icon |
| Card | Border or background shade changes, and the card lifts 2 px with `transform` | Scales to about 0.99 | Solid outline around the whole card | Faded | Skeleton matching the card |
| Link | Underline appears or thickens | Darker shade | Solid outline | Not applicable | Not applicable |
| Input | Border darkens | Not applicable | Accent border plus solid outline | Faded, neutral background | Not applicable |
| Toggle, checkbox, radio | Tonal ring or background | Scales slightly | Solid outline | Faded | Not applicable |

- Transitions last 120 to 200 ms with an ease-out curve, using `transform`, `opacity`, `background-color`, `border-color` and `color` only.
- States never use shadows (Section 1). Depth comes from shade, border and movement.
- With reduced motion on, keep the color changes and remove the movement and scaling.
- Pointer-only states (hover) never carry information that keyboard and touch users can't get.

## Cards

### When to use cards
- Use cards for collections of separate items people browse or compare: products, projects, articles, team members, plans.
- Do not use a card for a single block of text, for data people compare across columns on desktop (use a table), or for long lists of simple items (use list rows).

### Structure
- Every card shows an image or an icon from the project's icon set. Never a card with text alone.
- Images use one fixed aspect ratio across a group (16:9 or 4:3), fill their area with `object-fit: cover` without stretching, and have alt text. When an item has no image, show a relevant icon in the same space.
- Every card in a group has the same internal order: image or icon, title, details, actions.
- At most one primary and one secondary action. More actions go in a "More options" menu.

### Clickable cards
- When the whole card opens something, the card title is the one real link, stretched over the whole card with a positioned `::after`. Never put a link or button inside another link.
- Secondary buttons on the card sit above the stretched link (with `position: relative` and a higher `z-index`) and work on their own.
- The card shows the card states in the interaction table.

### Grids
- Use CSS grid with `repeat(auto-fill, minmax(<min>, 1fr))` so columns adjust to the available width.
- Cards in a row are the same height. Make each card a flex column and push the actions to the bottom with `margin-top: auto`, so actions line up even when the text above them differs in length.
- Use the same gap between cards as the spacing scale defines for grids.

### Spacing and text
- One padding size for all cards, from the spacing scale (16 px on mobile and 24 px on wider screens unless the design system says otherwise).
- One consistent gap between every element inside a card.
- Never position text absolutely inside a card. Text must never overlap images, badges, icons or other text.
- Body text in cards uses a line height between 1.4 and 1.6.
- Descriptions longer than the card allows are shortened in the content itself, not hidden behind an ellipsis.
- Test every card group with text 40% longer than normal, with the browser text size at 200%, and at every test width.

## Titles

- A title (page, section, card or navbar label) fits on one line on typical displays.
- On small displays (under 768 px), a title may wrap to two lines at most. Never three.
- Never cut a title off with an ellipsis.
- Keep titles Claude writes short: about 40 characters or fewer for section titles, and short enough for the card width on card titles.
- Shrink title sizes slightly on small screens with `clamp()`.
- Titles that come from users or data (a long product name) may wrap to two lines inside cards, and the card leaves room so nothing overlaps.
- Section titles describe the actual content (see `writing.md` for banned vague titles).

## Navbar Icon Buttons

Icon buttons in the navbar (search, theme toggle, menu, account, cart, notifications):
- Show only the icon at rest: no border, outline or background.
- Show a tonal rounded square behind the icon on hover and keyboard focus.
- Keep an invisible tap area of at least 44×44 px.
- Have an accessible name (`aria-label`) and a tooltip with the same text.
- Use the project's icon set, referenced by name.

## Theme Toggle

- Use the icon set's standard icons: `light_mode` and `dark_mode` in Material Symbols, or `sun` and `moon` in Font Awesome. Never custom-drawn or decorative icons.
- The icon shows the mode the user will switch to, and the label matches ("Switch to dark mode").
- It sits in the navbar's right-hand group (see `layout-patterns.md`).
- It is a navbar icon button and follows those rules.

## Download Buttons

- Downloads use a real button with a download icon (`download` in Material Symbols, `download` in Font Awesome) and a label naming the file and format, such as "Download report (PDF)". Never show the file size in the button.
- The link uses the `download` attribute, and the server sends `Content-Disposition: attachment` with the correct `Content-Type`, so the file saves instead of opening.
- Large files show download progress.
- Never a bare text link such as "here" or "download."

## Icons and Image Data

- Reference every icon from the project's icon set by name, such as `<span class="material-symbols-rounded">download</span>` or the icon set's own component. Never paste an icon's SVG drawing data (`<path d="...">`) into the code.
- Images, logos and fonts are always separate files referenced by path. Never encode them into the code as `data:` strings (such as `data:image/png;base64,...`).
- A logo the user provides as an SVG file is used as that file, not pasted inline.
