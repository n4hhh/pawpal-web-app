-- Fix feed_posts table

alter table public.feed_posts
drop column if exists owner_name,
drop column if exists pet_name,
drop column if exists likes,
drop column if exists comments,
drop column if exists time_ago;

alter table public.feed_posts
add column user_id uuid not null references auth.users(id) on delete cascade,
add column pet_id uuid not null references public.pets(id) on delete cascade;
