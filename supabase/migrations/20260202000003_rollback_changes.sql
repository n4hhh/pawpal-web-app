-- Rollback: Remove storage buckets and restore authenticated-only policies

-- Remove storage buckets
DELETE FROM storage.buckets WHERE id IN ('avatars', 'pet-images', 'post-images', 'stories');

-- Restore authenticated-only policies for pets
DROP POLICY IF EXISTS "Anyone can insert pets" ON public.pets;
CREATE POLICY "Authenticated users can insert pets" ON public.pets FOR INSERT TO authenticated WITH CHECK (auth.uid() = owner_id);

DROP POLICY IF EXISTS "Anyone can update pets" ON public.pets;
CREATE POLICY "Users can update own pets" ON public.pets FOR UPDATE USING (auth.uid() = owner_id);

DROP POLICY IF EXISTS "Anyone can delete pets" ON public.pets;
CREATE POLICY "Users can delete own pets" ON public.pets FOR DELETE USING (auth.uid() = owner_id);

-- Restore authenticated-only policies for feed_posts
DROP POLICY IF EXISTS "Anyone can create posts" ON public.feed_posts;
CREATE POLICY "Authenticated users can create posts" ON public.feed_posts FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Anyone can update posts" ON public.feed_posts;
CREATE POLICY "Users can update own posts" ON public.feed_posts FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Anyone can delete posts" ON public.feed_posts;
CREATE POLICY "Users can delete own posts" ON public.feed_posts FOR DELETE USING (auth.uid() = user_id);

-- Restore authenticated-only policies for comments
DROP POLICY IF EXISTS "Anyone can create comments" ON public.comments;
CREATE POLICY "Authenticated users can create comments" ON public.comments FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Anyone can delete comments" ON public.comments;
CREATE POLICY "Users can delete own comments" ON public.comments FOR DELETE USING (auth.uid() = user_id);

-- Restore authenticated-only policies for post_likes
DROP POLICY IF EXISTS "Anyone can like posts" ON public.post_likes;
CREATE POLICY "Authenticated users can like posts" ON public.post_likes FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Anyone can unlike posts" ON public.post_likes;
CREATE POLICY "Users can unlike posts" ON public.post_likes FOR DELETE USING (auth.uid() = user_id);

-- Restore authenticated-only policies for stories
DROP POLICY IF EXISTS "Anyone can insert stories" ON public.stories;
CREATE POLICY "Users can insert their own stories" ON public.stories FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Anyone can delete stories" ON public.stories;
CREATE POLICY "Users can delete their own stories" ON public.stories FOR DELETE USING (auth.uid() = user_id);
