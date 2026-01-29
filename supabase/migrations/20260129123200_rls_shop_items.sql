-- RLS policies for shop_items (public read only)
alter table if exists public.shop_items enable row level security;
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'shop_items'
      AND policyname = 'ShopItems: public select'
  ) THEN
    CREATE POLICY "ShopItems: public select" ON public.shop_items
      FOR SELECT USING (true);
  END IF;
END $$;
