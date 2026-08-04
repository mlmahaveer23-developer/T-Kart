-- Phase 3: Catalog schema (categories + bundles)
-- Run this in the Supabase SQL editor, or via `supabase db push` if
-- you're using the Supabase CLI locally.

create table if not exists categories (
  id           uuid primary key default gen_random_uuid(),
  name         text not null,
  icon_key     text not null default 'category',
  sort_order   int not null default 0,
  created_at   timestamptz not null default now()
);

create table if not exists bundles (
  id                    uuid primary key default gen_random_uuid(),
  category_id           uuid references categories(id) on delete set null,
  name                  text not null,
  description           text not null default '',
  price_rupees          int not null,
  reward_value_rupees   int not null default 0,
  image_url             text,
  is_featured           boolean not null default false,
  created_at            timestamptz not null default now()
);

create index if not exists idx_bundles_category_id on bundles(category_id);
create index if not exists idx_bundles_is_featured on bundles(is_featured);

-- Public read access: catalog browsing doesn't require auth. Write
-- access is intentionally NOT granted here — bundles/categories are
-- managed via the Retailer/Admin apps (separate codebases), not the
-- customer app.
alter table categories enable row level security;
alter table bundles enable row level security;

create policy "Public can read categories"
  on categories for select
  using (true);

create policy "Public can read bundles"
  on bundles for select
  using (true);

-- Seed data — replace with real bundles once the Admin dashboard can
-- manage these; this exists so Phase 3 has something to render against.
insert into categories (name, icon_key, sort_order) values
  ('Staples', 'staples', 1),
  ('Snacks', 'snacks', 2),
  ('Personal Care', 'personal_care', 3),
  ('Household', 'household', 4)
on conflict do nothing;

insert into bundles (name, description, price_rupees, reward_value_rupees, is_featured, category_id)
select
  'Monthly Grocery Bundle',
  'Atta, rice, dal, oil, and daily essentials for a family of 4.',
  4999,
  2500,
  true,
  (select id from categories where name = 'Staples' limit 1)
where not exists (select 1 from bundles where name = 'Monthly Grocery Bundle');

insert into bundles (name, description, price_rupees, reward_value_rupees, is_featured, category_id)
select
  'Snacks & Beverages Pack',
  'A curated mix of packaged snacks, tea, and beverages.',
  1299,
  200,
  true,
  (select id from categories where name = 'Snacks' limit 1)
where not exists (select 1 from bundles where name = 'Snacks & Beverages Pack');

insert into bundles (name, description, price_rupees, reward_value_rupees, is_featured, category_id)
select
  'Home Care Essentials',
  'Detergent, dish soap, floor cleaner, and more.',
  899,
  0,
  false,
  (select id from categories where name = 'Household' limit 1)
where not exists (select 1 from bundles where name = 'Home Care Essentials');
