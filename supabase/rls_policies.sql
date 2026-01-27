-- RLS policies for PawPals (run in Supabase SQL Editor)

-- Pets ownership
alter table public.pets enable row level security;
create policy "Owners can manage their pets" on public.pets
  for all
  using (owner_id = auth.uid())
  with check (owner_id = auth.uid());

-- Feed: public select but only owners can insert/update/delete their posts
alter table public.feed_posts enable row level security;
create policy "Public can select feed" on public.feed_posts
  for select using (true);
create policy "Owners can insert feed" on public.feed_posts
  for insert with check (owner_id = auth.uid());
create policy "Owners can modify feed" on public.feed_posts
  for update, delete using (owner_id = auth.uid());

-- Messages: participants only
alter table public.messages enable row level security;
create policy "Participants can access messages" on public.messages
  for all
  using (sender_id = auth.uid() or recipient_id = auth.uid())
  with check (sender_id = auth.uid() or recipient_id = auth.uid());
