-- Create stories table
CREATE TABLE IF NOT EXISTS public.stories (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    media_url text NOT NULL,
    media_type text NOT NULL CHECK (media_type IN ('image', 'video')),
    caption text,
    created_at timestamptz DEFAULT now() NOT NULL,
    expires_at timestamptz DEFAULT (now() + interval '24 hours') NOT NULL,
    view_count integer DEFAULT 0 NOT NULL
);

-- Create story_views table
CREATE TABLE IF NOT EXISTS public.story_views (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    story_id uuid NOT NULL REFERENCES public.stories(id) ON DELETE CASCADE,
    viewer_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    viewed_at timestamptz DEFAULT now() NOT NULL,
    UNIQUE(story_id, viewer_id)
);

-- Enable RLS
ALTER TABLE public.stories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.story_views ENABLE ROW LEVEL SECURITY;

-- =====================
-- RLS POLICIES: stories
-- =====================

DROP POLICY IF EXISTS "Anyone can view non-expired stories" ON public.stories;
CREATE POLICY "Anyone can view non-expired stories"
    ON public.stories
    FOR SELECT
    USING (expires_at > now());

DROP POLICY IF EXISTS "Users can insert their own stories" ON public.stories;
CREATE POLICY "Users can insert their own stories"
    ON public.stories
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own stories" ON public.stories;
CREATE POLICY "Users can delete their own stories"
    ON public.stories
    FOR DELETE
    USING (auth.uid() = user_id);

-- =========================
-- RLS POLICIES: story_views
-- =========================

DROP POLICY IF EXISTS "Users can view story views for their own stories" ON public.story_views;
CREATE POLICY "Users can view story views for their own stories"
    ON public.story_views
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1
            FROM public.stories
            WHERE stories.id = story_views.story_id
              AND stories.user_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "Anyone can insert story views" ON public.story_views;
CREATE POLICY "Anyone can insert story views"
    ON public.story_views
    FOR INSERT
    WITH CHECK (auth.uid() = viewer_id);

-- =====================
-- VIEW COUNT FUNCTION
-- =====================

CREATE OR REPLACE FUNCTION increment_story_view_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.stories
    SET view_count = view_count + 1
    WHERE id = NEW.story_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =====================
-- TRIGGER (SAFE)
-- =====================

DROP TRIGGER IF EXISTS increment_story_views ON public.story_views;
CREATE TRIGGER increment_story_views
    AFTER INSERT ON public.story_views
    FOR EACH ROW
    EXECUTE FUNCTION increment_story_view_count();

-- =====================
-- INDEXES (SAFE)
-- =====================

CREATE INDEX IF NOT EXISTS idx_stories_user_id
    ON public.stories(user_id);

CREATE INDEX IF NOT EXISTS idx_stories_expires_at
    ON public.stories(expires_at);

CREATE INDEX IF NOT EXISTS idx_story_views_story_id
    ON public.story_views(story_id);

CREATE INDEX IF NOT EXISTS idx_story_views_viewer_id
    ON public.story_views(viewer_id);
