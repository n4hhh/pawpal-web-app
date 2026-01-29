-- Allow anyone to upload images
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'storage'
      AND tablename = 'objects'
      AND policyname = 'Allow public uploads'
  ) THEN
    CREATE POLICY "Allow public uploads" ON storage.objects
      FOR INSERT TO public
      WITH CHECK (bucket_id = 'pet-images');
  END IF;
END $$;

-- Allow anyone to read images
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'storage'
      AND tablename = 'objects'
      AND policyname = 'Allow public reads'
  ) THEN
    CREATE POLICY "Allow public reads" ON storage.objects
      FOR SELECT TO public
      USING (bucket_id = 'pet-images');
  END IF;
END $$;