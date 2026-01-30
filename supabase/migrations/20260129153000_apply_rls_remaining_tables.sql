-- Additional RLS policies for tables shown in Supabase dashboard

-- POST_COMMENTS: public read; only author can insert/update/delete
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'post_comments'
  ) THEN
    EXECUTE 'ALTER TABLE public.post_comments ENABLE ROW LEVEL SECURITY';

    IF NOT EXISTS (
      SELECT 1 FROM pg_policies
      WHERE schemaname = 'public'
        AND tablename = 'post_comments'
        AND policyname = 'PostComments: public select'
    ) THEN
      CREATE POLICY "PostComments: public select" ON public.post_comments
        FOR SELECT USING (true);
    END IF;

    IF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'post_comments'
        AND column_name = 'user_id'
    ) THEN
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'post_comments'
          AND policyname = 'PostComments: author insert'
      ) THEN
        CREATE POLICY "PostComments: author insert" ON public.post_comments
          FOR INSERT WITH CHECK (user_id::text = auth.uid()::text);
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'post_comments'
          AND policyname = 'PostComments: author update'
      ) THEN
        CREATE POLICY "PostComments: author update" ON public.post_comments
          FOR UPDATE USING (user_id::text = auth.uid()::text) WITH CHECK (user_id::text = auth.uid()::text);
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'post_comments'
          AND policyname = 'PostComments: author delete'
      ) THEN
        CREATE POLICY "PostComments: author delete" ON public.post_comments
          FOR DELETE USING (user_id::text = auth.uid()::text);
      END IF;
    ELSIF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'post_comments'
        AND column_name = 'author_id'
    ) THEN
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'post_comments'
          AND policyname = 'PostComments: author insert'
      ) THEN
        CREATE POLICY "PostComments: author insert" ON public.post_comments
          FOR INSERT WITH CHECK (author_id::text = auth.uid()::text);
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'post_comments'
          AND policyname = 'PostComments: author update'
      ) THEN
        CREATE POLICY "PostComments: author update" ON public.post_comments
          FOR UPDATE USING (author_id::text = auth.uid()::text) WITH CHECK (author_id::text = auth.uid()::text);
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'post_comments'
          AND policyname = 'PostComments: author delete'
      ) THEN
        CREATE POLICY "PostComments: author delete" ON public.post_comments
          FOR DELETE USING (author_id::text = auth.uid()::text);
      END IF;
    END IF;
  END IF;
END $$;

-- PET_PREFERENCES: only pet owner can read/write
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'pet_preferences'
  ) THEN
    EXECUTE 'ALTER TABLE public.pet_preferences ENABLE ROW LEVEL SECURITY';
    IF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'pet_preferences'
        AND column_name = 'pet_id'
    ) THEN
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'pet_preferences'
          AND policyname = 'PetPreferences: owner select'
      ) THEN
        CREATE POLICY "PetPreferences: owner select" ON public.pet_preferences
          FOR SELECT USING (
            exists (
              select 1 from public.pets p
              where p.id = pet_preferences.pet_id and p.owner_id = auth.uid()
            )
          );
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'pet_preferences'
          AND policyname = 'PetPreferences: owner insert'
      ) THEN
        CREATE POLICY "PetPreferences: owner insert" ON public.pet_preferences
          FOR INSERT WITH CHECK (
            exists (
              select 1 from public.pets p
              where p.id = pet_preferences.pet_id and p.owner_id = auth.uid()
            )
          );
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'pet_preferences'
          AND policyname = 'PetPreferences: owner update'
      ) THEN
        CREATE POLICY "PetPreferences: owner update" ON public.pet_preferences
          FOR UPDATE USING (
            exists (
              select 1 from public.pets p
              where p.id = pet_preferences.pet_id and p.owner_id = auth.uid()
            )
          ) WITH CHECK (
            exists (
              select 1 from public.pets p
              where p.id = pet_preferences.pet_id and p.owner_id = auth.uid()
            )
          );
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'pet_preferences'
          AND policyname = 'PetPreferences: owner delete'
      ) THEN
        CREATE POLICY "PetPreferences: owner delete" ON public.pet_preferences
          FOR DELETE USING (
            exists (
              select 1 from public.pets p
              where p.id = pet_preferences.pet_id and p.owner_id = auth.uid()
            )
          );
      END IF;
    END IF;
  END IF;
END $$;

-- PET_SWIPES: owner of from_pet can read/write
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'pet_swipes'
  ) THEN
    EXECUTE 'ALTER TABLE public.pet_swipes ENABLE ROW LEVEL SECURITY';
    IF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'pet_swipes'
        AND column_name = 'from_pet_id'
    ) THEN
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'pet_swipes'
          AND policyname = 'PetSwipes: owner select'
      ) THEN
        CREATE POLICY "PetSwipes: owner select" ON public.pet_swipes
          FOR SELECT USING (
            exists (
              select 1 from public.pets p
              where p.id = pet_swipes.from_pet_id and p.owner_id = auth.uid()
            )
          );
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'pet_swipes'
          AND policyname = 'PetSwipes: owner insert'
      ) THEN
        CREATE POLICY "PetSwipes: owner insert" ON public.pet_swipes
          FOR INSERT WITH CHECK (
            exists (
              select 1 from public.pets p
              where p.id = pet_swipes.from_pet_id and p.owner_id = auth.uid()
            )
          );
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'pet_swipes'
          AND policyname = 'PetSwipes: owner update'
      ) THEN
        CREATE POLICY "PetSwipes: owner update" ON public.pet_swipes
          FOR UPDATE USING (
            exists (
              select 1 from public.pets p
              where p.id = pet_swipes.from_pet_id and p.owner_id = auth.uid()
            )
          ) WITH CHECK (
            exists (
              select 1 from public.pets p
              where p.id = pet_swipes.from_pet_id and p.owner_id = auth.uid()
            )
          );
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'pet_swipes'
          AND policyname = 'PetSwipes: owner delete'
      ) THEN
        CREATE POLICY "PetSwipes: owner delete" ON public.pet_swipes
          FOR DELETE USING (
            exists (
              select 1 from public.pets p
              where p.id = pet_swipes.from_pet_id and p.owner_id = auth.uid()
            )
          );
      END IF;
    END IF;
  END IF;
END $$;

-- PET_MATCHES: participants can read (no client insert/update/delete)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'pet_matches'
  ) THEN
    EXECUTE 'ALTER TABLE public.pet_matches ENABLE ROW LEVEL SECURITY';
    IF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'pet_matches'
        AND column_name = 'pet_a'
    ) AND EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'pet_matches'
        AND column_name = 'pet_b'
    ) THEN
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'pet_matches'
          AND policyname = 'PetMatches: participant select'
      ) THEN
        CREATE POLICY "PetMatches: participant select" ON public.pet_matches
          FOR SELECT USING (
            exists (
              select 1 from public.pets p
              where p.id in (pet_matches.pet_a, pet_matches.pet_b) and p.owner_id = auth.uid()
            )
          );
      END IF;
    END IF;
  END IF;
END $$;

-- PET_MESSAGES: participants can read; sender pet owner can write
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'pet_messages'
  ) THEN
    EXECUTE 'ALTER TABLE public.pet_messages ENABLE ROW LEVEL SECURITY';

    IF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'pet_messages'
        AND column_name = 'match_id'
    ) THEN
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'pet_messages'
          AND policyname = 'PetMessages: participant select'
      ) THEN
        CREATE POLICY "PetMessages: participant select" ON public.pet_messages
          FOR SELECT USING (
            exists (
              select 1
              from public.pet_matches m
              join public.pets p on p.id in (m.pet_a, m.pet_b)
              where m.id = pet_messages.match_id
                and p.owner_id = auth.uid()
            )
          );
      END IF;
    END IF;

    IF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'pet_messages'
        AND column_name = 'sender_pet_id'
    ) THEN
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'pet_messages'
          AND policyname = 'PetMessages: sender insert'
      ) THEN
        CREATE POLICY "PetMessages: sender insert" ON public.pet_messages
          FOR INSERT WITH CHECK (
            exists (
              select 1 from public.pets p
              where p.id = pet_messages.sender_pet_id and p.owner_id = auth.uid()
            )
          );
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'pet_messages'
          AND policyname = 'PetMessages: sender update'
      ) THEN
        CREATE POLICY "PetMessages: sender update" ON public.pet_messages
          FOR UPDATE USING (
            exists (
              select 1 from public.pets p
              where p.id = pet_messages.sender_pet_id and p.owner_id = auth.uid()
            )
          ) WITH CHECK (
            exists (
              select 1 from public.pets p
              where p.id = pet_messages.sender_pet_id and p.owner_id = auth.uid()
            )
          );
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'pet_messages'
          AND policyname = 'PetMessages: sender delete'
      ) THEN
        CREATE POLICY "PetMessages: sender delete" ON public.pet_messages
          FOR DELETE USING (
            exists (
              select 1 from public.pets p
              where p.id = pet_messages.sender_pet_id and p.owner_id = auth.uid()
            )
          );
      END IF;
    END IF;
  END IF;
END $$;

-- PRODUCTS & CATEGORIES: public read; restrict writes to server
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'products'
  ) THEN
    EXECUTE 'ALTER TABLE public.products ENABLE ROW LEVEL SECURITY';
    IF NOT EXISTS (
      SELECT 1 FROM pg_policies
      WHERE schemaname = 'public'
        AND tablename = 'products'
        AND policyname = 'Products: public select'
    ) THEN
      CREATE POLICY "Products: public select" ON public.products
        FOR SELECT USING (true);
    END IF;
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'product_categories'
  ) THEN
    EXECUTE 'ALTER TABLE public.product_categories ENABLE ROW LEVEL SECURITY';
    IF NOT EXISTS (
      SELECT 1 FROM pg_policies
      WHERE schemaname = 'public'
        AND tablename = 'product_categories'
        AND policyname = 'ProductCategories: public select'
    ) THEN
      CREATE POLICY "ProductCategories: public select" ON public.product_categories
        FOR SELECT USING (true);
    END IF;
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'product_category_map'
  ) THEN
    EXECUTE 'ALTER TABLE public.product_category_map ENABLE ROW LEVEL SECURITY';
    IF NOT EXISTS (
      SELECT 1 FROM pg_policies
      WHERE schemaname = 'public'
        AND tablename = 'product_category_map'
        AND policyname = 'ProductCategoryMap: public select'
    ) THEN
      CREATE POLICY "ProductCategoryMap: public select" ON public.product_category_map
        FOR SELECT USING (true);
    END IF;
  END IF;
END $$;

-- PURCHASES (if table exists): only owner can access
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'purchases'
  ) THEN
    EXECUTE 'ALTER TABLE public.purchases ENABLE ROW LEVEL SECURITY';

    IF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'purchases'
        AND column_name = 'user_id'
    ) THEN
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'purchases'
          AND policyname = 'Purchases: self select'
      ) THEN
        CREATE POLICY "Purchases: self select" ON public.purchases
          FOR SELECT USING (user_id::text = auth.uid()::text);
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'purchases'
          AND policyname = 'Purchases: self insert'
      ) THEN
        CREATE POLICY "Purchases: self insert" ON public.purchases
          FOR INSERT WITH CHECK (user_id::text = auth.uid()::text);
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'purchases'
          AND policyname = 'Purchases: self update'
      ) THEN
        CREATE POLICY "Purchases: self update" ON public.purchases
          FOR UPDATE USING (user_id::text = auth.uid()::text) WITH CHECK (user_id::text = auth.uid()::text);
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'purchases'
          AND policyname = 'Purchases: self delete'
      ) THEN
        CREATE POLICY "Purchases: self delete" ON public.purchases
          FOR DELETE USING (user_id::text = auth.uid()::text);
      END IF;
    ELSIF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'purchases'
        AND column_name = 'profile_id'
    ) THEN
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'purchases'
          AND policyname = 'Purchases: self select'
      ) THEN
        CREATE POLICY "Purchases: self select" ON public.purchases
          FOR SELECT USING (profile_id::text = auth.uid()::text);
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'purchases'
          AND policyname = 'Purchases: self insert'
      ) THEN
        CREATE POLICY "Purchases: self insert" ON public.purchases
          FOR INSERT WITH CHECK (profile_id::text = auth.uid()::text);
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'purchases'
          AND policyname = 'Purchases: self update'
      ) THEN
        CREATE POLICY "Purchases: self update" ON public.purchases
          FOR UPDATE USING (profile_id::text = auth.uid()::text) WITH CHECK (profile_id::text = auth.uid()::text);
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'purchases'
          AND policyname = 'Purchases: self delete'
      ) THEN
        CREATE POLICY "Purchases: self delete" ON public.purchases
          FOR DELETE USING (profile_id::text = auth.uid()::text);
      END IF;
    END IF;
  END IF;
END $$;
