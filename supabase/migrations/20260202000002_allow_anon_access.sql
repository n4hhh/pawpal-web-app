-- Temporarily allow anonymous access for development

-- Pets policies - allow anon
DROP POLICY IF EXISTS "Authenticated users can insert pets" ON public.pets;
CREATE POLICY "Anyone can insert pets" ON public.pets FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Users can update own pets" ON public.pets;
CREATE POLICY "Anyone can update pets" ON public.pets FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Users can delete own pets" ON public.pets;
CREATE POLICY "Anyone can delete pets" ON public.pets FOR DELETE USING (true);

-- Feed posts policies - allow anon
DROP POLICY IF EXISTS "Authenticated users can create posts" ON public.feed_posts;
CREATE POLICY "Anyone can create posts" ON public.feed_posts FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Users can update own posts" ON public.feed_posts;
CREATE POLICY "Anyone can update posts" ON public.feed_posts FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Users can delete own posts" ON public.feed_posts;
CREATE POLICY "Anyone can delete posts" ON public.feed_posts FOR DELETE USING (true);

-- Comments policies - allow anon
DROP POLICY IF EXISTS "Authenticated users can create comments" ON public.comments;
CREATE POLICY "Anyone can create comments" ON public.comments FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Users can delete own comments" ON public.comments;
CREATE POLICY "Anyone can delete comments" ON public.comments FOR DELETE USING (true);

-- Post likes policies - allow anon
DROP POLICY IF EXISTS "Authenticated users can like posts" ON public.post_likes;
CREATE POLICY "Anyone can like posts" ON public.post_likes FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Users can unlike posts" ON public.post_likes;
CREATE POLICY "Anyone can unlike posts" ON public.post_likes FOR DELETE USING (true);

-- Stories policies - allow anon
DROP POLICY IF EXISTS "Users can insert their own stories" ON public.stories;
CREATE POLICY "Anyone can insert stories" ON public.stories FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Users can delete their own stories" ON public.stories;
CREATE POLICY "Anyone can delete stories" ON public.stories FOR DELETE USING (true);

-- Storage policies - allow anon upload
DROP POLICY IF EXISTS "Authenticated upload avatars" ON storage.objects;
CREATE POLICY "Anyone can upload avatars" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'avatars');

DROP POLICY IF EXISTS "Authenticated upload pet-images" ON storage.objects;
CREATE POLICY "Anyone can upload pet-images" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'pet-images');

DROP POLICY IF EXISTS "Authenticated upload post-images" ON storage.objects;
CREATE POLICY "Anyone can upload post-images" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'post-images');

DROP POLICY IF EXISTS "Authenticated upload stories" ON storage.objects;
CREATE POLICY "Anyone can upload stories" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'stories');
