-- Row-Level Security (RLS) policies for PawPals
-- Apply these in Supabase SQL Editor or include in migrations before enabling RLS in production.

-- PROFILES: users may read/insert/update/delete their own profile only
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'profiles'
  ) THEN
    EXECUTE 'ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY';
    IF NOT EXISTS (
      SELECT 1 FROM pg_policies
      WHERE schemaname = 'public'
        AND tablename = 'profiles'
        AND policyname = 'Profiles: self select'
    ) THEN
      CREATE POLICY "Profiles: self select" ON public.profiles
        FOR SELECT USING (auth.uid() = id);
    END IF;
    IF NOT EXISTS (
      SELECT 1 FROM pg_policies
      WHERE schemaname = 'public'
        AND tablename = 'profiles'
        AND policyname = 'Profiles: self insert'
    ) THEN
      CREATE POLICY "Profiles: self insert" ON public.profiles
        FOR INSERT WITH CHECK (auth.uid() = id);
    END IF;
    IF NOT EXISTS (
      SELECT 1 FROM pg_policies
      WHERE schemaname = 'public'
        AND tablename = 'profiles'
        AND policyname = 'Profiles: self update'
    ) THEN
      CREATE POLICY "Profiles: self update" ON public.profiles
        FOR UPDATE USING (auth.uid() = id) WITH CHECK (auth.uid() = id);
    END IF;
    IF NOT EXISTS (
      SELECT 1 FROM pg_policies
      WHERE schemaname = 'public'
        AND tablename = 'profiles'
        AND policyname = 'Profiles: self delete'
    ) THEN
      CREATE POLICY "Profiles: self delete" ON public.profiles
        FOR DELETE USING (auth.uid() = id);
    END IF;
  END IF;
END $$;

-- PETS: public can view; only owner can create/update/delete
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'pets'
  ) THEN
    EXECUTE 'ALTER TABLE public.pets ENABLE ROW LEVEL SECURITY';
    IF NOT EXISTS (
      SELECT 1 FROM pg_policies
      WHERE schemaname = 'public'
        AND tablename = 'pets'
        AND policyname = 'Pets: public select'
    ) THEN
      CREATE POLICY "Pets: public select" ON public.pets
        FOR SELECT USING (true);
    END IF;
    IF NOT EXISTS (
      SELECT 1 FROM pg_policies
      WHERE schemaname = 'public'
        AND tablename = 'pets'
        AND policyname = 'Pets: owner insert'
    ) THEN
      CREATE POLICY "Pets: owner insert" ON public.pets
        FOR INSERT WITH CHECK (owner_id = auth.uid());
    END IF;
    IF NOT EXISTS (
      SELECT 1 FROM pg_policies
      WHERE schemaname = 'public'
        AND tablename = 'pets'
        AND policyname = 'Pets: owner update'
    ) THEN
      CREATE POLICY "Pets: owner update" ON public.pets
        FOR UPDATE USING (owner_id = auth.uid()) WITH CHECK (owner_id = auth.uid());
    END IF;
    IF NOT EXISTS (
      SELECT 1 FROM pg_policies
      WHERE schemaname = 'public'
        AND tablename = 'pets'
        AND policyname = 'Pets: owner delete'
    ) THEN
      CREATE POLICY "Pets: owner delete" ON public.pets
        FOR DELETE USING (owner_id = auth.uid());
    END IF;
  END IF;
END $$;

-- FEED POSTS: public read; owners may insert/update/delete their posts
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'feed_posts'
  ) THEN
    EXECUTE 'ALTER TABLE public.feed_posts ENABLE ROW LEVEL SECURITY';
    IF NOT EXISTS (
      SELECT 1 FROM pg_policies
      WHERE schemaname = 'public'
        AND tablename = 'feed_posts'
        AND policyname = 'Feed: public select'
    ) THEN
      CREATE POLICY "Feed: public select" ON public.feed_posts
        FOR SELECT USING (true);
    END IF;

    IF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'feed_posts'
        AND column_name = 'profile_id'
    ) THEN
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'feed_posts'
          AND policyname = 'Feed: insert as owner'
      ) THEN
        CREATE POLICY "Feed: insert as owner" ON public.feed_posts
          FOR INSERT WITH CHECK (profile_id = auth.uid());
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'feed_posts'
          AND policyname = 'Feed: update owner'
      ) THEN
        CREATE POLICY "Feed: update owner" ON public.feed_posts
          FOR UPDATE USING (profile_id = auth.uid()) WITH CHECK (profile_id = auth.uid());
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'feed_posts'
          AND policyname = 'Feed: delete owner'
      ) THEN
        CREATE POLICY "Feed: delete owner" ON public.feed_posts
          FOR DELETE USING (profile_id = auth.uid());
      END IF;
    ELSIF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'feed_posts'
        AND column_name = 'author_id'
    ) THEN
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'feed_posts'
          AND policyname = 'Feed: insert as owner'
      ) THEN
        CREATE POLICY "Feed: insert as owner" ON public.feed_posts
          FOR INSERT WITH CHECK (author_id = auth.uid());
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'feed_posts'
          AND policyname = 'Feed: update owner'
      ) THEN
        CREATE POLICY "Feed: update owner" ON public.feed_posts
          FOR UPDATE USING (author_id = auth.uid()) WITH CHECK (author_id = auth.uid());
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'feed_posts'
          AND policyname = 'Feed: delete owner'
      ) THEN
        CREATE POLICY "Feed: delete owner" ON public.feed_posts
          FOR DELETE USING (author_id = auth.uid());
      END IF;
    ELSIF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'feed_posts'
        AND column_name = 'owner_id'
    ) THEN
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'feed_posts'
          AND policyname = 'Feed: insert as owner'
      ) THEN
        CREATE POLICY "Feed: insert as owner" ON public.feed_posts
          FOR INSERT WITH CHECK (owner_id = auth.uid());
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'feed_posts'
          AND policyname = 'Feed: update owner'
      ) THEN
        CREATE POLICY "Feed: update owner" ON public.feed_posts
          FOR UPDATE USING (owner_id = auth.uid()) WITH CHECK (owner_id = auth.uid());
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'feed_posts'
          AND policyname = 'Feed: delete owner'
      ) THEN
        CREATE POLICY "Feed: delete owner" ON public.feed_posts
          FOR DELETE USING (owner_id = auth.uid());
      END IF;
    END IF;
  END IF;
END $$;

-- COMMENTS: anyone can read comments; only author can insert/update/delete their comments
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'comments'
  ) THEN
    EXECUTE 'ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY';
    IF NOT EXISTS (
      SELECT 1 FROM pg_policies
      WHERE schemaname = 'public'
        AND tablename = 'comments'
        AND policyname = 'Comments: public select'
    ) THEN
      CREATE POLICY "Comments: public select" ON public.comments
        FOR SELECT USING (true);
    END IF;
    IF NOT EXISTS (
      SELECT 1 FROM pg_policies
      WHERE schemaname = 'public'
        AND tablename = 'comments'
        AND policyname = 'Comments: author insert'
    ) THEN
      CREATE POLICY "Comments: author insert" ON public.comments
        FOR INSERT WITH CHECK (author_id = auth.uid());
    END IF;
    IF NOT EXISTS (
      SELECT 1 FROM pg_policies
      WHERE schemaname = 'public'
        AND tablename = 'comments'
        AND policyname = 'Comments: author update'
    ) THEN
      CREATE POLICY "Comments: author update" ON public.comments
        FOR UPDATE USING (author_id = auth.uid()) WITH CHECK (author_id = auth.uid());
    END IF;
    IF NOT EXISTS (
      SELECT 1 FROM pg_policies
      WHERE schemaname = 'public'
        AND tablename = 'comments'
        AND policyname = 'Comments: author delete'
    ) THEN
      CREATE POLICY "Comments: author delete" ON public.comments
        FOR DELETE USING (author_id = auth.uid());
    END IF;
  END IF;
END $$;

-- POST LIKES: allow public read; users can like/unlike their own identity
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'post_likes'
  ) THEN
    EXECUTE 'ALTER TABLE public.post_likes ENABLE ROW LEVEL SECURITY';
    IF NOT EXISTS (
      SELECT 1 FROM pg_policies
      WHERE schemaname = 'public'
        AND tablename = 'post_likes'
        AND policyname = 'PostLikes: public select'
    ) THEN
      CREATE POLICY "PostLikes: public select" ON public.post_likes
        FOR SELECT USING (true);
    END IF;

    IF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'post_likes'
        AND column_name = 'profile_id'
    ) THEN
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'post_likes'
          AND policyname = 'PostLikes: insert by profile'
      ) THEN
        CREATE POLICY "PostLikes: insert by profile" ON public.post_likes
          FOR INSERT WITH CHECK (profile_id = auth.uid());
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'post_likes'
          AND policyname = 'PostLikes: delete by profile'
      ) THEN
        CREATE POLICY "PostLikes: delete by profile" ON public.post_likes
          FOR DELETE USING (profile_id = auth.uid());
      END IF;
    ELSIF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'post_likes'
        AND column_name = 'user_id'
    ) THEN
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'post_likes'
          AND policyname = 'PostLikes: insert by profile'
      ) THEN
        CREATE POLICY "PostLikes: insert by profile" ON public.post_likes
          FOR INSERT WITH CHECK (user_id = auth.uid());
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'post_likes'
          AND policyname = 'PostLikes: delete by profile'
      ) THEN
        CREATE POLICY "PostLikes: delete by profile" ON public.post_likes
          FOR DELETE USING (user_id = auth.uid());
      END IF;
    END IF;
  END IF;
END $$;

-- SWIPES: users can only read/create/update/delete their own swipes
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'swipes'
  ) THEN
    EXECUTE 'ALTER TABLE public.swipes ENABLE ROW LEVEL SECURITY';
    IF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'swipes'
        AND column_name = 'swiper_id'
    ) THEN
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'swipes'
          AND policyname = 'Swipes: self select'
      ) THEN
        CREATE POLICY "Swipes: self select" ON public.swipes
          FOR SELECT USING (swiper_id = auth.uid());
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'swipes'
          AND policyname = 'Swipes: self insert'
      ) THEN
        CREATE POLICY "Swipes: self insert" ON public.swipes
          FOR INSERT WITH CHECK (swiper_id = auth.uid());
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'swipes'
          AND policyname = 'Swipes: self update'
      ) THEN
        CREATE POLICY "Swipes: self update" ON public.swipes
          FOR UPDATE USING (swiper_id = auth.uid()) WITH CHECK (swiper_id = auth.uid());
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'swipes'
          AND policyname = 'Swipes: self delete'
      ) THEN
        CREATE POLICY "Swipes: self delete" ON public.swipes
          FOR DELETE USING (swiper_id = auth.uid());
      END IF;
    END IF;
  END IF;
END $$;

-- MATCHES: allow participants to see matches involving them
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'matches'
  ) THEN
    EXECUTE 'ALTER TABLE public.matches ENABLE ROW LEVEL SECURITY';

    IF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'matches'
        AND column_name = 'profile_a'
    ) AND EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'matches'
        AND column_name = 'profile_b'
    ) THEN
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'matches'
          AND policyname = 'Matches: participant select'
      ) THEN
        CREATE POLICY "Matches: participant select" ON public.matches
          FOR SELECT USING (
            profile_a = auth.uid() OR profile_b = auth.uid()
          );
      END IF;
    ELSIF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'matches'
        AND column_name = 'user_a'
    ) AND EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'matches'
        AND column_name = 'user_b'
    ) THEN
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'matches'
          AND policyname = 'Matches: participant select'
      ) THEN
        CREATE POLICY "Matches: participant select" ON public.matches
          FOR SELECT USING (
            user_a = auth.uid() OR user_b = auth.uid()
          );
      END IF;
    END IF;
  END IF;
END $$;
-- Matches are typically created by backend logic; restrict inserts/updates to service role (no open policy)

-- CONVERSATIONS & PARTICIPANTS
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'conversation_participants'
  ) THEN
    EXECUTE 'ALTER TABLE public.conversation_participants ENABLE ROW LEVEL SECURITY';
    IF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'conversation_participants'
        AND column_name = 'profile_id'
    ) THEN
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'conversation_participants'
          AND policyname = 'ConvParts: self select'
      ) THEN
        CREATE POLICY "ConvParts: self select" ON public.conversation_participants
          FOR SELECT USING (profile_id = auth.uid());
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'conversation_participants'
          AND policyname = 'ConvParts: self insert'
      ) THEN
        CREATE POLICY "ConvParts: self insert" ON public.conversation_participants
          FOR INSERT WITH CHECK (profile_id = auth.uid());
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'conversation_participants'
          AND policyname = 'ConvParts: self delete'
      ) THEN
        CREATE POLICY "ConvParts: self delete" ON public.conversation_participants
          FOR DELETE USING (profile_id = auth.uid());
      END IF;
    ELSIF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'conversation_participants'
        AND column_name = 'user_id'
    ) THEN
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'conversation_participants'
          AND policyname = 'ConvParts: self select'
      ) THEN
        CREATE POLICY "ConvParts: self select" ON public.conversation_participants
          FOR SELECT USING (user_id = auth.uid());
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'conversation_participants'
          AND policyname = 'ConvParts: self insert'
      ) THEN
        CREATE POLICY "ConvParts: self insert" ON public.conversation_participants
          FOR INSERT WITH CHECK (user_id = auth.uid());
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'conversation_participants'
          AND policyname = 'ConvParts: self delete'
      ) THEN
        CREATE POLICY "ConvParts: self delete" ON public.conversation_participants
          FOR DELETE USING (user_id = auth.uid());
      END IF;
    END IF;
  END IF;
END $$;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'conversations'
  ) THEN
    EXECUTE 'ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY';

    IF EXISTS (
      SELECT 1 FROM information_schema.tables
      WHERE table_schema = 'public'
        AND table_name = 'conversation_participants'
    ) AND EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'conversation_participants'
        AND column_name = 'conversation_id'
    ) AND EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'conversation_participants'
        AND column_name = 'profile_id'
    ) THEN
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'conversations'
          AND policyname = 'Conversations: participant select'
      ) THEN
        CREATE POLICY "Conversations: participant select" ON public.conversations
          FOR SELECT USING (
            exists (
              select 1 from public.conversation_participants cp
              where cp.conversation_id = public.conversations.id and cp.profile_id = auth.uid()
            )
          );
      END IF;
    ELSIF EXISTS (
      SELECT 1 FROM information_schema.tables
      WHERE table_schema = 'public'
        AND table_name = 'conversation_participants'
    ) AND EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'conversation_participants'
        AND column_name = 'conversation_id'
    ) AND EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'conversation_participants'
        AND column_name = 'user_id'
    ) THEN
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'conversations'
          AND policyname = 'Conversations: participant select'
      ) THEN
        CREATE POLICY "Conversations: participant select" ON public.conversations
          FOR SELECT USING (
            exists (
              select 1 from public.conversation_participants cp
              where cp.conversation_id = public.conversations.id and cp.user_id = auth.uid()
            )
          );
      END IF;
    END IF;
  END IF;
END $$;
-- Insert/update/delete for conversations should be restricted to application server (no open policy)

-- MESSAGES: participants can read; sender may insert/update/delete their own messages
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'messages'
  ) THEN
    EXECUTE 'ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY';

    IF EXISTS (
      SELECT 1 FROM information_schema.tables
      WHERE table_schema = 'public'
        AND table_name = 'conversation_participants'
    ) AND EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'conversation_participants'
        AND column_name = 'conversation_id'
    ) AND EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'conversation_participants'
        AND column_name = 'profile_id'
    ) THEN
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'messages'
          AND policyname = 'Messages: participant select'
      ) THEN
        CREATE POLICY "Messages: participant select" ON public.messages
          FOR SELECT USING (
            exists (
              select 1 from public.conversation_participants cp
              where cp.conversation_id = public.messages.conversation_id and cp.profile_id = auth.uid()
            )
          );
      END IF;
    ELSIF EXISTS (
      SELECT 1 FROM information_schema.tables
      WHERE table_schema = 'public'
        AND table_name = 'conversation_participants'
    ) AND EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'conversation_participants'
        AND column_name = 'conversation_id'
    ) AND EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'conversation_participants'
        AND column_name = 'user_id'
    ) THEN
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'messages'
          AND policyname = 'Messages: participant select'
      ) THEN
        CREATE POLICY "Messages: participant select" ON public.messages
          FOR SELECT USING (
            exists (
              select 1 from public.conversation_participants cp
              where cp.conversation_id = public.messages.conversation_id and cp.user_id = auth.uid()
            )
          );
      END IF;
    END IF;

    IF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'messages'
        AND column_name = 'sender_id'
    ) THEN
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'messages'
          AND policyname = 'Messages: sender insert'
      ) THEN
        CREATE POLICY "Messages: sender insert" ON public.messages
          FOR INSERT WITH CHECK (sender_id = auth.uid());
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'messages'
          AND policyname = 'Messages: sender update'
      ) THEN
        CREATE POLICY "Messages: sender update" ON public.messages
          FOR UPDATE USING (sender_id = auth.uid()) WITH CHECK (sender_id = auth.uid());
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'messages'
          AND policyname = 'Messages: sender delete'
      ) THEN
        CREATE POLICY "Messages: sender delete" ON public.messages
          FOR DELETE USING (sender_id = auth.uid());
      END IF;
    ELSIF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'messages'
        AND column_name = 'user_id'
    ) THEN
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'messages'
          AND policyname = 'Messages: sender insert'
      ) THEN
        CREATE POLICY "Messages: sender insert" ON public.messages
          FOR INSERT WITH CHECK (user_id = auth.uid());
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'messages'
          AND policyname = 'Messages: sender update'
      ) THEN
        CREATE POLICY "Messages: sender update" ON public.messages
          FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'messages'
          AND policyname = 'Messages: sender delete'
      ) THEN
        CREATE POLICY "Messages: sender delete" ON public.messages
          FOR DELETE USING (user_id = auth.uid());
      END IF;
    END IF;
  END IF;
END $$;

-- SHOP ITEMS: public read; restrict mutations to server-side (no policies for insert/update/delete)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'shop_items'
  ) THEN
    EXECUTE 'ALTER TABLE public.shop_items ENABLE ROW LEVEL SECURITY';
    IF NOT EXISTS (
      SELECT 1 FROM pg_policies
      WHERE schemaname = 'public'
        AND tablename = 'shop_items'
        AND policyname = 'ShopItems: public select'
    ) THEN
      CREATE POLICY "ShopItems: public select" ON public.shop_items
        FOR SELECT USING (true);
    END IF;
  END IF;
END $$;

-- ORDERS & ORDER_ITEMS: users can only access their own orders
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'orders'
  ) THEN
    EXECUTE 'ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY';
    IF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'orders'
        AND column_name = 'profile_id'
    ) THEN
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'orders'
          AND policyname = 'Orders: self select'
      ) THEN
        CREATE POLICY "Orders: self select" ON public.orders
          FOR SELECT USING (profile_id = auth.uid());
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'orders'
          AND policyname = 'Orders: self insert'
      ) THEN
        CREATE POLICY "Orders: self insert" ON public.orders
          FOR INSERT WITH CHECK (profile_id = auth.uid());
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'orders'
          AND policyname = 'Orders: self update'
      ) THEN
        CREATE POLICY "Orders: self update" ON public.orders
          FOR UPDATE USING (profile_id = auth.uid()) WITH CHECK (profile_id = auth.uid());
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'orders'
          AND policyname = 'Orders: self delete'
      ) THEN
        CREATE POLICY "Orders: self delete" ON public.orders
          FOR DELETE USING (profile_id = auth.uid());
      END IF;
    ELSIF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'orders'
        AND column_name = 'user_id'
    ) THEN
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'orders'
          AND policyname = 'Orders: self select'
      ) THEN
        CREATE POLICY "Orders: self select" ON public.orders
          FOR SELECT USING (user_id = auth.uid());
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'orders'
          AND policyname = 'Orders: self insert'
      ) THEN
        CREATE POLICY "Orders: self insert" ON public.orders
          FOR INSERT WITH CHECK (user_id = auth.uid());
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'orders'
          AND policyname = 'Orders: self update'
      ) THEN
        CREATE POLICY "Orders: self update" ON public.orders
          FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'orders'
          AND policyname = 'Orders: self delete'
      ) THEN
        CREATE POLICY "Orders: self delete" ON public.orders
          FOR DELETE USING (user_id = auth.uid());
      END IF;
    END IF;
  END IF;
END $$;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'order_items'
  ) THEN
    EXECUTE 'ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY';
    IF EXISTS (
      SELECT 1 FROM information_schema.tables
      WHERE table_schema = 'public'
        AND table_name = 'orders'
    ) AND EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'order_items'
        AND column_name = 'order_id'
    ) AND EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'orders'
        AND column_name = 'profile_id'
    ) THEN
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'order_items'
          AND policyname = 'OrderItems: order owner select'
      ) THEN
        CREATE POLICY "OrderItems: order owner select" ON public.order_items
          FOR SELECT USING (
            exists (
              select 1 from public.orders o
              where o.id = public.order_items.order_id
                and o.profile_id = auth.uid()
            )
          );
      END IF;
    ELSIF EXISTS (
      SELECT 1 FROM information_schema.tables
      WHERE table_schema = 'public'
        AND table_name = 'orders'
    ) AND EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'order_items'
        AND column_name = 'order_id'
    ) AND EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'orders'
        AND column_name = 'user_id'
    ) THEN
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'order_items'
          AND policyname = 'OrderItems: order owner select'
      ) THEN
        CREATE POLICY "OrderItems: order owner select" ON public.order_items
          FOR SELECT USING (
            exists (
              select 1 from public.orders o
              where o.id = public.order_items.order_id
                and o.user_id = auth.uid()
            )
          );
      END IF;
    END IF;
  END IF;
END $$;

-- NOTIFICATIONS: only recipient can read/insert/update/delete their notifications
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'notifications'
  ) THEN
    EXECUTE 'ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY';
    IF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'notifications'
        AND column_name = 'profile_id'
    ) THEN
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'notifications'
          AND policyname = 'Notifications: self select'
      ) THEN
        CREATE POLICY "Notifications: self select" ON public.notifications
          FOR SELECT USING (profile_id = auth.uid());
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'notifications'
          AND policyname = 'Notifications: self insert'
      ) THEN
        CREATE POLICY "Notifications: self insert" ON public.notifications
          FOR INSERT WITH CHECK (profile_id = auth.uid());
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'notifications'
          AND policyname = 'Notifications: self update'
      ) THEN
        CREATE POLICY "Notifications: self update" ON public.notifications
          FOR UPDATE USING (profile_id = auth.uid()) WITH CHECK (profile_id = auth.uid());
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'notifications'
          AND policyname = 'Notifications: self delete'
      ) THEN
        CREATE POLICY "Notifications: self delete" ON public.notifications
          FOR DELETE USING (profile_id = auth.uid());
      END IF;
    ELSIF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'notifications'
        AND column_name = 'user_id'
    ) THEN
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'notifications'
          AND policyname = 'Notifications: self select'
      ) THEN
        CREATE POLICY "Notifications: self select" ON public.notifications
          FOR SELECT USING (user_id = auth.uid());
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'notifications'
          AND policyname = 'Notifications: self insert'
      ) THEN
        CREATE POLICY "Notifications: self insert" ON public.notifications
          FOR INSERT WITH CHECK (user_id = auth.uid());
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'notifications'
          AND policyname = 'Notifications: self update'
      ) THEN
        CREATE POLICY "Notifications: self update" ON public.notifications
          FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'notifications'
          AND policyname = 'Notifications: self delete'
      ) THEN
        CREATE POLICY "Notifications: self delete" ON public.notifications
          FOR DELETE USING (user_id = auth.uid());
      END IF;
    END IF;
  END IF;
END $$;

-- Final note: review policies before enabling in production. Some actions (e.g., creating matches,
-- administrative product updates) should be performed server-side with the service_role key.
