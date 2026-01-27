-- Create feed_posts table
create table if not exists public.feed_posts (
  id uuid primary key default gen_random_uuid(),
  pet_name text not null,
  owner_name text not null,
  avatar text,
  image text,
  caption text,
  likes integer default 0,
  comments integer default 0,
  time_ago text,
  created_at timestamptz default now()
);

-- Insert sample feed posts (matching mockData structure)
insert into public.feed_posts (pet_name, owner_name, avatar, image, caption, likes, comments, time_ago)
values
('Max', 'sarah_pawsome', 'https://place-puppy.com/400', 'https://place-puppy.com/400', 'Living my best life at the beach today! 🏖️ Who else loves the water?', 234, 18, '2 hours ago'),
('Whiskers', 'cat_dad_mike', 'https://placekitten.com/400/400', 'https://placekitten.com/400/400', 'Caught me in my best pose. Yes, I woke up like this 💅', 567, 42, '5 hours ago'),
('Bruno', 'frenchie_lover', 'https://images.unsplash.com/photo-1598133894001-3c4b5f6a6c8b', 'https://images.unsplash.com/photo-1598133894001-3c4b5f6a6c8b', 'Did someone say treats?! 👀🍖', 891, 56, '8 hours ago');

-- Enable RLS (optional: for development, you can skip this or create a permissive policy)
-- For quick testing, you can disable RLS temporarily:
-- alter table public.feed_posts disable row level security;

-- Or create a policy to allow anon select:
-- alter table public.feed_posts enable row level security;
-- create policy "Allow select for anon" on public.feed_posts
--   for select
--   using (true);
