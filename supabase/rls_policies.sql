-- Row-Level Security (RLS) policies for PawPals
-- Apply these in Supabase SQL Editor or include in migrations before enabling RLS in production.

-- PROFILES: users may read/update/insert their own profile only
alter table if exists public.profiles enable row level security;
create policy if not exists "Profiles: self select" on public.profiles
  for select using (auth.uid() = id::text);
create policy if not exists "Profiles: self insert" on public.profiles
  for insert with check (auth.uid() = id::text);
create policy if not exists "Profiles: self update" on public.profiles
  for update using (auth.uid() = id::text) with check (auth.uid() = id::text);
create policy if not exists "Profiles: self delete" on public.profiles
  for delete using (auth.uid() = id::text);


-- PETS: public can view; only owner can create/update/delete
alter table if exists public.pets enable row level security;
create policy if not exists "Pets: public select" on public.pets
  for select using (true);
create policy if not exists "Pets: owner insert" on public.pets
  for insert with check (owner_id::text = auth.uid());
create policy if not exists "Pets: owner update" on public.pets
  for update using (owner_id::text = auth.uid()) with check (owner_id::text = auth.uid());
create policy if not exists "Pets: owner delete" on public.pets
  for delete using (owner_id::text = auth.uid());


-- FEED POSTS: public read; owners may insert/update/delete their posts
alter table if exists public.feed_posts enable row level security;
create policy if not exists "Feed: public select" on public.feed_posts
  for select using (true);
create policy if not exists "Feed: insert as owner" on public.feed_posts
  for insert with check (profile_id::text = auth.uid());
create policy if not exists "Feed: update owner" on public.feed_posts
  for update using (profile_id::text = auth.uid()) with check (profile_id::text = auth.uid());
create policy if not exists "Feed: delete owner" on public.feed_posts
  for delete using (profile_id::text = auth.uid());


-- COMMENTS: anyone can read comments; only author can insert/update/delete their comments
alter table if exists public.comments enable row level security;
create policy if not exists "Comments: public select" on public.comments
  for select using (true);
create policy if not exists "Comments: author insert" on public.comments
  for insert with check (author_id::text = auth.uid());
create policy if not exists "Comments: author update" on public.comments
  for update using (author_id::text = auth.uid()) with check (author_id::text = auth.uid());
create policy if not exists "Comments: author delete" on public.comments
  for delete using (author_id::text = auth.uid());


-- POST LIKES: allow public read; users can like/unlike their own identity
alter table if exists public.post_likes enable row level security;
create policy if not exists "PostLikes: public select" on public.post_likes
  for select using (true);
create policy if not exists "PostLikes: insert by profile" on public.post_likes
  for insert with check (profile_id::text = auth.uid());
create policy if not exists "PostLikes: delete by profile" on public.post_likes
  for delete using (profile_id::text = auth.uid());


-- SWIPES: users can only read/create/update their own swipes
alter table if exists public.swipes enable row level security;
create policy if not exists "Swipes: self select" on public.swipes
  for select using (swiper_id::text = auth.uid());
create policy if not exists "Swipes: self insert" on public.swipes
  for insert with check (swiper_id::text = auth.uid());
create policy if not exists "Swipes: self update" on public.swipes
  for update using (swiper_id::text = auth.uid()) with check (swiper_id::text = auth.uid());
create policy if not exists "Swipes: self delete" on public.swipes
  for delete using (swiper_id::text = auth.uid());


-- MATCHES: allow participants to see matches involving them
alter table if exists public.matches enable row level security;
create policy if not exists "Matches: participant select" on public.matches
  for select using (
    profile_a::text = auth.uid() OR profile_b::text = auth.uid()
  );
-- Matches are typically created by backend logic; restrict inserts/updates to service role (no open policy)


-- CONVERSATIONS & PARTICIPANTS
alter table if exists public.conversation_participants enable row level security;
create policy if not exists "ConvParts: self select" on public.conversation_participants
  for select using (profile_id::text = auth.uid());
create policy if not exists "ConvParts: self insert" on public.conversation_participants
  for insert with check (profile_id::text = auth.uid());
create policy if not exists "ConvParts: self delete" on public.conversation_participants
  for delete using (profile_id::text = auth.uid());

alter table if exists public.conversations enable row level security;
create policy if not exists "Conversations: participant select" on public.conversations
  for select using (
    exists (
      select 1 from public.conversation_participants cp
      where cp.conversation_id = public.conversations.id and cp.profile_id::text = auth.uid()
    )
  );
-- Insert/update/delete for conversations should be restricted to application server (no open policy)


-- MESSAGES: participants can read; sender may insert/update/delete their own messages
alter table if exists public.messages enable row level security;
create policy if not exists "Messages: participant select" on public.messages
  for select using (
    exists (
      select 1 from public.conversation_participants cp
      where cp.conversation_id = public.messages.conversation_id and cp.profile_id::text = auth.uid()
    )
  );
create policy if not exists "Messages: sender insert" on public.messages
  for insert with check (sender_id::text = auth.uid());
create policy if not exists "Messages: sender update" on public.messages
  for update using (sender_id::text = auth.uid()) with check (sender_id::text = auth.uid());
create policy if not exists "Messages: sender delete" on public.messages
  for delete using (sender_id::text = auth.uid());


-- SHOP ITEMS: public read; restrict mutations to server-side (no policies for insert/update/delete)
alter table if exists public.shop_items enable row level security;
create policy if not exists "ShopItems: public select" on public.shop_items
  for select using (true);


-- ORDERS & ORDER_ITEMS: users can only access their own orders
alter table if exists public.orders enable row level security;
create policy if not exists "Orders: self select" on public.orders
  for select using (profile_id::text = auth.uid());
create policy if not exists "Orders: self insert" on public.orders
  for insert with check (profile_id::text = auth.uid());
create policy if not exists "Orders: self update" on public.orders
  for update using (profile_id::text = auth.uid()) with check (profile_id::text = auth.uid());
create policy if not exists "Orders: self delete" on public.orders
  for delete using (profile_id::text = auth.uid());

alter table if exists public.order_items enable row level security;
create policy if not exists "OrderItems: order owner select" on public.order_items
  for select using (
    exists (select 1 from public.orders o where o.id = public.order_items.order_id and o.profile_id::text = auth.uid())
  );


-- NOTIFICATIONS: only recipient can read/update their notifications
alter table if exists public.notifications enable row level security;
create policy if not exists "Notifications: self select" on public.notifications
  for select using (profile_id::text = auth.uid());
create policy if not exists "Notifications: self insert" on public.notifications
  for insert with check (profile_id::text = auth.uid());
create policy if not exists "Notifications: self update" on public.notifications
  for update using (profile_id::text = auth.uid()) with check (profile_id::text = auth.uid());
create policy if not exists "Notifications: self delete" on public.notifications
  for delete using (profile_id::text = auth.uid());

-- Final note: review policies before enabling in production. Some actions (e.g., creating matches,
-- administrative product updates) should be performed server-side with the service_role key.
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
