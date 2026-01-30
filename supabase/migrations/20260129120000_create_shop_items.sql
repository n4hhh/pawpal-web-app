-- Create shop_items table for e-commerce functionality
CREATE TABLE IF NOT EXISTS public.shop_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text,
  price numeric(10,2) NOT NULL,
  image text,
  stock integer DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- Grant permissions
GRANT ALL ON TABLE public.shop_items TO postgres;
GRANT ALL ON TABLE public.shop_items TO anon;
GRANT ALL ON TABLE public.shop_items TO authenticated;
GRANT ALL ON TABLE public.shop_items TO service_role;

-- Create index for efficient queries
CREATE INDEX IF NOT EXISTS idx_shop_items_created_at ON public.shop_items (created_at DESC);
