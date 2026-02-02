-- Enable RLS and add policies for comments and post_likes tables
-- This allows anonymous users to interact with comments and likes

-- Create comments table if not exists
CREATE TABLE IF NOT EXISTS public.comments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id uuid REFERENCES public.feed_posts(id) ON DELETE CASCADE,
  author_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  body text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create index
CREATE INDEX IF NOT EXISTS idx_comments_post ON public.comments(post_id);

-- Enable RLS on comments table
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;

-- Create policies for comments (allow anonymous access)
DROP POLICY IF EXISTS "Comments: anyone can select" ON public.comments;
CREATE POLICY "Comments: anyone can select" ON public.comments
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "Comments: anyone can insert" ON public.comments;
CREATE POLICY "Comments: anyone can insert" ON public.comments
  FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Comments: anyone can update" ON public.comments;
CREATE POLICY "Comments: anyone can update" ON public.comments
  FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Comments: anyone can delete" ON public.comments;
CREATE POLICY "Comments: anyone can delete" ON public.comments
  FOR DELETE USING (true);

-- Enable RLS on post_likes table
ALTER TABLE public.post_likes ENABLE ROW LEVEL SECURITY;

-- Create policies for post_likes (allow anonymous access)
DROP POLICY IF EXISTS "Likes: anyone can select" ON public.post_likes;
CREATE POLICY "Likes: anyone can select" ON public.post_likes
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "Likes: anyone can insert" ON public.post_likes;
CREATE POLICY "Likes: anyone can insert" ON public.post_likes
  FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Likes: anyone can delete" ON public.post_likes;
CREATE POLICY "Likes: anyone can delete" ON public.post_likes
  FOR DELETE USING (true);

-- Update feed_posts policies to allow anonymous updates (for like_count and comment_count)
DROP POLICY IF EXISTS "Feed: anyone can update" ON public.feed_posts;
CREATE POLICY "Feed: anyone can update" ON public.feed_posts
  FOR UPDATE USING (true);
