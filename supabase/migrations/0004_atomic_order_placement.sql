-- Phase 8 (hardening): atomic order placement + coupon discounts applied
-- at checkout. Run after 0001, 0002, and 0003.
--
-- This migration closes two gaps flagged during Phase 5 and Phase 6:
--   1. Order placement was two sequential client-side inserts (orders,
--      then order_items) — a mid-flight failure could leave an order
--      with no items. It's now one SECURITY DEFINER function, which
--      Postgres runs as a single transaction: either everything commits
--      or nothing does.
--   2. Coupons could be claimed but never actually reduced an order's
--      total. place_order() now validates and applies one, computing
--      the discount server-side rather than trusting a client-supplied
--      number — the same "don't trust the client with money" principle
--      already used for reward amounts.

alter table orders add column if not exists discount_rupees int not null default 0;
alter table orders add column if not exists coupon_code text;

-- Order creation now only ever happens inside place_order() below, so
-- the broad "for all" policy from 0002 is replaced with select-only.
-- (Status transitions — confirmed/packed/shipped/etc — are an Admin
-- app concern, not this customer app's, so no update policy is added
-- here either.)
drop policy if exists "Users manage their own orders" on orders;
create policy "Users view their own orders"
  on orders for select
  using (auth.uid() = user_id);

drop policy if exists "Users manage their own order items" on order_items;
create policy "Users view their own order items"
  on order_items for select
  using (exists (
    select 1 from orders o
    where o.id = order_items.order_id and o.user_id = auth.uid()
  ));

create or replace function public.place_order(
  p_items jsonb,
  p_recipient_name text,
  p_phone text,
  p_address_line1 text,
  p_address_line2 text,
  p_city text,
  p_state text,
  p_pincode text,
  p_coupon_code text default null
)
returns uuid
language plpgsql
security definer
as $$
declare
  v_user_id uuid := auth.uid();
  v_subtotal int := 0;
  v_reward int := 0;
  v_discount int := 0;
  v_coupon coupons%rowtype;
  v_order_id uuid;
  v_item jsonb;
begin
  if v_user_id is null then
    raise exception 'You must be signed in to place an order.';
  end if;

  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'Cannot place an order with no items.';
  end if;

  -- Recompute subtotal/reward from the items themselves rather than
  -- trusting a client-supplied total — a client bug or tampered
  -- request can send bad prices, but it can't change what's actually
  -- in this jsonb array's price_rupees/quantity fields being summed here.
  for v_item in select * from jsonb_array_elements(p_items)
  loop
    v_subtotal := v_subtotal + ((v_item->>'price_rupees')::int * (v_item->>'quantity')::int);
    v_reward := v_reward + (coalesce((v_item->>'reward_value_rupees')::int, 0) * (v_item->>'quantity')::int);
  end loop;

  if p_coupon_code is not null and length(trim(p_coupon_code)) > 0 then
    select * into v_coupon from coupons
      where code = upper(trim(p_coupon_code))
        and is_active = true
        and (expires_at is null or expires_at > now());

    if not found then
      raise exception 'That coupon is not valid or has expired.';
    end if;

    if v_subtotal < v_coupon.min_order_rupees then
      raise exception 'This coupon needs a minimum order of ₹%.', v_coupon.min_order_rupees;
    end if;

    if not exists (
      select 1 from coupon_redemptions
      where user_id = v_user_id and coupon_id = v_coupon.id
    ) then
      raise exception 'Claim this coupon before using it at checkout.';
    end if;

    v_discount := least(v_coupon.discount_rupees, v_subtotal);
  end if;

  insert into orders (
    user_id, status, subtotal_rupees, discount_rupees, reward_value_rupees,
    coupon_code, recipient_name, phone, address_line1, address_line2,
    city, state, pincode
  ) values (
    v_user_id, 'placed', v_subtotal, v_discount, v_reward,
    case when v_coupon.id is null then null else v_coupon.code end,
    p_recipient_name, p_phone, p_address_line1, p_address_line2,
    p_city, p_state, p_pincode
  )
  returning id into v_order_id;
  -- The on_order_created_reward trigger (from 0003) fires here
  -- automatically and credits reward_value_rupees to the wallet — no
  -- separate reward-crediting logic needed in this function.

  insert into order_items (
    order_id, bundle_id, bundle_name, price_rupees, reward_value_rupees, quantity
  )
  select
    v_order_id,
    nullif(item->>'bundle_id', '')::uuid,
    item->>'bundle_name',
    (item->>'price_rupees')::int,
    coalesce((item->>'reward_value_rupees')::int, 0),
    (item->>'quantity')::int
  from jsonb_array_elements(p_items) as item;

  return v_order_id;
end;
$$;
