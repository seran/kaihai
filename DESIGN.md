# Design System

## North star: consistency over local optimization

**Priority always goes to user experience and consistency.** When you're tempted to tune a per-page width, font size, padding, or color, ask whether the change makes the *transition* between pages worse. A page that feels marginally better in isolation but jolts the column-width or shifts the chrome when the user navigates to it is a regression.

Concrete corollaries:
- **Don't override the layout's max-width on individual pages.** The layout's `max-w-4xl` already governs the body column; per-view wrappers cause reflow between sibling pages. Just write `<div class="space-y-6">` and let the layout do the centering. No per-page exceptions.
- **Reach for shared partials and helpers (`button_classes`, `input_classes`, `_card`, `_input`) before hand-rolling a class string.** Two slightly-different shapes will diverge over time; one shape stays consistent.
- **When a stylistic choice is made for one surface, apply it everywhere.** If buttons lose their shadow, all buttons lose it. Don't leave half the codebase in the old style.

When in doubt, match the existing pattern; don't introduce a new one.

## App shell (layout)

Two-column shell in `app/views/layouts/application.html.erb`: a fixed-width sidebar plus a main content column. `<%= yield %>` renders directly into `<main>`.

- **Sidebar**: 260px, on the left. `position: sticky` only on desktop (≥981px). On mobile **and tablet** (≤980px) it's an off-canvas drawer, opened by the hamburger button.
- **Main**: takes the remaining width on desktop (`grid-cols-[260px_minmax(0,1fr)]`); single full-width column at ≤980px. Page content is centered with `mx-auto w-full max-w-4xl px-8 py-8`. The page-header bar above it spans the **full main-column width** with `px-8` padding (not constrained to `max-w-4xl`) so it reads as global chrome.
- **Breakpoint**: 980px is the pixel-precise desktop cutoff — use `min-[981px]:` for layout-aware utilities. Tailwind's default `md`/`lg` don't match this seam.

### Drawer mechanics

- `app/javascript/controllers/sidebar_controller.js` toggles `data-sidebar-open` on the wrapper. Actions: `sidebar#open`, `sidebar#close`, `sidebar#toggle`.
- The slide-in transform, backdrop, and body scroll-lock are CSS-only, scoped to `@media (max-width: 980px)` in `application.css` under `.app-sidebar` / `.app-backdrop`. Desktop sticky behavior is plain Tailwind utilities on the `<aside>`.

## Sidebar contents

`app/views/shared/_sidebar.html.erb` is the only place to add nav items. The sidebar header is the **Kaihai brand** (`text-2xl font-semibold`) plus the tagline _"a quiet community"_ (`text-xs text-ink-soft italic`). The same brand + tagline pair appears in the mobile hamburger header in `application.html.erb`; change them together.

**Nav-item pattern** — each `<li>` is a `link_to` that:
- Renders an outline icon (`<%= icon "..." , variant: :outline, size: 16 %>`) plus a label.
- Uses `"flex items-center gap-2 px-3 py-2 rounded-md text-base text-ink transition-colors"` plus `bg-panel` when active or `hover:bg-panel` when not. Sidebar uses `text-base` — primary navigation, not dense chrome.
- Computes active via `current_page?(some_path)` and emits `aria-current="page"`.

## Page header (in-content)

Each authenticated page gets a consistent in-content header bar (`text-2xl` title, `text-xs text-ink-soft italic` subtitle — same style as the sidebar tagline so the two read as one voice, wrapped in `leading-tight` with no `mt-*` between lines, `border-b border-ink-soft/15`) rendered automatically by the layout when the page sets:

```erb
<% content_for :page_title, "UI test page" %>
<% content_for :page_subtitle, "Every primitive in one place." %>
```

The header lives **outside** the centered body wrapper so its border-bottom runs the full main-column width. Internal padding (`px-8 pt-6 pb-4`) lives on the partial. **Don't roll your own `<h1>` in page templates** — use `content_for :page_title`. Anonymous pages (sign-in, magic-link, password) sit in the unauthenticated branch of the layout, which doesn't render the page header — those use a local `<h1>`.

**Right-side actions** — partial uses a two-column flex (`flex-1 min-w-0` title block, `shrink-0` actions block). With no `actions:` local / unset `content_for :page_actions`, the right slot renders a global `<input type="search">` (hidden below `sm`, `bg-panel`). Override per page via `content_for :page_actions { … }`. Flex uses `items-center` so actions align vertically against the (taller) title+subtitle block. Inputs and buttons share a 1px box edge for pixel-aligned baselines — see `BUTTON_BASE`.

**Title-side extras** — for per-page elements that belong *next to the title* (e.g. a favorite/star toggle on `spaces/show`), use `content_for :page_title_extras { … }`. Partial renders that block in a `flex items-center gap-2` row alongside `<h1>`. Use this when the affordance scopes to *this entity*; page-level actions like "New post" belong in `:page_actions`.

When `Current.user` is `nil` the entire shell collapses — layout skips the sidebar, hamburger header, and drawer plumbing, rendering only `<main>` full-width.

## User tile + menu

A user tile is pinned to the bottom of the sidebar (only when authenticated):
- Avatar is a `bg-accent-faint` circle with `text-accent` initials computed by `user_initials(user)` in `UiHelper` (uses `user.name` if present, falls back to `handle`).
- Top line: `user.name.presence || user.handle`. Bottom line: `@handle` in `text-ink-soft`.
- Click opens a floating popover anchored to the tile (`position: absolute; bottom: 100%`), driven by `popover_controller.js`. Controller closes on outside click and Escape; clicks inside the menu leave it open. On mobile, the menu floats above the open drawer — the drawer is **not** auto-closed.
- Menu (`app/views/shared/_user_menu.html.erb`): six "Background" swatches (`--color-paper-{name}`), six "Accent" swatches (`--color-accent-{name}`), and a `text-danger hover:bg-danger-soft` Sign out item (`button_to session_path, method: :delete`).
- Uses the unified `theme_controller.js` (`data-controller="theme"`, `data-theme-target="theme|accent"`, `data-action="theme#setTheme|setAccent"`) — same controller the test page uses, same PATCH `/user` persistence. Don't introduce a parallel controller or persistence path.
- Menu order: **Adminland** (admin-only, `link_to admin_root_path`) at the top, then **Profile** (`link_to profile_path`), divider, Background group, Accent group, Sign out. Adminland is above Profile because admins reach for it more than personal tweaks; non-admins never see it.

## Design tokens

The `@theme` block in `app/assets/tailwind/application.css` is the single source of truth. Never hardcode hex values or arbitrary Tailwind values like `bg-[#3366ff]` or `w-[437px]`. Don't add new tokens without confirming first.

### Colors

#### Themes (paper + ink)

Six themes ship: warm-light, cool-light, pure-white, warm-dark, cool-dark, pure-black. **Default is `warm-light`** — a faintly creamy paper, never pure white. **Never create new theme or accent colors, push back.**

**Surfaces** — `--color-paper` is the page background. `--color-panel` is the sub-surface (input fields, surfaces nested inside a card). The card itself stays paper-on-paper with just a border. Don't use `bg-panel` as a top-level page or sidebar background.

Each theme's paper and ink hex is also exposed individually as `--color-paper-{name}` and `--color-ink-{name}`. Use these tokens **only** for picker UIs that render every theme at once — for normal UI use `--color-paper` and `--color-ink`.

**Text tiers** — four levels, in order of emphasis:
- `--color-ink` — primary text (body copy, headings).
- `--color-ink-soft` — secondary text (helper hints, captions). Per-theme color.
- `--color-ink-faint` — tertiary text and **mono labels**. Derived as `color-mix(in srgb, var(--color-ink) 60%, var(--color-paper))` so it auto-adapts.
- (Disabled / placeholder uses per-element opacity, not a token.)

**Borders / dividers** — three intensities, derived from `--color-ink` via `color-mix(...)`:
- `--color-line` (ink at 10%) — default seam.
- `--color-line-soft` (ink at 6%) — secondary separators.
- `--color-line-faint` (ink at 2%) — barely-there hairlines.

Don't cross-use the families: `ink-*` is for text, `line-*` is for 1-px borders, `paper`/`panel` are for fills. If you need a subtle tinted fill that isn't `panel`, ask before introducing a new token.

#### Accents

The accent is the only saturated color in the UI. Six options from Tailwind colors: blue, orange, yellow, amber, emerald, violet; default `blue`. Links, primary buttons, focus rings, and active tab underline use the accent. If a per-space color is needed, use the existing space `hue` integer (avatar/glyph seed) rather than a new brand color.

Tokens for the active accent: `--color-accent`, `--color-accent-soft`, `--color-accent-contrast`, and `--color-accent-faint` (10% mix, used for the user-tile avatar and any low-emphasis accent-tinted fill). Each accent's hex is also exposed individually as `--color-accent-{name}` for picker UIs only — for normal UI use `--color-accent`.

**Favorites are always yellow.** The favorite/star button uses `text-accent-yellow` regardless of the user's accent — a star reads as a star across cultures, and the gold tone carries that meaning. This is the one sanctioned exception to the "don't use per-accent tokens for normal UI" rule.

#### Persistence

User theme and accent live on `users.theme` (default `warm-light`) and `users.accent` (default `blue`), allow-listed against `User::THEMES` / `User::ACCENTS`. The layout reads `Current.user&.theme` / `&.accent` and writes them onto `<html data-theme=… data-accent=…>` server-side, so the correct theme is on first paint — no JS flash.

Updates flow through `PATCH /user`. `theme_controller.js` handles `setTheme`, `setAccent`, and `setFamily` — theme/accent persist + update `<html>` instantly; `setFamily` is preview-only on the controller's own element (page-scoped, doesn't persist). **Do not put theme state in `localStorage`** — it causes a paint flash on hard reload because the layout hardcodes a value before JS can read storage.

For `Current.user` to be available on `allow_unauthenticated_access` actions (e.g. `/test`), the `Authentication` concern runs `resume_session` as a separate `before_action` ahead of `require_authentication` — so signed-in users get themed even on public pages.

### Spacing

Stick to the default 4pt scale (`p-1` = 4px, `p-2` = 8px, etc.). Avoid arbitrary spacing — if a value isn't on the scale, the design is probably wrong.

**Stacked cards use `space-y-8` (32px) — always.** Any vertical stack containing one or more `_card` partials, or a back-link above a card, uses `space-y-8` on the wrapper (or `class="block space-y-8"` on a `<turbo-frame>`). Don't reach for `space-y-6` or `space-y-10` on a per-page basis — the goal is constant vertical rhythm between sibling pages. Inside a card (between sections within one card) `space-y-4` or `space-y-6` is fine — the rule is about gaps **between** cards, not within them.

### Radii

**Use Tailwind classes. Don't create anything new.**
- `rounded-sm` — inputs, badges, small buttons
- `rounded-md` — cards, modals, default buttons
- `rounded-lg` — large surfaces, hero panels
- `rounded-full` — pills, avatars

### Typography

- Three families, all locally-hosted variable woff2 in `app/assets/fonts/`. Don't pull from a CDN.
  - `--font-serif`: **Source Serif 4** (default body — `--default-font-family`).
  - `--font-sans`: **Source Sans 3** (UI chrome where serif feels off — data tables, dense controls).
  - `--font-mono`: **JetBrains Mono** (use `font-mono`).
- All three are variable fonts. Use any Tailwind weight utility (`font-medium`, `font-semibold`, `font-bold`).
- Sizes: `text-xs` through `text-3xl` from the default scale.
- Headings: `font-semibold text-ink`.
- Body inherits `text-ink` from `<body>` — no class needed.
- Muted / secondary text: `text-ink-soft`. Tertiary / mono labels: `text-ink-faint`.

**Mono labels** — small uppercase grouping labels (e.g. "Background", "Accent", "With icons", input form labels, the "Member since" stamp on the profile page) all share one style: `text-xs font-mono font-medium uppercase tracking-wider text-ink-faint`. Use **`tracking-wider`** (not `tracking-wide`). When you add a new section heading or grouped-control label, reach for this exact combination.

### Iconography

- Icons vendored in `app/assets/images/icons/{outline,solid}/`.
- Inline via the `icon` helper: `<%= icon "bell", variant: :outline, size: 24, class: "text-ink-700" %>`.
- Default variant `:outline`. Pass `variant: :solid` for filled.
- Decorative icons: omit `label:` (renders aria-hidden). Meaningful icons: pass `label: "Save"` (renders `<title>` + `role="img"`).
- Color via Tailwind text utilities — icons use `currentColor`.
- Need a new icon? Run `rails icons:sync`. If still missing, create SVG under `app/assets/images/icons/custom` following https://flowbite.com/icons/ style into the matching variant folder. Don't paste raw `<svg>` into ERB.

### Shadows

- `shadow-lg` — modals, popovers, the user-menu floating panel.
- `shadow-sm`, `shadow-md` — kept in the scale but **buttons and inputs deliberately carry no shadow** — depth comes from surface tone (`bg-panel` for inputs, `bg-accent` for primary buttons). Don't add shadows back without explicit direction.

## Partial catalog

All UI primitives live in `app/views/shared/ui/`. Render with `render "shared/ui/<name>", **locals`. Read the partial source for usage examples; the rules below capture what's not obvious from reading.

**`_button`** — locals: `label:` (nil/blank + `icon:` set ⇒ square icon-only button), `variant:` (`:primary`/`:secondary`/`:ghost`/`:danger`), `type:` (default `"button"`), `extra:`, `icon:`, `icon_variant:` (default `:outline`), `icon_position:` (`:leading`/`:trailing`, default `:leading`), plus HTML attrs via `**opts`. Class via `button_classes(variant:, extra:, icon_only:)` in `ui_helper.rb`. One size only — `px-4 py-2 text-sm`, or `p-2.5` square when icon-only.

Variant rest/hover treatments — these are the rule, not suggestions:
- `primary` — filled `bg-accent`, lifts up on hover (slow ~300ms ease-out CSS animation), gently lifts down on press for a tactile feel. Animations always read slow and subtle — no hard snaps, jumps, or scale pops. No additional border once clicked.
- `secondary` — **outlined**: transparent fill at rest with `border-ink-soft/20`, fills with `bg-panel` on hover. The border is what distinguishes it from `ghost`.
- `ghost` — **no background at rest**, only `hover:bg-panel`. No border. For low-emphasis actions where even a border would be too much visual weight (close buttons, menu items, hamburger toggles).
- `danger` — filled `bg-danger`, fades opacity on hover. Reserved for destructive actions; modals confirm before submission.

Every variant inherits a 1px transparent border from `BUTTON_BASE` so all four box-heights match each other and match bordered inputs.

**`_card`** — locals: `padding:` (`:sm`/`:md`/`:lg`), `extra:`. Yields a block for content.

**`_input`** — locals: `form:`, `field:`, `label:`, `type:` (default `"text"`), `hint:`, `error:`, `icon:`, `icon_position:` (default `:leading`). Background stays `bg-panel` regardless of value. Label uses the mono-label style. **Icon-in-input color is `text-ink-faint`** (chrome tone, not the input value tone) — keep all in-input icons on this token so search inputs and form inputs read consistently.

**Class string** — don't hand-roll input/select Tailwind class strings. Use `input_classes(extra:, error:)` from `UiHelper` (mirrors `button_classes`):
```erb
<%= form.select :role, options, {}, { class: input_classes(extra: "block w-full px-3") } %>
<input class="<%= input_classes(extra: 'block w-48 pl-9 pr-3') %>">
```
The helper bakes in `text-sm py-2 border bg-panel` plus the focus ring so input height matches `button_classes`'s `text-sm py-2 border` exactly. Caller adds layout (`block`/`block w-full`) and horizontal padding (`px-3`, or `pl-9 pr-3` when there's a leading icon).

**`_radio_group`** — locals: `form:`, `field:`, `options:` (array of `[label, value]` pairs, matching `options_for_select`), `label:`, `hint:`. Renders as a segmented control: a `bg-panel` tray with the active option "punched out" to `bg-paper` + `border-ink-soft/30`. Inactive options are `text-ink-soft hover:text-ink` with a transparent border so box height stays identical between states. The underlying `<input type="radio">` is `sr-only`; the `<label>` is the click target. Use anywhere a small fixed set of mutually-exclusive options would otherwise be a `<select>`.

**`_badge`** — locals: `label:`, `variant:` (`:neutral`/`:success`/`:warning`/`:danger`/`:info`). Renders `bg-{variant}-soft text-{variant} rounded-sm px-2.5 py-0.5 text-xs font-mono font-medium capitalize tracking-wider`. Padding is intentionally lop-sided — more horizontal than vertical so it reads as a tag, not a pill. Neutral falls back to `bg-panel text-ink-soft`.

**`_toaster`** — fixed top-right container with `id="toaster"`, always rendered by the layout. Renders any current `flash` entries as toasts on first paint, and serves as the Turbo Stream target for runtime toast appends.

**`_toast`** — locals: `variant:` (`:info`/`:success`/`:warning`/`:danger`), `message:`, `duration:` (ms before auto-dismiss, default `5000`). Drop-in / fade-out animations are CSS (`animate-toast-in` / `animate-toast-out` from `@theme`). The element carries `data-controller="toast"` for the auto-dismiss timer.

To push a toast from a controller action:
```ruby
render turbo_stream: turbo_stream.append("toaster",
  partial: "shared/ui/toast",
  locals: { variant: :success, message: "Saved." })
```
For real-time / cross-tab pushes, use `Turbo::StreamsChannel.broadcast_append_to(...)` against a stream the layout subscribes to via `<%= turbo_stream_from ... %>`.

Do NOT create a dedicated `ToastsController` for production code — toasts are side effects of *other* actions, not a primary resource. The `TestController#toast` action exists only to demo the pattern from the test page.

Need a new primitive? Create a partial under `app/views/shared/ui/`.

## Conventions to follow

- Reusable UI: partials in `app/views/shared/ui/` + helpers in `app/helpers/ui_helper.rb`. Page-specific markup lives with its controller's views. Stimulus controllers in `app/javascript/controllers/` for interactivity.
- Before adding new UI, check `app/views/shared/ui/` and `app/helpers/ui_helper.rb` first.
- New buttons/inputs/cards = new partial + helper method, not inline Tailwind.
- Stick to Tailwind conventions, never create custom classes.

## What this design is *not*

- Not a Slack/Discord clone. No presence dots, no typing indicators, no live activity.
- Not a Twitter clone. No retweets, no quote-posts, no follower counts.
- Not a forum. Threads are flat (one level of replies), not nested.
- Not gamified. No points, badges, streaks, or leaderboards — ever.

When a feature request risks turning Kaihai into one of the above, push back with the design principle that disqualifies it.