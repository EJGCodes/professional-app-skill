# Layout Patterns

Read this before laying out any page, navbar or app shell. People expect a product to work the way the other products they use already work (Jakob's law). Follow the standard layout for the app type and the standard placement for each element. Any layout that departs from these standards requires the user's approval.

## Layout by App Type

| App type | Standard layout |
|---|---|
| Marketing site or landing page | Header, hero, content sections, footer |
| Portfolio or personal site | Header, introduction, work grid, about, contact, footer |
| Blog or content site | Header, article list or grid, article page with a single readable column, footer |
| Dashboard or SaaS app | Left sidebar navigation, top bar with search and account, main content area |
| E-commerce | Header with search and cart, product grid with filters on the left, product page with the gallery on the left and buy options on the right |
| Documentation | Header with search, left navigation, content, on-this-page links on the right |
| Settings | Category list on the left, settings panel on the right (stacked on mobile) |
| Mobile app | Top app bar, content, bottom tab bar with at most 5 tabs |
| Desktop app | Platform-standard window chrome and menus, sidebar navigation, content area |

## Navbar

**Desktop order, left to right:**
1. Logo (links home, or to the dashboard when signed in).
2. Main navigation links, ordered from most to least used.
3. Right-hand group: search, theme toggle, cart, notifications, account menu.
4. The main call to action, as the last item on the right (such as "Start free trial" or "Book a demo").

**Mobile:** logo on the left, menu icon on the right. The menu holds the main links, then the utility links, then the call to action.

**Rules:**
- Navbar icon buttons follow `components.md`.
- Keep the main navigation to about 7 links or fewer. Group the rest under a menu.
- Show the current page in the navigation with weight or a tonal background, never a colored side strip.

## Element Placement

| Element | Standard place |
|---|---|
| Logo | Top left |
| Search | Header (center or right); in dashboards, the top bar |
| Cart | Top right |
| Account and sign-in | Top right; the account menu holds profile, settings, billing and sign out |
| Notifications | Next to the account menu |
| Theme toggle | Navbar right-hand group |
| Accessibility options | Account section under "Appearance and accessibility" when signed in; on public sites, an "Accessibility" page linked from the footer |
| Settings | Account menu, opening the account section |
| Help and FAQ | Footer and account menu |
| Legal links and copyright | Bottom of the footer |
| Cookie settings | Footer |
| Primary page action | Top right of the page header in apps; below the hero copy on marketing pages |
| Form submit button | Below the last field, aligned with the fields |
| Destructive actions | Last in their group, separated from safe actions, with confirmation |
| Back navigation | Top left |

## Accessibility Settings

- The theme toggle lives in the navbar.
- Text size, high contrast and reduced motion live in the account section under "Appearance and accessibility" for signed-in users.
- Public sites put the same options on an "Accessibility" page linked from the footer, together with an accessibility statement.
- Never use a floating accessibility widget or overlay button.

## Common Pages
- Recommend a FAQ page for any application that may benefit from one (products, services, pricing, accounts, bookings). Answers come from the builder or are clearly marked placeholders.
- Add breadcrumbs to any page more than two levels deep.

## Footer

- Columns of grouped links (such as Product, Company, Resources, Legal) on desktop, stacked on mobile.
- Bottom row: copyright with the year generated automatically, legal links and cookie settings.
- Every footer link works and leads where its text says.
- Social links use official brand logos (Section 4).
