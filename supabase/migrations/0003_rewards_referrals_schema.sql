-- Phase 6: Rewards, Coupons, Referrals schema
-- Run after 0001 and 0002, in the Supabase SQL editor or via
-- `supabase db push`.

-- ============================================================
-- Reward wallet — a ledger, not a stored balance. The balance is
-- always `sum(earned) - sum(redeemed)`, computed at read time (see
-- RewardsRemoteDataSource in the Flutter code). This avoids the
-- classic "stored balance drifts from its ledger" bug class entirely.
-- ============================================================
create table if not exists reward_transactions (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references auth.users(id) on delete cascade,
  type            text not null check (type in ('earned', 'redeemed')),
  amount_rupees   int not null,
  description     text not null,
  order_id        uuid references orders(id) on delete set null,
  created_at      timestamptz not null default now()
);

create index if not exists idx_reward_transactions_user_id on reward_transactions(user_id);

alter table reward_transactions enable row level security;

create policy "Users read their own reward transactions"
  on reward_transactions for select
  using (auth.uid() = user_id);

-- No insert/update/delete policy for the authenticated role: reward
-- transactions are only ever written by the trigger below or the
-- redeem_referral_code() function, both SECURITY DEFINER — never
-- directly by client code. This stops a compromised or buggy client
-- from crediting itself rewards.

-- Auto-credit the reward earned on an order the moment it's placed —
-- keeps this business rule enforced in the database, not just in the
-- Flutter app, so it can't be bypassed by calling the API directly.
create or replace function public.handle_order_reward()
returns trigger as $$
begin
  if new.reward_value_rupees > 0 then
    insert into reward_transactions (user_id, type, amount_rupees, description, order_id)
    values (new.user_id, 'earned', new.reward_value_rupees, 'Reward from your order', new.id);
  end if;
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_order_created_reward on orders;
create trigger on_order_created_reward
  after insert on orders
  for each row execute function public.handle_order_reward();

-- ============================================================
-- Coupons — admin-managed catalog (same pattern as bundles/categories:
-- public read, no client write access).
-- ============================================================
create table if not exists coupons (
  id                 uuid primary key default gen_random_uuid(),
  code               text unique not null,
  description        text not null,
  discount_rupees    int not null,
  min_order_rupees   int not null default 0,
  expires_at         timestamptz,
  is_active          boolean not null default true,
  created_at         timestamptz not null default now()
);

alter table coupons enable row level security;

create policy "Public can read coupons"
  on coupons for select
  using (true);

-- Which coupons a given user has claimed ("added to My Coupons").
-- Claiming is a direct client insert (unlike reward_transactions) —
-- it's not a privileged action, just bookmarking an already-public
-- coupon for later use at checkout.
create table if not exists coupon_redemptions (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references auth.users(id) on delete cascade,
  coupon_id     uuid not null references coupons(id) on delete cascade,
  redeemed_at   timestamptz not null default now(),
  unique (user_id, coupon_id)
);

alter table coupon_redemptions enable row level security;

create policy "Users manage their own coupon redemptions"
  on coupon_redemptions for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Seed a couple of coupons so Phase 6 has something to render against.
insert into coupons (code, description, discount_rupees, min_order_rupees)
select 'WELCOME100', '₹100 off your next order', 100, 500
where not exists (select 1 from coupons where code = 'WELCOME100');

insert into coupons (code, description, discount_rupees, min_order_rupees)
select 'BUNDLE50', '₹50 off any grocery bundle', 50, 0
where not exists (select 1 from coupons where code = 'BUNDLE50');

-- ============================================================
-- Referrals
-- ============================================================
create table if not exists referrals (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null unique references auth.users(id) on delete cascade,
  code        text unique not null,
  created_at  timestamptz not null default now()
);

alter table referrals enable row level security;

create policy "Users read their own referral code"
  on referrals for select
  using (auth.uid() = user_id);

-- Every new user automatically gets a referral code — generated
-- server-side so it's guaranteed to exist and be unique, rather than
-- relying on the app to create one on first visit to the Referral tab.
create or replace function public.handle_new_user_referral()
returns trigger as $$
declare
  generated_code text;
begin
  generated_code := upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 8));
  insert into public.referrals (user_id, code) values (new.id, generated_code)
  on conflict (user_id) do nothing;
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created_referral on auth.users;
create trigger on_auth_user_created_referral
  after insert on auth.users
  for each row execute function public.handle_new_user_referral();

-- Who referred whom, and what each side earned for it.
create table if not exists referral_redemptions (
  id             uuid primary key default gen_random_uuid(),
  referrer_id    uuid not null references auth.users(id) on delete cascade,
  referee_id     uuid not null references auth.users(id) on delete cascade,
  reward_rupees  int not null default 100,
  created_at     timestamptz not null default now(),
  unique (referee_id) -- a user can be referred at most once, ever
);

alter table referral_redemptions enable row level security;

create policy "Users read referrals they made"
  on referral_redemptions for select
  using (auth.uid() = referrer_id);

-- No insert policy: rows are only ever created by redeem_referral_code()
-- below, which runs as SECURITY DEFINER and enforces every business
-- rule (can't self-refer, can't redeem twice, code must exist) inside
-- a single atomic transaction — impossible to bypass or race from the
-- client, unlike doing these checks in Dart before three separate
-- client-side inserts.
create or replace function public.redeem_referral_code(p_code text)
returns void as $$
declare
  v_referrer_id uuid;
  v_referee_id uuid := auth.uid();
begin
  if v_referee_id is null then
    raise exception 'You must be signed in to redeem a referral code.';
  end if;

  select user_id into v_referrer_id from referrals where code = upper(p_code);

  if v_referrer_id is null then
    raise exception 'That referral code was not found.';
  end if;

  if v_referrer_id = v_referee_id then
    raise exception 'You cannot redeem your own referral code.';
  end if;

  if exists (select 1 from referral_redemptions where referee_id = v_referee_id) then
    raise exception 'You have already redeemed a referral code.';
  end if;

  insert into referral_redemptions (referrer_id, referee_id, reward_rupees)
  values (v_referrer_id, v_referee_id, 100);

  insert into reward_transactions (user_id, type, amount_rupees, description)
  values (v_referrer_id, 'earned', 100, 'Referral bonus — a friend joined using your code');

  insert into reward_transactions (user_id, type, amount_rupees, description)
  values (v_referee_id, 'earned', 50, 'Welcome bonus for using a referral code');
end;
$$ language plpgsql security definer;
