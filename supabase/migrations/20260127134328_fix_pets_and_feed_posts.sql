create table if not exists public.pet_preferences (
  id uuid primary key default gen_random_uuid(),
  pet_id uuid references public.pets(id) on delete cascade,
  preferred_breed text,
  preferred_age_min int,
  preferred_age_max int,
  max_distance_km int,
  created_at timestamptz default now()
);

create table if not exists public.pet_swipes (
  id uuid primary key default gen_random_uuid(),
  from_pet_id uuid references public.pets(id) on delete cascade,
  to_pet_id uuid references public.pets(id) on delete cascade,
  liked boolean not null,
  created_at timestamptz default now(),
  unique (from_pet_id, to_pet_id)
);

create table if not exists public.pet_matches (
  id uuid primary key default gen_random_uuid(),
  pet_a uuid references public.pets(id) on delete cascade,
  pet_b uuid references public.pets(id) on delete cascade,
  matched_at timestamptz default now(),
  unique (pet_a, pet_b)
);

create table if not exists public.pet_messages (
  id uuid primary key default gen_random_uuid(),
  match_id uuid references public.pet_matches(id) on delete cascade,
  sender_pet_id uuid references public.pets(id),
  content text,
  created_at timestamptz default now()
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  price numeric(10,2) not null,
  image_url text,
  stock int default 0,
  created_at timestamptz default now()
);
create table if not exists public.product_categories (
  id uuid primary key default gen_random_uuid(),
  name text not null
);

create table if not exists public.product_category_map (
  product_id uuid references public.products(id) on delete cascade,
  category_id uuid references public.product_categories(id) on delete cascade,
  primary key (product_id, category_id)
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id),
  status text default 'pending',
  total numeric(10,2),
  created_at timestamptz default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid references public.orders(id) on delete cascade,
  product_id uuid references public.products(id),
  quantity int not null,
  price numeric(10,2) not null
);
