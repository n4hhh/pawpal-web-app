-- Update shop_items: remove legacy image column, add category and rating metadata
alter table if exists public.shop_items
  drop column if exists image,
  add column if not exists category text,
  add column if not exists rating numeric(2,1) default 4.5,
  add column if not exists reviews_count integer default 0;

create index if not exists idx_shop_items_category on public.shop_items (category);
