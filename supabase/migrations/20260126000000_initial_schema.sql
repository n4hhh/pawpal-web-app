-- PawPals canonical DB schema for Supabase (Postgres)
-- Run this in Supabase SQL Editor (Project -> SQL -> New query -> Run)
-- Creates tables, relations, sample seed data and example RLS policies.

-- Enable helper extension for gen_random_uuid
create extension if not exists "pgcrypto";

-- PROFILES (application user profiles mapped to Supabase Auth users)
-- We keep a `profiles` table to store app-specific user metadata. In your app, use
-- the Supabase Auth `user.id` value as `profiles.id` when inserting/updating.
create table if not exists public.profiles (
  id uuid primary key,
  email text unique,
  username text unique,
  display_name text,
  avatar text,
  bio text,
  location text,
  created_at timestamptz default now()
);

-- PETS
create table if not exists public.pets (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid references public.profiles(id) on delete cascade,
  name text not null,
  age text,
  breed text,
  gender text,
  size text,
  location text,
  images text[], -- array of image URLs
  avatar text, -- small avatar image
  bio text,
  is_active boolean default true,
  created_at timestamptz default now()
);

-- FEED POSTS (posts can belong to a pet or directly to a profile)
create table if not exists public.feed_posts (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid references public.profiles(id) on delete set null,
  pet_id uuid references public.pets(id) on delete set null,
  images text[],
  caption text,
  like_count integer default 0,
  comment_count integer default 0,
  created_at timestamptz default now()
);

-- COMMENTS on feed posts
create table if not exists public.comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid references public.feed_posts(id) on delete cascade,
  author_id uuid references public.profiles(id) on delete set null,
  body text not null,
  created_at timestamptz default now()
);

-- LIKES for feed posts
create table if not exists public.post_likes (
  id uuid primary key default gen_random_uuid(),
  post_id uuid references public.feed_posts(id) on delete cascade,
  profile_id uuid references public.profiles(id) on delete cascade,
  created_at timestamptz default now(),
  unique (post_id, profile_id)
);

-- SWIPES & MATCHES
create table if not exists public.swipes (
  id uuid primary key default gen_random_uuid(),
  swiper_id uuid references public.profiles(id) on delete cascade,
  pet_id uuid references public.pets(id) on delete cascade,
  direction text not null check (direction in ('left','right')),
  created_at timestamptz default now(),
  unique (swiper_id, pet_id)
);

create table if not exists public.matches (
  id uuid primary key default gen_random_uuid(),
  pet_id uuid references public.pets(id) on delete cascade,
  profile_a uuid references public.profiles(id) on delete cascade,
  profile_b uuid references public.profiles(id) on delete cascade,
  matched_at timestamptz default now()
);

-- CONVERSATIONS & MESSAGES
create table if not exists public.conversations (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz default now(),
  last_activity timestamptz default now()
);

create table if not exists public.conversation_participants (
  conversation_id uuid references public.conversations(id) on delete cascade,
  profile_id uuid references public.profiles(id) on delete cascade,
  primary key (conversation_id, profile_id)
);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid references public.conversations(id) on delete cascade,
  sender_id uuid references public.profiles(id) on delete set null,
  body text,
  read boolean default false,
  created_at timestamptz default now()
);

-- SHOP: items & orders
create table if not exists public.shop_items (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  price numeric(10,2) not null,
  category text,
  images text[],
  rating numeric(2,1) default 4.5,
  reviews_count integer default 0,
  stock integer default 0,
  created_at timestamptz default now()
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid references public.profiles(id) on delete set null,
  total numeric(10,2) not null,
  status text default 'pending', -- pending, paid, shipped, cancelled
  created_at timestamptz default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid references public.orders(id) on delete cascade,
  item_id uuid references public.shop_items(id) on delete set null,
  quantity integer default 1,
  price numeric(10,2) not null
);

-- NOTIFICATIONS
create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid references public.profiles(id) on delete cascade,
  type text not null,
  data jsonb,
  read boolean default false,
  created_at timestamptz default now()
);

-- Useful indexes
create index if not exists idx_pets_owner on public.pets(owner_id);
create index if not exists idx_feed_posts_created on public.feed_posts(created_at desc);
create index if not exists idx_messages_conv on public.messages(conversation_id);
create index if not exists idx_comments_post on public.comments(post_id);
create index if not exists idx_swipes on public.swipes(swiper_id, pet_id);

-- SAMPLE SEED (minimal, optional)
insert into public.profiles (id, email, username, display_name, avatar, bio)
values
('sarah@example.com','sarah_pawsome','Sarah','https://picsum.photos/64','Dog lover and photographer'),
('mike@example.com','cat_dad_mike','Mike','https://picsum.photos/64','Cat dad and baker')
on conflict (email) do nothing;

-- Insert sample pets without owners (owner_id is nullable)
insert into public.pets (name, age, breed, location, image, bio)
values
('Max','2 yrs','Golden Retriever','2 miles away','https://picsum.photos/400','I love long walks and belly rubs!'),
('Whiskers','1 yr','Orange Tabby','5 miles away','https://picsum.photos/401','Professional napper and treat connoisseur.'),
('Bruno','8 mo','French Bulldog','1 mile away','https://picsum.photos/402','Snort expert and zoomies champion!')
on conflict do nothing;

-- Enable RLS if not already enabled
alter table public.feed_posts enable row level security;

-- Create policies only if they don't exist (will error if they exist, but that's ok)
do $$ 
begin
  if not exists (select 1 from pg_policies where tablename = 'feed_posts' and policyname = 'Allow anon insert on feed_posts') then
    create policy "Allow anon insert on feed_posts" on public.feed_posts for insert to anon with check (true);
  end if;
  if not exists (select 1 from pg_policies where tablename = 'feed_posts' and policyname = 'Allow select for anon') then
    create policy "Allow select for anon" on public.feed_posts for select using (true);
  end if;
end $$;

-- Notes:
-- - For production, create strict RLS policies and use Supabase Auth. Use service role for server-side operations.
-- - Supabase auto-generates REST endpoints at /rest/v1/<table> so frontend can call e.g. /rest/v1/feed_posts?select=*
-- - Use Supabase Storage for hosting images; store public URLs in image fields or use signed URLs for private content.