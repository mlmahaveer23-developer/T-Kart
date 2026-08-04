# Tribhuban Concepts — Customer App (Phase 0 + 1 + 2 + 3 + 4 + 5 + 6 + 7 + 8)

Foundation-first, vertical-slice build. Phases 0–1 laid the shared
skeleton (architecture, theme, component library); Phases 2–3 are the
first two real, working features built on top of it. Each phase below
is documented in the order it was built — read top to bottom for the
full history, or jump to the phase you care about.

## Current structure

```
lib/
  main.dart                 # bootstrap: .env, Supabase.initialize, error handler
  app.dart                  # MaterialApp.router wiring theme + GoRouter
  core/
    config/env_config.dart  # typed access to .env — secrets never hardcoded
    constants/               # app-wide non-secret constants
    theme/                   # colors, typography, spacing, radius, ThemeData
    router/                  # GoRouter + route names + auth redirect logic
    error/                   # Failure (domain) + Exception (data) types
    network/                 # connectivity abstraction
    providers/                # Supabase client, connectivity, theme-mode, onboarding
    utils/                   # logger, validators
    widgets/                  # reusable component library (Phase 1)
      buttons/ cards/ inputs/ feedback/ loaders/ layout/
      widgets.dart             # barrel export — single import for all of the above
  features/
    splash/                  # bootstrap screen — decides cold-start destination
    auth/                    # Phase 2: phone-OTP login, onboarding
    catalog/                 # Phase 3: home feed, bundle discovery, search
                              # Phase 4: bundle detail screen added here too
    cart/                    # Phase 4: cart state, persisted locally
    address/                 # Phase 5: saved delivery addresses
    orders/                  # Phase 5: checkout, order placement, order history
    rewards/                 # Phase 6: reward wallet, coupons, referrals
    profile/                 # Phase 7: account screen, sign-out, appearance
supabase/
  migrations/                # SQL schema this app depends on
```

## Phase 0 — Architecture scaffold

## Design decisions made in this phase

- **State management:** Riverpod (`flutter_riverpod` + code-gen ready via
  `riverpod_generator`, not yet used since there's no async feature logic
  yet).
- **Navigation:** GoRouter, exposed as a Riverpod provider so redirect
  logic can later depend on auth state cleanly.
- **Error handling:** data layer throws typed `Exception`s
  (`core/error/exceptions.dart`); repositories will catch these and
  return `Either<Failure, T>` (dartz) so the UI never deals with raw
  try/catch — every failure maps to an explicit state.
- **Theme:** a deliberately original palette — deep forest green +
  warm brass/gold accent on warm ivory — instead of the blue/white
  "generic delivery app" look, per the brief to not resemble
  Blinkit/Instamart/Zepto/BigBasket. Full light + dark themes are wired
  and toggleable now (see the placeholder screen).
- **Secrets:** loaded from `.env` via `flutter_dotenv`; `.env` is
  git-ignored. Copy `.env.example` → `.env` and fill in your Supabase
  project URL/anon key before running.

## Phase 1 additions

A single-import component library (`core/widgets/widgets.dart`) built
purely on the Phase 0 theme tokens — no feature imports this file's
contents needs to know a hex code or a spacing number, only the
component API:

- **AppButton** — one component, four variants (primary/secondary/danger/text),
  built-in loading spinner and disabled state instead of per-screen
  `isLoading ? Spinner() : Text()` branching.
- **AppTextField / OtpInputField** — consistent form fields; OTP field
  has auto-advance + backspace-to-previous built in, ready for Phase 2's
  verification screen.
- **AppCard / InfoBanner** — InfoBanner is the dedicated visual language
  for the rewards/coupon/referral system (gradient, distinct from
  ordinary content cards) so users learn to recognize "this is a reward"
  at a glance.
- **EmptyStateWidget / ErrorStateWidget** — ErrorStateWidget takes a
  domain `Failure` directly and picks icon/copy from its type, so a
  repository failure flows straight into the right UI with no
  translation step in feature code.
- **OfflineBanner + AppScaffold** — AppScaffold auto-mounts the offline
  banner so connectivity handling isn't something each screen has to
  remember.
- **SkeletonBox / SkeletonListTile** — shimmer-based loading placeholders
  shaped to match real content, avoiding layout jump on load.

The placeholder screen (`features/placeholder/`) has been rebuilt to use
this library end-to-end — see it for real usage examples of every
component above.

## Phase 2 additions — Auth & Onboarding

Full Clean Architecture vertical slice under `features/auth/`:

```
features/auth/
  domain/      entities/repositories/usecases — no Flutter or Supabase imports
  data/        Supabase-backed datasource, repository impl, model mapper
  presentation/ controllers (Riverpod AsyncNotifiers), screens, providers
```

**Why phone OTP, not email/password:** across tier-2/3 Indian markets,
mobile numbers are the reliable, universally-owned identifier — email is
often secondary or unused. Supabase's `signInWithOtp`/`verifyOTP` with
`phone` handles this natively.

**Screens added:**
- `OnboardingScreen` — 3-slide carousel, shown once (persisted via
  `hasSeenOnboardingProvider`, hydrated from SharedPreferences before
  `runApp` so there's no first-frame flash for returning users)
- `LoginScreen` — Indian mobile number entry (`+91` prefix applied
  automatically), validated by the `Validators.indianPhone` rule from
  Phase 0
- `OtpVerifyScreen` — uses the `OtpInputField` built in Phase 1, with a
  30-second resend cooldown timer

**Router redirect is now real**, not a passthrough:
- `SplashScreen` explicitly decides the cold-start destination (session
  found → Home; no session but onboarding seen → Login; first-ever
  launch → Onboarding) — kept explicit rather than folded into
  `redirect:` so that decision reads top-to-bottom in one place.
- `redirect:` in `app_router.dart` continuously enforces two invariants
  after splash: a signed-in user can't land back on onboarding/login/OTP,
  and a signed-out user can't reach protected routes (currently just
  `/home`).
- `GoRouterRefreshStream` (new util in `core/router/`) wires Supabase's
  auth stream into GoRouter's `refreshListenable`, so a session ending
  elsewhere (expiry, revoked token) redirects immediately, not just on
  next navigation.

**Error handling stays consistent with Phase 0's contract:** the auth
datasource throws typed exceptions → the repository converts them to
`Failure`s → controllers expose `AsyncError<Failure>` → screens read
`failure.message` directly, no new error-handling pattern introduced.

## Phase 3 additions — Home & Bundle Discovery

Another full Clean Architecture vertical slice, `features/catalog/`,
following the exact same domain → data → presentation shape as
`features/auth/`:

```
features/catalog/
  domain/      Bundle & Category entities, CatalogRepository contract, 4 usecases
  data/        Supabase datasource (bundles + categories tables), model mappers
  presentation/ Riverpod FutureProviders, HomeScreen, SearchScreen, widgets
```

**New Supabase schema:** `supabase/migrations/0001_catalog_schema.sql`
defines `categories` and `bundles` tables with public read-only RLS
policies (write access is deliberately withheld — bundles are managed
by the Retailer/Admin apps, not this one) and seed data so the screens
have something real to render against. Run this in the Supabase SQL
editor before testing Phase 3.

**HomeScreen:**
- Reward teaser banner (Phase 1's `InfoBanner`) linking to search
- Category filter chips — tapping one filters the grid below via
  `bundlesByCategoryProvider(categoryId)`
- Horizontal featured-bundles carousel
- Bundle grid, filtered by the selected category
- Pull-to-refresh invalidates and re-awaits all three data providers
- Every section has its own loading (skeleton), error (`ErrorStateWidget`
  with retry), and empty (`EmptyStateWidget`) state — none of them block
  the others, so a slow/failed featured-bundles fetch doesn't stop the
  grid from rendering

**SearchScreen:** debounced (400ms) search-as-you-type against
`ilike` on the bundles table, with the same loading/error/empty pattern.

**Bundle tap → Phase 4 stub:** tapping any `BundleCard` currently shows
a snackbar ("Bundle details arrive in Phase 4") rather than a half-built
detail screen — kept deliberately minimal so this phase doesn't leak
into the next one.

The Phase 0/1 placeholder screen (`features/placeholder/`) has been
deleted — `HomeScreen` is now the real `/home` destination, and
`/search` is a new protected route covered by the same auth redirect
logic from Phase 2.

## Phase 4 additions — Bundle Detail & Cart

Two additions this phase: `BundleDetailScreen` extends the existing
catalog feature, and a new `features/cart/` slice holds cart state.

**BundleDetailScreen** (`features/catalog/presentation/screens/`):
image, name, price, reward banner, description, and a quantity
stepper + "Add to Cart" bar pinned to the bottom. Reachable from every
`BundleCard` tap across Home, the featured carousel, and Search — the
Phase 3 "coming in Phase 4" snackbar stub is gone.

**Cart** (`features/cart/`) — same domain → data → presentation shape
as the other features:
```
features/cart/
  domain/      CartItem entity, CartRepository contract, 5 usecases
  data/        SharedPreferences-backed local datasource + repository
  presentation/ CartController (AsyncNotifier), CartScreen, widgets
```

**Why local storage, not a Supabase `cart_items` table:** a cart is
draft/pre-checkout state, not a durable record — device-local
persistence (SharedPreferences, JSON-encoded) is the right tradeoff
here. It survives app restarts but doesn't need to sync across devices
or survive a sign-out. An actual order becomes a durable, server-side
record only at checkout (Phase 5).

**Why `CartItem` stores a snapshot, not just a `bundleId`:** the cart
holds the name/price/reward/image *as the customer saw them* when they
tapped "Add to Cart" — standard e-commerce practice. This means the
cart renders instantly with no extra network round-trip, and stays
intact even if a bundle is later renamed or removed from the catalog.
The authoritative price is re-checked server-side at checkout regardless.

**CartScreen:** line items with an inline quantity stepper (0 = remove
the line), running subtotal + total reward value, and a "Proceed to
Checkout" button that's a deliberate Phase 5 stub — same "don't build
ahead" pattern as Phase 3's bundle-detail stub was.

**Home screen** now shows a live cart-count badge next to the cart icon,
driven by `cartItemCountProvider`.

## Phase 5 additions — Checkout & Orders

Two more Clean Architecture slices: `features/address/` and
`features/orders/`. Unlike the cart (Phase 4), orders and addresses ARE
durable records, so both are backed by Supabase, not local storage —
see `supabase/migrations/0002_orders_schema.sql`.

**`features/address/`** — saved delivery addresses, full CRUD:
```
domain/      Address entity, AddressRepository contract, 5 usecases
data/        Supabase datasource (per-user RLS), repository impl
presentation/ AddressController, AddressListScreen, AddressFormScreen (add + edit in one screen)
```
A user has at most one default address at a time — enforced in the
datasource (`_clearExistingDefault()`), not left as a client-side
convention that could drift.

**`features/orders/`** — checkout and order history:
```
domain/      Order/OrderItem/OrderStatus entities, OrderRepository, 3 usecases
data/        Supabase datasource (orders + order_items), repository impl
presentation/ CheckoutController, CheckoutScreen, OrderHistoryScreen, OrderDetailScreen
```

**Why orders snapshot the address instead of storing a foreign key:**
same reasoning as the cart snapshotting bundle data in Phase 4 — an
order should keep showing the address it actually shipped to, even if
the customer edits or deletes that saved address afterward. See the
migration file's comments for the full rationale.

**Order placement was originally two sequential inserts** (`orders`
row, then `order_items` rows) — flagged here as a gap and closed in the
Phase 8 hardening pass below, which moved this to a single atomic
Postgres function.

**`CheckoutController`** only clears the cart *after* a successful
order insert — a failed order placement can never wipe the customer's
cart.

**Navigation:** since there's no Profile screen yet, "My Orders" and
"My Addresses" are reachable via an overflow menu on the Home app bar
— a temporary home for them until the Profile feature gives them a
permanent one.

## Phase 6 additions — Rewards & Referral

`features/rewards/` — one more Clean Architecture slice covering three
related but distinct things: a reward wallet, a coupon catalog, and a
referral system. `supabase/migrations/0003_rewards_referrals_schema.sql`
is doing the most interesting work this phase; the Flutter code is
comparatively thin because two business rules are enforced in the
database instead of the app:

**Reward wallet is a ledger, not a stored number.** `reward_transactions`
holds every earn/redeem event; the balance shown on screen is always
`sum(earned) − sum(redeemed)`, computed at read time
(`RewardTransaction.signedAmountRupees` + a fold in
`rewardBalanceRupeesProvider`). This sidesteps the entire "stored
balance drifted from its ledger" bug class.

**Orders auto-credit rewards via a Postgres trigger**
(`handle_order_reward()` on `orders` insert), not an app-side write
after `PlaceOrderUseCase` succeeds. That means the reward can't be
skipped by a client bug, a killed app, or someone calling the API
directly instead of going through this app.

**Referral codes are generated server-side** the moment a Supabase
auth user is created (`handle_new_user_referral()` trigger on
`auth.users`), so every account has a code from first launch — no
"create one on first visit to the Referral tab" race to get wrong.

**Referral redemption is a single `SECURITY DEFINER` RPC**
(`redeem_referral_code`), not three separate client-side inserts. It
enforces every rule — code must exist, can't redeem your own code,
can't redeem twice — inside one atomic Postgres transaction. This is
the same "move it server-side" reasoning as the order-reward trigger:
a client-side version of these checks could be raced or bypassed.

**Scope decision at the time — coupons were claimed, not applied at
checkout:** this phase built claiming a coupon into "My Coupons"
(`coupon_redemptions` table, a straightforward client insert since it's
not privileged data), but stopped short of extending Phase 5's
`CheckoutScreen`/`orders` table to actually apply a discount — flagged
explicitly rather than left quietly half-done. Closed in Phase 8 below.

**Navigation:** "My Rewards" joins "My Orders"/"My Addresses" in the
temporary Home app-bar menu; the Home reward banner now links here too.

## Phase 7 additions — Profile & Settings

`features/profile/` is deliberately thin — presentation only, no
domain/data layers of its own. It doesn't own any data; it composes
things that already exist:

- **Sign-out** finally has a UI. The usecase (`SignOutUseCase`) has
  existed since Phase 2 — this phase adds `SignOutController`
  (`features/auth/presentation/controllers/`, not under `profile/`,
  since signing out is an auth action Profile merely triggers) and a
  confirmation dialog before calling it.
- **No manual navigation after sign-out is needed.** `GoRouterRefreshStream`
  (built in Phase 2) is already watching Supabase's auth stream, so the
  moment sign-out succeeds, the router's `redirect:` re-runs on its own
  and bounces the user out of the now-protected `/home` to `/login`.
- **Cart is cleared on sign-out.** The cart (Phase 4) is device-local,
  not scoped to a user account — left populated across a sign-out, it
  would leak one person's cart to whoever signs in next on a shared
  device. `ProfileScreen` clears it explicitly after a successful sign-out.
- **Appearance (light/system/dark)** moves here from where it was only
  ever demoed (the old Phase 0/1 placeholder screen) into a permanent
  home, using the same `themeModeProvider` from Phase 0.
- **My Orders / My Addresses / My Rewards** move out of the temporary
  Home app-bar overflow menu (Phases 5–6) into `ProfileMenuTile` rows
  here — their permanent home. Home's app bar now has a single Profile
  icon instead of a growing "⋮" menu.

## Phase 8 — Production hardening (atomic orders + coupons applied)

Not a new feature — a pass closing the two gaps flagged honestly back
in Phases 5 and 6, rather than leaving them as permanent caveats.
`supabase/migrations/0004_atomic_order_placement.sql`:

**Order placement is now one atomic transaction.** A new
`place_order()` `SECURITY DEFINER` function replaces the two sequential
client-side inserts from Phase 5. Postgres runs a function body as a
single transaction, so the order row and every line item either all
commit or none do — no more possibility of an order with no items if
something fails mid-flight. `OrderRemoteDataSourceImpl.placeOrder()`
now calls this RPC and fetches the resulting order by the id it returns.

**The function also recomputes the subtotal/reward from the item list
itself**, rather than trusting a client-supplied total — closing a
second, smaller gap: the old code computed `subtotal`/`reward` in Dart
and inserted them directly. Same "don't trust the client with money"
principle already used for `redeem_referral_code` in Phase 6.

**Coupons now actually apply a discount.** `place_order()` takes an
optional `p_coupon_code`, validates it (active, not expired, minimum
order met, already claimed by this user via `coupon_redemptions`), and
writes `discount_rupees`/`coupon_code` onto the order. `CheckoutScreen`
gained a Coupon section listing the user's *claimed* coupons (from
Phase 6) as a radio selection, showing the discount and strikethrough
subtotal live before the order is placed. `Order` gained a
`totalRupees` getter (`subtotalRupees − discountRupees`); order history
and detail screens now show it.

**RLS tightened accordingly:** `orders`/`order_items` had a broad "for
all" policy in Phase 5 allowing direct client inserts — since all order
creation now goes through `place_order()`, that's replaced with
select-only policies. A client can no longer write an `orders` row
directly even if it wanted to.

## Running this scaffold

```bash
cp .env.example .env        # then fill in your Supabase URL + anon key
flutter pub get
flutter run
```

**Before OTP login will actually work:** enable Phone auth in your
Supabase project (Authentication → Providers → Phone) and configure an
SMS provider (Twilio, MessageBird, or Vonage — Supabase requires one of
these to actually send the SMS). Without this, `sendOtp` will fail with
a clear `AuthFailure` surfaced on the Login screen rather than crashing.

**Before the Home screen will show real data:** run
`supabase/migrations/0001_catalog_schema.sql` in your Supabase project's
SQL editor. Without it, `HomeScreen` will show the `ErrorStateWidget` /
empty states, not crash — but you won't see any bundles.

**Before checkout/orders/addresses will work:** also run
`supabase/migrations/0002_orders_schema.sql`. Both migrations use
row-level security scoped to `auth.uid()`, so they only work correctly
once Phone auth (above) is also configured — a customer needs to
actually be signed in for any of these reads/writes to succeed.

**Before rewards/coupons/referrals will work:** also run
`supabase/migrations/0003_rewards_referrals_schema.sql`, in order after
0001 and 0002 (it references the `orders` table). This migration
creates two triggers and one `SECURITY DEFINER` function — if you're
reviewing it before running, note that's intentional (see the Phase 6
section above), not something to strip out.

**Run last:** `supabase/migrations/0004_atomic_order_placement.sql`.
It alters the `orders` table (adds `discount_rupees`/`coupon_code`),
replaces the Phase 5 order-insert RLS policies with select-only ones,
and adds the `place_order()` function that Phase 5's checkout now
calls instead of inserting directly. Running 0001–0003 without 0004
still works — checkout just won't function until it's applied too,
since `OrderRemoteDataSourceImpl` calls `place_order()` unconditionally.

You should see: splash screen → onboarding (first launch only) → phone
login → OTP verification → the real Home screen with live bundle data.
Every phase after Phase 1 plugs into the architecture/design-system
foundation from Phases 0–1 without re-deciding those fundamentals.

## Not in this phase (by design)

- No auth screens yet (Phase 2)
- No profile *editing* yet (name, email, avatar) — Phase 7 covers the
  account screen and settings, not a profile-data feature; there's no
  `profiles` table yet since nothing needs one until this exists
- No payment gateway integration — orders are placed and recorded
  (with any coupon discount applied), but there's no actual payment
  collection step yet
- No `flutter pub get` was run in this environment (no Flutter SDK
  available here) — run it locally to fetch dependencies and generate
  `pubspec.lock`

## What's next

All eight roadmap phases from the original plan are built, plus a
Phase 8 hardening pass that closed the two gaps flagged along the way
(atomic order placement, coupons actually applying a discount) rather
than leaving them as permanent caveats. From here, natural next steps
(not yet scoped into a phase) would be: a `profiles` table for
editable name/email, payment gateway integration, push notifications
for order status changes, and building out the Retailer and Admin
codebases this customer app is one of three pieces of.
