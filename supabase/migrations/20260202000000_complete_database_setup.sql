-- PawPals Complete Database Setup for Supabase
-- Run this script in your Supabase SQL Editor after creating a new project
-- Project Settings > Database > SQL Editor > New query > Paste this > Run

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLES
-- ============================================

-- PROFILES (mapped to auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text UNIQUE,
  username text UNIQUE,
  display_name text,
  avatar text,
  bio text,
  location text,
  created_at timestamptz DEFAULT now()
);

-- PETS
CREATE TABLE IF NOT EXISTS public.pets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  name text NOT NULL,
  age text,
  breed text,
  gender text,
  size text,
  location text,
  images text[],
  avatar text,
  bio text,
  is_active boolean DEFAULT true,
  view_count integer DEFAULT 0,
  like_count integer DEFAULT 0,
  match_count integer DEFAULT 0,
  trending_score numeric(10,2) DEFAULT 0,
  last_trending_update timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now()
);

-- FEED POSTS
CREATE TABLE IF NOT EXISTS public.feed_posts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  pet_id uuid REFERENCES public.pets(id) ON DELETE SET NULL,
  images text[],
  caption text,
  like_count integer DEFAULT 0,
  comment_count integer DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- COMMENTS
CREATE TABLE IF NOT EXISTS public.comments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id uuid REFERENCES public.feed_posts(id) ON DELETE CASCADE,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  body text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- POST LIKES
CREATE TABLE IF NOT EXISTS public.post_likes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id uuid REFERENCES public.feed_posts(id) ON DELETE CASCADE,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  UNIQUE (post_id, user_id)
);

-- FOLLOWS
CREATE TABLE IF NOT EXISTS public.follows (
  follower_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  following_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  PRIMARY KEY (follower_id, following_id)
);

-- SWIPES
CREATE TABLE IF NOT EXISTS public.swipes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  swiper_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  pet_id uuid REFERENCES public.pets(id) ON DELETE CASCADE,
  direction text NOT NULL CHECK (direction IN ('left','right')),
  created_at timestamptz DEFAULT now(),
  UNIQUE (swiper_id, pet_id)
);

-- MATCHES
CREATE TABLE IF NOT EXISTS public.matches (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  pet_id uuid REFERENCES public.pets(id) ON DELETE CASCADE,
  profile_a uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  profile_b uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  matched_at timestamptz DEFAULT now()
);

-- CONVERSATIONS
CREATE TABLE IF NOT EXISTS public.conversations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz DEFAULT now(),
  last_activity timestamptz DEFAULT now()
);

-- CONVERSATION PARTICIPANTS
CREATE TABLE IF NOT EXISTS public.conversation_participants (
  conversation_id uuid REFERENCES public.conversations(id) ON DELETE CASCADE,
  profile_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  PRIMARY KEY (conversation_id, profile_id)
);

-- MESSAGES
CREATE TABLE IF NOT EXISTS public.messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id uuid REFERENCES public.conversations(id) ON DELETE CASCADE,
  sender_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  body text,
  read boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- SHOP ITEMS
CREATE TABLE IF NOT EXISTS public.shop_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text,
  price numeric(10,2) NOT NULL,
  category text,
  images text[],
  rating numeric(2,1) DEFAULT 4.5,
  reviews_count integer DEFAULT 0,
  stock integer DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- ORDERS
CREATE TABLE IF NOT EXISTS public.orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  total numeric(10,2) NOT NULL,
  status text DEFAULT 'pending',
  created_at timestamptz DEFAULT now()
);

-- ORDER ITEMS
CREATE TABLE IF NOT EXISTS public.order_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid REFERENCES public.orders(id) ON DELETE CASCADE,
  item_id uuid REFERENCES public.shop_items(id) ON DELETE SET NULL,
  quantity integer DEFAULT 1,
  price numeric(10,2) NOT NULL
);

-- STORIES
CREATE TABLE IF NOT EXISTS public.stories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  media_url text NOT NULL,
  media_type text NOT NULL CHECK (media_type IN ('image', 'video')),
  caption text,
  created_at timestamptz DEFAULT now() NOT NULL,
  expires_at timestamptz DEFAULT (now() + interval '24 hours') NOT NULL,
  view_count integer DEFAULT 0 NOT NULL
);

-- STORY VIEWS
CREATE TABLE IF NOT EXISTS public.story_views (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  story_id uuid NOT NULL REFERENCES public.stories(id) ON DELETE CASCADE,
  viewer_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  viewed_at timestamptz DEFAULT now() NOT NULL,
  UNIQUE(story_id, viewer_id)
);

-- NOTIFICATIONS
CREATE TABLE IF NOT EXISTS public.notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  type text NOT NULL,
  data jsonb,
  read boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- ============================================
-- INDEXES
-- ============================================

CREATE INDEX IF NOT EXISTS idx_pets_owner ON public.pets(owner_id);
CREATE INDEX IF NOT EXISTS idx_pets_trending_score ON public.pets(trending_score DESC);
CREATE INDEX IF NOT EXISTS idx_pets_created_trending ON public.pets(created_at DESC, trending_score DESC);
CREATE INDEX IF NOT EXISTS idx_feed_posts_created ON public.feed_posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_feed_posts_user ON public.feed_posts(user_id);
CREATE INDEX IF NOT EXISTS idx_messages_conv ON public.messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_comments_post ON public.comments(post_id);
CREATE INDEX IF NOT EXISTS idx_swipes ON public.swipes(swiper_id, pet_id);

-- ============================================
-- FUNCTIONS
-- ============================================

-- Calculate trending score for pets
CREATE OR REPLACE FUNCTION calculate_trending_score(
  p_view_count INTEGER,
  p_like_count INTEGER,
  p_match_count INTEGER,
  p_created_at TIMESTAMPTZ
) RETURNS NUMERIC AS $$
DECLARE
  base_score NUMERIC;
  time_factor NUMERIC;
  age_hours NUMERIC;
BEGIN
  base_score := (p_view_count * 1.0) 
              + (p_like_count * 3.0) 
              + (p_match_count * 5.0);
  
  age_hours := EXTRACT(EPOCH FROM (now() - p_created_at)) / 3600;
  
  IF age_hours < 24 THEN
    time_factor := 2.0;
  ELSIF age_hours < 168 THEN
    time_factor := 1.0 - ((age_hours - 24) / 288);
  ELSE
    time_factor := 0.5 * EXP(-age_hours / 1680);
  END IF;
  
  RETURN base_score * time_factor;
END;
$$ LANGUAGE plpgsql STABLE;

-- Update all trending scores
CREATE OR REPLACE FUNCTION update_all_trending_scores() 
RETURNS void AS $$
BEGIN
  UPDATE public.pets
  SET 
    trending_score = calculate_trending_score(
      COALESCE(view_count, 0),
      COALESCE(like_count, 0),
      COALESCE(match_count, 0),
      created_at
    ),
    last_trending_update = now()
  WHERE is_active = true;
END;
$$ LANGUAGE plpgsql;

-- Increment pet view count
CREATE OR REPLACE FUNCTION increment_pet_view(pet_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE public.pets
  SET view_count = COALESCE(view_count, 0) + 1
  WHERE id = pet_id AND is_active = true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Increment pet like count
CREATE OR REPLACE FUNCTION increment_pet_like(pet_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE public.pets
  SET like_count = COALESCE(like_count, 0) + 1
  WHERE id = pet_id AND is_active = true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Increment pet match count
CREATE OR REPLACE FUNCTION increment_pet_match(pet_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE public.pets
  SET match_count = COALESCE(match_count, 0) + 1
  WHERE id = pet_id AND is_active = true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feed_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.swipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversation_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shop_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.story_views ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- PROFILES policies
DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON public.profiles;
CREATE POLICY "Public profiles are viewable by everyone"
  ON public.profiles FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Users can insert their own profile" ON public.profiles;
CREATE POLICY "Users can insert their own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

-- PETS policies
DROP POLICY IF EXISTS "Pets are viewable by everyone" ON public.pets;
CREATE POLICY "Pets are viewable by everyone"
  ON public.pets FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Authenticated users can insert pets" ON public.pets;
CREATE POLICY "Authenticated users can insert pets"
  ON public.pets FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = owner_id);

DROP POLICY IF EXISTS "Users can update own pets" ON public.pets;
CREATE POLICY "Users can update own pets"
  ON public.pets FOR UPDATE
  USING (auth.uid() = owner_id);

DROP POLICY IF EXISTS "Users can delete own pets" ON public.pets;
CREATE POLICY "Users can delete own pets"
  ON public.pets FOR DELETE
  USING (auth.uid() = owner_id);

-- FEED POSTS policies
DROP POLICY IF EXISTS "Feed posts are viewable by everyone" ON public.feed_posts;
CREATE POLICY "Feed posts are viewable by everyone"
  ON public.feed_posts FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Authenticated users can create posts" ON public.feed_posts;
CREATE POLICY "Authenticated users can create posts"
  ON public.feed_posts FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own posts" ON public.feed_posts;
CREATE POLICY "Users can update own posts"
  ON public.feed_posts FOR UPDATE
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own posts" ON public.feed_posts;
CREATE POLICY "Users can delete own posts"
  ON public.feed_posts FOR DELETE
  USING (auth.uid() = user_id);

-- COMMENTS policies
DROP POLICY IF EXISTS "Comments are viewable by everyone" ON public.comments;
CREATE POLICY "Comments are viewable by everyone"
  ON public.comments FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Authenticated users can create comments" ON public.comments;
CREATE POLICY "Authenticated users can create comments"
  ON public.comments FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own comments" ON public.comments;
CREATE POLICY "Users can delete own comments"
  ON public.comments FOR DELETE
  USING (auth.uid() = user_id);

-- POST LIKES policies
DROP POLICY IF EXISTS "Likes are viewable by everyone" ON public.post_likes;
CREATE POLICY "Likes are viewable by everyone"
  ON public.post_likes FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Authenticated users can like posts" ON public.post_likes;
CREATE POLICY "Authenticated users can like posts"
  ON public.post_likes FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can unlike posts" ON public.post_likes;
CREATE POLICY "Users can unlike posts"
  ON public.post_likes FOR DELETE
  USING (auth.uid() = user_id);

-- FOLLOWS policies
DROP POLICY IF EXISTS "Follows are viewable by everyone" ON public.follows;
CREATE POLICY "Follows are viewable by everyone"
  ON public.follows FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Users can follow others" ON public.follows;
CREATE POLICY "Users can follow others"
  ON public.follows FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = follower_id);

DROP POLICY IF EXISTS "Users can unfollow" ON public.follows;
CREATE POLICY "Users can unfollow"
  ON public.follows FOR DELETE
  USING (auth.uid() = follower_id);

-- SWIPES policies
DROP POLICY IF EXISTS "Users can view their own swipes" ON public.swipes;
CREATE POLICY "Users can view their own swipes"
  ON public.swipes FOR SELECT
  USING (auth.uid() = swiper_id);

DROP POLICY IF EXISTS "Users can create swipes" ON public.swipes;
CREATE POLICY "Users can create swipes"
  ON public.swipes FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = swiper_id);

-- MATCHES policies
DROP POLICY IF EXISTS "Users can view their matches" ON public.matches;
CREATE POLICY "Users can view their matches"
  ON public.matches FOR SELECT
  USING (auth.uid() = profile_a OR auth.uid() = profile_b);

DROP POLICY IF EXISTS "System can create matches" ON public.matches;
CREATE POLICY "System can create matches"
  ON public.matches FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- SHOP ITEMS policies
DROP POLICY IF EXISTS "Shop items viewable by everyone" ON public.shop_items;
CREATE POLICY "Shop items viewable by everyone"
  ON public.shop_items FOR SELECT
  USING (true);

-- ORDERS policies
DROP POLICY IF EXISTS "Users can view own orders" ON public.orders;
CREATE POLICY "Users can view own orders"
  ON public.orders FOR SELECT
  USING (auth.uid() = profile_id);

DROP POLICY IF EXISTS "Users can create orders" ON public.orders;
CREATE POLICY "Users can create orders"
  ON public.orders FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = profile_id);

-- ORDER ITEMS policies
DROP POLICY IF EXISTS "Users can view own order items" ON public.order_items;
CREATE POLICY "Users can view own order items"
  ON public.order_items FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM public.orders
    WHERE orders.id = order_items.order_id
    AND orders.profile_id = auth.uid()
  ));

-- STORIES policies
DROP POLICY IF EXISTS "Anyone can view non-expired stories" ON public.stories;
CREATE POLICY "Anyone can view non-expired stories"
  ON public.stories FOR SELECT
  USING (expires_at > now());

DROP POLICY IF EXISTS "Users can insert their own stories" ON public.stories;
CREATE POLICY "Users can insert their own stories"
  ON public.stories FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own stories" ON public.stories;
CREATE POLICY "Users can delete their own stories"
  ON public.stories FOR DELETE
  USING (auth.uid() = user_id);

-- STORY VIEWS policies
DROP POLICY IF EXISTS "Users can view story views" ON public.story_views;
CREATE POLICY "Users can view story views"
  ON public.story_views FOR SELECT
  USING (
    auth.uid() = viewer_id 
    OR auth.uid() = (SELECT user_id FROM public.stories WHERE id = story_id)
  );

DROP POLICY IF EXISTS "Users can insert story views" ON public.story_views;
CREATE POLICY "Users can insert story views"
  ON public.story_views FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = viewer_id);

-- NOTIFICATIONS policies
DROP POLICY IF EXISTS "Users can view own notifications" ON public.notifications;
CREATE POLICY "Users can view own notifications"
  ON public.notifications FOR SELECT
  USING (auth.uid() = profile_id);

DROP POLICY IF EXISTS "Users can update own notifications" ON public.notifications;
CREATE POLICY "Users can update own notifications"
  ON public.notifications FOR UPDATE
  USING (auth.uid() = profile_id);

-- ============================================
-- GRANT PERMISSIONS
-- ============================================

GRANT EXECUTE ON FUNCTION increment_pet_view(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION increment_pet_like(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION increment_pet_match(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION update_all_trending_scores() TO anon, authenticated;

-- ============================================
-- DONE!
-- ============================================

-- Your database is now set up and ready to use!
-- Next steps:
-- 1. Update your .env file with the new project's URL and anon key
-- 2. Create some test users through Supabase Auth
-- 3. Run the seed data script if you want sample data
