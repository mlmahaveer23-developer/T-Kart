-- Phase 5: Addresses + Orders schema
-- Run after 0001_catalog_schema.sql, in the Supabase SQL editor or via
-- `supabase db push`.

create table if not exists addresses (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references auth.users(id) on delete cascade,
  label           text not null default 'Home',
  recipient_name  text not null,
  phone           text not null,
  line1           text not null,
  line2           text,
  city            text not null,
  state           text not null,
  pincode         text not null,
  is_default      boolean not null default false,
  created_at      timestamptz not null default now()
);

create index if not exists idx_addresses_user_id on addresses(user_id);

alter table addresses enable row level security;

create policy "Users manage their own addresses"
  on addresses for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Orders intentionally snapshot the shipping address (recipient_name,
-- phone, address lines, city, state, pincode) rather than storing a
-- foreign key to `addresses`. This mirrors the cart's snapshot
-- philosophy: an order should keep showing the address it was actually
-- shipped to, even if the customer later edits or deletes that saved
-- address. It also avoids a join every time order history is read.
create table if not exists orders (
  id                    uuid primary key default gen_random_uuid(),
  user_id               uuid not null references auth.users(id) on delete cascade,
  status                text not null default 'placed',
  subtotal_rupees       int not null,
  reward_value_rupees   int not null default 0,
  recipient_name        text not null,
  phone                 text not null,
  address_line1         text not null,
  address_line2         text,
  city                  text not null,
  state                 text not null,
  pincode               text not null,
  created_at            timestamptz not null default now()
);

create index if not exists idx_orders_user_id on orders(user_id);
create index if not exists idx_orders_created_at on orders(created_at desc);

alter table orders enable row level security;

create policy "Users manage their own orders"
  on orders for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Order line items also snapshot bundle name/price/reward at time of
-- purchase — same rationale as the cart and the address above.
create table if not exists order_items (
  id                    uuid primary key default gen_random_uuid(),
  order_id              uuid not null references orders(id) on delete cascade,
  bundle_id             uuid references bundles(id) on delete set null,
  bundle_name           text not null,
  price_rupees          int not null,
  reward_value_rupees   int not null default 0,
  quantity              int not null
);

create index if not exists idx_order_items_order_id on order_items(order_id);

alter table order_items enable row level security;

create policy "Users manage their own order items"
  on order_items for all
  using (exists (
    select 1 from orders o
    where o.id = order_items.order_id and o.user_id = auth.uid()
  ))
  with check (exists (
    select 1 from orders o
    where o.id = order_items.order_id and o.user_id = auth.uid()
  ));

-- Allowed status values, enforced at the app layer (see
-- OrderStatus in the Flutter code) rather than a DB check constraint,
-- so new statuses (e.g. "out_for_delivery") don't require a migration.
-- Valid values: placed, confirmed, packed, shipped, delivered, cancelled
