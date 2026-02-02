-- Fix RLS policies for post_comments and post_likes
-- These tables had RLS enabled but NO policies, blocking all operations

-- post_comments RLS policies
DROP POLICY IF EXISTS "Anyone can read comments" ON public.post_comments;
CREATE POLICY "Anyone can read comments"
  ON public.post_comments
  FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Anyone can insert comments" ON public.post_comments;
CREATE POLICY "Anyone can insert comments"
  ON public.post_comments
  FOR INSERT
  WITH CHECK (true);

DROP POLICY IF EXISTS "Users can delete own comments" ON public.post_comments;
CREATE POLICY "Users can delete own comments"
  ON public.post_comments
  FOR DELETE
  USING (user_id = auth.uid()::text);

DROP POLICY IF EXISTS "Users can update own comments" ON public.post_comments;
CREATE POLICY "Users can update own comments"
  ON public.post_comments
  FOR UPDATE
  USING (user_id = auth.uid()::text);


-- post_likes RLS policies
DROP POLICY IF EXISTS "Anyone can read likes" ON public.post_likes;
CREATE POLICY "Anyone can read likes"
  ON public.post_likes
  FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Authenticated users can insert likes" ON public.post_likes;
CREATE POLICY "Authenticated users can insert likes"
  ON public.post_likes
  FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "Users can delete own likes" ON public.post_likes;
CREATE POLICY "Users can delete own likes"
  ON public.post_likes
  FOR DELETE
  USING (user_id = auth.uid());


-- Add columns to feed_posts to cache counts and display info
ALTER TABLE public.feed_posts 
ADD COLUMN IF NOT EXISTS like_count integer DEFAULT 0,
ADD COLUMN IF NOT EXISTS comment_count integer DEFAULT 0;

-- Create functions to auto-update counts (optional but recommended)
CREATE OR REPLACE FUNCTION update_post_like_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.feed_posts 
    SET like_count = like_count + 1 
    WHERE id = NEW.post_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.feed_posts 
    SET like_count = like_count - 1 
    WHERE id = OLD.post_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_post_comment_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.feed_posts 
    SET comment_count = comment_count + 1 
    WHERE id = NEW.post_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.feed_posts 
    SET comment_count = comment_count - 1 
    WHERE id = OLD.post_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create triggers
DROP TRIGGER IF EXISTS trigger_update_like_count ON public.post_likes;
CREATE TRIGGER trigger_update_like_count
AFTER INSERT OR DELETE ON public.post_likes
FOR EACH ROW EXECUTE FUNCTION update_post_like_count();

DROP TRIGGER IF EXISTS trigger_update_comment_count ON public.post_comments;
CREATE TRIGGER trigger_update_comment_count
AFTER INSERT OR DELETE ON public.post_comments
FOR EACH ROW EXECUTE FUNCTION update_post_comment_count();
