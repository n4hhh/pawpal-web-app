-- Create storage buckets for the app

-- Create buckets
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
  ('avatars', 'avatars', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']),
  ('pet-images', 'pet-images', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']),
  ('post-images', 'post-images', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']),
  ('stories', 'stories', true, 52428800, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'video/mp4', 'video/quicktime'])
ON CONFLICT (id) DO NOTHING;

-- Storage policies - Public read access
DROP POLICY IF EXISTS "Public Access to avatars" ON storage.objects;
CREATE POLICY "Public Access to avatars" ON storage.objects FOR SELECT USING (bucket_id = 'avatars');

DROP POLICY IF EXISTS "Public Access to pet-images" ON storage.objects;
CREATE POLICY "Public Access to pet-images" ON storage.objects FOR SELECT USING (bucket_id = 'pet-images');

DROP POLICY IF EXISTS "Public Access to post-images" ON storage.objects;
CREATE POLICY "Public Access to post-images" ON storage.objects FOR SELECT USING (bucket_id = 'post-images');

DROP POLICY IF EXISTS "Public Access to stories" ON storage.objects;
CREATE POLICY "Public Access to stories" ON storage.objects FOR SELECT USING (bucket_id = 'stories');

-- Authenticated users can upload
DROP POLICY IF EXISTS "Authenticated upload avatars" ON storage.objects;
CREATE POLICY "Authenticated upload avatars" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'avatars');

DROP POLICY IF EXISTS "Authenticated upload pet-images" ON storage.objects;
CREATE POLICY "Authenticated upload pet-images" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'pet-images');

DROP POLICY IF EXISTS "Authenticated upload post-images" ON storage.objects;
CREATE POLICY "Authenticated upload post-images" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'post-images');

DROP POLICY IF EXISTS "Authenticated upload stories" ON storage.objects;
CREATE POLICY "Authenticated upload stories" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'stories');

-- Users can update/delete own files
DROP POLICY IF EXISTS "Users update own files" ON storage.objects;
CREATE POLICY "Users update own files" ON storage.objects FOR UPDATE TO authenticated USING (auth.uid() = owner);

DROP POLICY IF EXISTS "Users delete own files" ON storage.objects;
CREATE POLICY "Users delete own files" ON storage.objects FOR DELETE TO authenticated USING (auth.uid() = owner);
