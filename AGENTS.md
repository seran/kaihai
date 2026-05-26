# Project Conventions

This is a Rails 8.1 application using Hotwire (Turbo + Stimulus), Propshaft,
and Tailwind CSS 4 via tailwindcss-rails (CSS-first config in
`app/assets/tailwind/application.css`). Vanilla Rails views — no
ViewComponents. Follow vanilla Rails conventions and the 37signals "rich
models, thin controllers" style.

**Design system, tokens, partials, layout chrome, and visual conventions live in [`DESIGN.md`](DESIGN.md).**

## Generators

- Always use Rails generators (`bin/rails g`) for models, controllers, migrations, mailers, jobs, and channels. Never hand-write the boilerplate.
- To remove a generated resource, use `bin/rails d` (destroy) — never `rm` the files by hand.
- After generating a migration, run `bin/rails db:migrate`.
- Use UUIDs as primary keys for new tables unless told otherwise.

## Database

- **Always go through `bin/rails` for database changes** — `bin/rails g migration`, `bin/rails db:migrate`, `bin/rails db:rollback`. Never reach for `sqlite3`, raw SQL files, or manual edits to `db/schema.rb`. The migration is the source of truth; if schema and migrations disagree, re-run migrations rather than editing the dump.
- **Always create migrations via `bin/rails g migration`**, never hand-write the file. The generator names the file with the right timestamp; hand-named files break Rails' ordering, and `references` / `polymorphic` shorthands typed by hand silently produce the wrong DDL.
- **Editing an already-applied migration is only safe before it ships.** To replay a single edited migration: `bin/rails db:migrate:redo VERSION=<timestamp>`. Confirm with `bin/rails runner "puts Model.column_names.inspect"`, not by reading `schema.rb`. `db:drop db:create db:migrate` is an alternative but Rails 8 may load `schema.rb` instead of replaying migrations against the empty DB. **Never** edit a migration that has run in any non-throwaway environment — write a new migration.
- For inspection, prefer `bin/rails db:migrate:status`, `bin/rails dbconsole`, or `bin/rails runner` over raw `sqlite3`. The Rails wrappers honor environment, credentials, and connection config across dev/test/production.

## Controllers

- Keep controllers thin. They orchestrate; they do not contain business logic.
- Prefer CRUD actions (`index`, `show`, `new`, `create`, `edit`, `update`, `destroy`) over custom action names. If you need a custom verb, create a nested resource controller (e.g. `Cards::ClosuresController#create` instead of `CardsController#close`).
- Extract shared before_actions and helpers into controller concerns under `app/controllers/concerns/`. Name them by what they scope or do (`CardScoped`, `BoardScoped`, `CurrentRequest`, `TurboFlash`).
- Authorization lives on the model (`user.can_administer_card?(card)`); the controller just calls it in a `before_action` and returns `:forbidden`.

## Models

- Rich models. Put business logic, state transitions, and queries on the model — not in service objects, not in controllers.
- Break large models up with concerns under `app/models/concerns/`.
- Prefer "state as a record" over boolean flags. A `Closure` record is better than a `closed_at` timestamp when the state has its own metadata or lifecycle.
- Use `Current` (ActiveSupport::CurrentAttributes) for request context like `Current.user`, `Current.ip_address`, `Current.request_id`. Don't pass these as parameters through every layer.
- **Keep `docs/DOMAIN.md` in sync.** Whenever you add a model, add or remove a column, change an association/validation/scope/enum, or introduce non-obvious behavior on a model, update `docs/DOMAIN.md` in the same change. Treat drift as a regression.

## Hotwire & Views

- Use Turbo Frames and Turbo Streams. Reach for Stimulus only when server-rendered HTML genuinely isn't enough.
- Respond with `format.turbo_stream` for in-page updates and `format.html` for full navigations. Use morphing where it fits.
- Keep partials small and named after what they render. Use fragment caching with cache keys derived from the record.

### Turbo Frame `_top` breakout — the "Content missing" rule

**A link or form inside a `<turbo-frame>` that targets a URL whose response doesn't contain a matching frame must carry `data: { turbo_frame: "_top" }` to break out.** Otherwise Turbo scopes the request to the frame, can't find a matching `<turbo-frame id="…">` in the response, and renders the literal text **"Content missing"**.

Where it shows up in this codebase:
- **Sidebar frames** `sidebar-favorites` and `sidebar-notifications` — favorite-space links point at `/spaces/:handle`, Notifications at `/notifications`. Both `_top`.
- **Entry cards** (`spaces/entries/_card.html.erb`) — used inside `<turbo-frame id="space-body">`. Space-name link and content-block link both `_top`.
- **Manage-space frame** (`<turbo-frame id="space-body">`) — the cog link on `spaces/show` opens management in-frame on purpose; the "Back to @handle" link uses `data-turbo-action="advance"` to push URL state.
- **Admin user frame** (`<turbo-frame id="admin-user">`) — row links from `users-list` use `_top`; the show page's "All users" link does too.

**Rule of thumb**: when a link inside a frame goes somewhere that frame doesn't exist, escape with `_top`. When you're _intentionally_ swapping the frame in-place, pair with `data-turbo-action="advance"` so the URL still updates. Don't reach for `_top` to "fix" a broken in-frame swap — that masks a frame-naming mismatch.

### Form validation feedback (toast on failure)

**Every form submission that fails validation must surface a toast.** The user should never see a 422 render with no visible feedback.

- **HTML responses** (`render :new` / `render :edit, status: :unprocessable_entity`): set `flash.now[:alert] = form_error_message(@record)` before rendering. The layout's `_toaster` picks up flash on render.
- **Turbo Stream responses** (form lives inside a `<turbo-frame>`, so the layout — and therefore the toaster — isn't re-rendered): respond with a `turbo_stream` array that (a) replaces the form frame with the errored form and (b) appends the toast via `form_error_toast(@record)`. Both helpers live on `ApplicationController`.
- **Redirect-on-failure flows**: `redirect_to ..., alert: "..."` is sufficient — the redirected page renders the layout fresh, flash propagates, toast appears.

`form_error_message(record)` returns the record's first full error message when present, or `"Please fix the errors below."` as a fallback. Inline field errors stay where they are — the toast is in addition to, not a replacement for, the form's own error UI.

## Localization (i18n)

All user-facing strings go through Rails' built-in I18n so the app is translation-ready, even though only `:en` ships today. Discipline matters before there's a second locale, not after.

- **Views**: lazy lookup, `<%= t(".title") %>` → `en.{controller}.{action}.title`. Use the explicit form (`t("shared.user_menu.profile")`) only for shared partials and helpers.
- **Flash and controller messages**: `redirect_to ..., notice: t(".updated")`. Strings live in locale files.
- **Model attributes and validation errors**: under `activerecord.attributes.{model}.*` and `activerecord.errors.models.{model}.attributes.{attribute}.{rule}`. Don't write `message: "..."` inline in `validates`.
- **Pluralization**: `t(".count", count: n)` with `one:` / `other:` keys. No hand-rolled `count == 1 ? ...`.
- **Dates and times**: `l(t, format: :long)` against formats in `en.time.formats.*` / `en.date.formats.*`.
- **Numbers**: `number_to_human`, `number_with_delimiter`, etc.
- **Helpers we ship** (`app_name`, `app_tagline`, etc.) read from `Current.account` and don't go through I18n — they're per-installation, not per-language.

Locale files live in `config/locales/`, split by concern as they grow (`{en,users,setups,accounts}.yml`). Default locale is `:en`.

**Existing hardcoded strings** predate this rule. New code follows the convention; existing strings get migrated when the surrounding view is touched. Don't run a separate sweep migration unless explicitly asked.

**Per-user locale (future)** — follow the `time_zone` pattern: add a `locale` string column to `users`, validate against `I18n.available_locales`, expose a select on the profile form, and set `I18n.locale = Current.user&.locale` via an `around_action` in `ApplicationController`.

## Testing

- Use Minitest, not RSpec.
- Use fixtures, not FactoryBot.
- Prefer integration tests (`ActionDispatch::IntegrationTest`) that exercise full request/response cycles over heavily mocked unit tests.
- Run `bin/rails test` for the suite and `bin/rails test path/to/file.rb` for a single file.

## What to avoid

- Service objects (`app/services/`). Put the logic on the model instead.
- Devise. Use Rails 8's built-in authentication generator (`bin/rails g authentication`).
- FactoryBot, RSpec, Sidekiq, Redis, dotenv. Vanilla Rails covers these — Solid Queue for jobs, Solid Cache for cache, Solid Cable for ActionCable.
- Docker Compose for production. Use Kamal.
- Reaching for a gem before checking whether ~30 lines of plain Ruby would do the job.

## Workflow

- Before a non-trivial change, read the relevant files first and propose a plan. Don't edit blindly.
- After changes, run `bin/rails test` and `bin/rubocop` (Omakase) and fix what they flag.
- For non-trivial feature work, prefer a `git worktree` over branch-switching in place — see below.

## Worktrees

Use `git worktree` to keep a second working copy alongside the main checkout — useful for new feature work, reviewing a PR without disturbing your dev server, or running long tests in parallel.

```bash
git worktree add ../kaihai-<name> -b feature/<name>
cp config/master.key ../kaihai-<name>/config/
cp storage/development.sqlite3 ../kaihai-<name>/storage/   # or run db:schema:load + dev:prime fresh
cd ../kaihai-<name> && PORT=3001 bin/dev                   # use a non-default port if :3000 is taken
```

Cleanup when the branch is merged: `git worktree remove ../kaihai-<name>`. List active worktrees with `git worktree list`.

Gotchas:
- `config/master.key` and `storage/*.sqlite3` are gitignored — copy them across, or rebuild the DB fresh in the new tree.
- Default port 3000 collides between worktrees — set `PORT=<n>` for any additional one.
- Gems install to a shared `BUNDLE_PATH`, so `bundle install` doesn't need to re-run per worktree.

## Subsystems

The sections below describe how specific subsystems in this codebase are wired. Skim only the ones relevant to your change.

### Account (singleton, SaaS-ready)

The installation is one `Account` row (`app/models/account.rb`), holding installation-wide config (`name`, `tagline`). **Always access via `Current.account`** — never call `Account.first` or `Account.singleton` from views/helpers, so the resolver can be swapped when SaaS multi-tenancy lands.

`app_name` and `app_tagline` (`ApplicationHelper`) read `Current.account.name` / `tagline` with `"Kaihai"` / `"a quiet community"` fallbacks. Views use these helpers — never hardcode the strings.

### First-run wizard

`SetupsController` at `GET /setup` + `POST /setup` creates the founding admin + configures the singleton Account. `db/seeds.rb` is intentionally empty — production fresh installs go through the wizard, development uses `bin/rails dev:prime` (see below). The setup gate lives on `ApplicationController` as `before_action :ensure_setup_complete, prepend: true` — **`prepend` is important** so the gate runs *before* the auth gate; otherwise unauthenticated visitors of a fresh install get sent to `/sessions/new` where they can't sign in because no users exist yet.

Sample data for development (admin user, regular user, mock spaces and entries) lives in `lib/tasks/dev.rake`. The task is guarded with `raise unless Rails.env.development?`.

**Use `bin/setup` for the one-command dev path.** It runs `mise install`, OS deps (libvips + sqlite3 via brew/apt), `bundle install`, `db:prepare`, `dev:prime` (only when no users exist), `tailwindcss:build`, and then starts `bin/dev`. Flags: `--reset` (drop + recreate DB), `--skip-server` (don't auto-start). Re-running `bin/setup` on an already-set-up checkout is idempotent. Falls back gracefully if `gum` isn't installed (just uses plain output).

### Sign-up policy

There is **no public sign-up route**. Three ways a User record gets created:
1. `lib/tasks/dev.rake` (`bin/rails dev:prime`) in development.
2. The first-run wizard at `/setup` (the founding admin).
3. **Admin-issued invitations.** `Admin::Users::InvitationsController#create` builds a `User` with `email_address`, `invited_at`, `invited_by`, no password. `InvitationsMailer.invite(user)` sends the link. Invitee opens `/invitations/:token/edit` — token validity binds to `password_digest` so it self-invalidates on claim. Token expires in 24 hours.

The model encodes both states: `pending_invitation?` (invited_at present, password_digest blank) and `claimed?` (digest set). Validations on `name`, `handle`, and password presence are conditional on `pending_invitation?`. `has_secure_password validations: false` makes the empty-digest state legal.

Do not add a `users#new` / `users#create` for self-service registration without explicit direction.

### Adminland (admin namespace)

All admin-only features live under the `Admin::` controller namespace and `/admin/...` URL prefix.

- **`Admin::BaseController`** declares `before_action :require_admin` (returns `:forbidden` for non-admins). New admin controllers inherit from it — never repeat the guard inline.
- **Show ↔ Edit transitions** inside `<turbo-frame id="admin-user">` use `data-turbo-action="advance"` so URLs update. Flash notices on Turbo-Frame redirects don't render (the toaster is outside the frame); use `turbo_stream.append("toaster", ...)` if you need flash inside a frame flow.
- **Personal preferences (theme, accent, time_zone) and password are NOT editable from admin** — those are user-only via `/profile`.

### Time zones

Each user has a `time_zone` string column (default `"UTC"`). `ApplicationController` runs `Time.use_zone(Current.user&.time_zone || "UTC", &block)` via `around_action :with_user_time_zone`, so view code stays vanilla — `post.created_at.to_fs(:long)`, `Time.zone.now`, etc. return values in the user's zone for free. Don't sprinkle `.in_time_zone(...)` at call sites.

When rendering a visible timestamp, use the **37signals pattern**: `time_ago_in_words` for the visible text, wrapped in `<time datetime="<%= t.iso8601 %>" title="<%= l(t, format: :long) %>">`. Reach for a Stimulus live-updater only on surfaces where the relative phrase needs to tick (e.g. real-time chat).

For mailers/jobs that render outside the request cycle, wrap explicitly: `Time.use_zone(user.time_zone) { ... }`. Browser auto-detection is not wired up — users start at UTC and pick their zone on the profile page.

### Profile page

`/profile` (`UsersController#edit`) is the user's account page. **Personal preferences (theme, accent, time_zone, password) live here, never in Adminland.** Reached via the **Profile** entry at the top of the user menu — don't add a separate top-bar link.

The password form posts to `user_password_path` (`Users::PasswordsController#update`, namespaced under `scope :user, module: "users"` so it doesn't clash with `PasswordsController` reset). Account deletion destroys sessions + cookie + user, then redirects to `/sessions/new`.
