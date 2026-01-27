-- Add owner_id (correct relation)
alter table public.pets
add column if not exists owner_id uuid references auth.users(id);

-- Remove old incorrect column
alter table public.pets
drop column if exists owner;

-- Add correct relations
alter table public.feed_posts
add column if not exists author_id uuid references auth.users(id);

alter table public.feed_posts
add column if not exists pet_id uuid references public.pets(id);

-- Remove incorrect columns
alter table public.feed_posts
drop column if exists owner_name,
drop column if exists pet_name,
drop column if exists likes,
drop column if exists comments,
drop column if exists time_ago;

create table if not exists public.post_likes (
  id uuid primary key default gen_random_uuid(),
  post_id uuid references public.feed_posts(id) on delete cascade,
  user_id uuid references auth.users(id) on delete cascade,
  unique (post_id, user_id)
);

create table if not exists public.post_comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid references public.feed_posts(id) on delete cascade,
  user_id uuid references auth.users(id) on delete cascade,
  content text not null,
  created_at timestamptz default now()
);
