-- Complete database cleanup - remove conflicting columns and tables
-- This fixes all the issues from manually running SQL yesterday

-- 1. Drop duplicate tables that conflict with the real schema
DROP TABLE IF EXISTS public.users CASCADE;
DROP TABLE IF EXISTS public.shop_items CASCADE;
DROP TABLE IF EXISTS public.purchases CASCADE;

-- 2. Clean up feed_posts - remove duplicate/conflicting columns
ALTER TABLE public.feed_posts DROP COLUMN IF EXISTS pet_name;
ALTER TABLE public.feed_posts DROP COLUMN IF EXISTS owner_name;
ALTER TABLE public.feed_posts DROP COLUMN IF EXISTS likes;
ALTER TABLE public.feed_posts DROP COLUMN IF EXISTS comments;
ALTER TABLE public.feed_posts DROP COLUMN IF EXISTS time_ago;

-- 3. Ensure we have the correct columns (from the previous migration)
-- These should already exist but we'll make sure
ALTER TABLE public.feed_posts 
ADD COLUMN IF NOT EXISTS like_count integer DEFAULT 0,
ADD COLUMN IF NOT EXISTS comment_count integer DEFAULT 0;

-- 4. Make sure post_comments.user_id is text type
ALTER TABLE public.post_comments 
DROP CONSTRAINT IF EXISTS post_comments_user_id_fkey;

DO $$ 
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'post_comments' 
    AND column_name = 'user_id' 
    AND data_type = 'uuid'
  ) THEN
    ALTER TABLE public.post_comments 
    ALTER COLUMN user_id TYPE text USING user_id::text;
  END IF;
END $$;

-- 5. Re-enable RLS on all tables (ensure it's on)
ALTER TABLE public.feed_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_likes ENABLE ROW LEVEL SECURITY;
