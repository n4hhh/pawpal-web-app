-- PawPals canonical DB schema for Supabase (Postgres)
-- Run this in Supabase SQL Editor (Project -> SQL -> New query -> Run)
-- It creates tables, relations, sample seed data and example RLS policies.

-- Enable helper extension for gen_random_uuid
create extension if not exists "pgcrypto";

-- USERS
create table if not exists public.users (
  id uuid primary key default gen_random_uuid(),
  email text unique,
  username text unique,
  display_name text,
  avatar text,
  bio text,
  created_at timestamptz default now()
);

-- PETS
create table if not exists public.pets (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid references public.users(id) on delete set null,
  name text not null,
  age text,
  breed text,
  location text,
  image text,
  bio text,
  created_at timestamptz default now()
);

-- FEED POSTS
create table if not exists public.feed_posts (
  id uuid primary key default gen_random_uuid(),
  pet_id uuid references public.pets(id) on delete set null,
  pet_name text,
  owner_name text,
  avatar text,
  image text,
  caption text,
  likes integer default 0,
  comments integer default 0,
  time_ago text,
  created_at timestamptz default now()
);

-- MATCHES (store swipes / matches between pets/users)
create table if not exists public.matches (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.users(id) on delete cascade,
  pet_id uuid references public.pets(id) on delete cascade,
  status text default 'pending', -- pending, liked, matched, passed
  created_at timestamptz default now()
);

-- MESSAGES (chat between users)
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid,
  sender_id uuid references public.users(id) on delete set null,
  recipient_id uuid references public.users(id) on delete set null,
  body text,
  delivered boolean default false,
  created_at timestamptz default now()
);

-- SHOP ITEMS
create table if not exists public.shop_items (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  price numeric(10,2) not null,
  image text,
  stock integer default 0,
  created_at timestamptz default now()
);

-- PURCHASES
create table if not exists public.purchases (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.users(id) on delete set null,
  item_id uuid references public.shop_items(id) on delete set null,
  quantity integer default 1,
  amount_paid numeric(10,2),
  created_at timestamptz default now()
);

-- Indexes for common queries
create index if not exists idx_pets_owner on public.pets(owner_id);
create index if not exists idx_feed_posts_created on public.feed_posts(created_at desc);
create index if not exists idx_messages_conv on public.messages(conversation_id);

-- SAMPLE SEED (optional)
insert into public.users (email, username, display_name, avatar, bio)
values
('sarah@example.com','sarah_pawsome','Sarah','https://picsum.photos/64','Dog lover and photographer'),
('mike@example.com','cat_dad_mike','Mike','https://picsum.photos/64','Cat dad and baker')
on conflict do nothing;

-- If pets table empty, insert sample pets (referencing seeded users if present)
insert into public.pets (owner_id, name, age, breed, location, image, bio)
select u.id, v.name, v.age, v.breed, v.location, v.image, v.bio
from (
  values
  ('Max','2 yrs','Golden Retriever','2 miles away','https://picsum.photos/400','I love long walks and belly rubs!'),
  ('Whiskers','1 yr','Orange Tabby','5 miles away','https://picsum.photos/401','Professional napper and treat connoisseur.'),
  ('Bruno','8 mo','French Bulldog','1 mile away','https://picsum.photos/402','Snort expert and zoomies champion!')
) as v(name, age, breed, location, image, bio)
cross join lateral (select id from public.users order by created_at limit 1) as u
on conflict do nothing;

-- Example RLS policy to allow anonymous SELECT on read-only tables (dev only)
-- Enable RLS and create permissive policy for feed and pets for quick dev checks
-- Uncomment and run if you want to enable RLS and permit anon select
-- alter table public.feed_posts enable row level security;
-- create policy "Allow select for anon" on public.feed_posts for select using (true);
-- alter table public.pets enable row level security;
-- create policy "Allow select for anon pets" on public.pets for select using (true);

-- Notes:
-- - For production, create strict RLS policies and use Supabase Auth. Use service role for server-side operations.
-- - Supabase auto-generates REST endpoints at /rest/v1/<table> so frontend can call e.g. /rest/v1/feed_posts?select=*
-- - Use Supabase Storage for hosting images; store public URLs in image fields or use signed URLs for private content.
