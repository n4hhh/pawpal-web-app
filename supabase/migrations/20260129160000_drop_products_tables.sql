-- Drop legacy product catalog tables (replaced by shop_items)

drop table if exists public.product_category_map cascade;
drop table if exists public.product_categories cascade;
drop table if exists public.products cascade;
