-- Add images array column to shop_items
alter table if exists public.shop_items
  add column if not exists images text[];
