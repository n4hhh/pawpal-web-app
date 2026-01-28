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
  images text[],
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
-- If you want to seed, replace the uuid with your auth user ids or leave to gen_random
(gen_random_uuid(),'sarah@example.com','sarah_pawsome','Sarah','https://picsum.photos/64','Dog lover and photographer'),
(gen_random_uuid(),'mike@example.com','cat_dad_mike','Mike','https://picsum.photos/64','Cat dad and baker')
on conflict do nothing;

-- DEV RLS EXAMPLES (uncomment & adapt for production)
-- Notes: For production you should enable RLS and create policies that use auth.uid() to scope rows.
-- Example: allow users to read their own profile and allow anon read on feed_posts for public feed.

-- enable row level security on tables you want to protect
-- alter table public.profiles enable row level security;
-- create policy "Profiles: allow self read/write" on public.profiles
--   for all using (auth.uid() = id) with check (auth.uid() = id);

-- alter table public.feed_posts enable row level security;
-- create policy "Feed: public read" on public.feed_posts for select using (true);
-- create policy "Feed: insert post as authenticated" on public.feed_posts for insert
--   with check (auth.uid() = profile_id);

-- Production notes:
-- - Keep your SUPABASE_SERVICE_ROLE_KEY secret and use it server-side for privileged ops.
-- - Use Supabase Storage for user-uploaded images. Store either public URLs in arrays `images` or
--   store paths and generate signed URLs when serving private content.
-- - Run these SQL migrations in Supabase SQL Editor. Review RLS policies carefully before enabling.
