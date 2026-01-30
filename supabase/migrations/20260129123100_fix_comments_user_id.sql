-- Fix post_comments table to use text for user_id instead of UUID
-- This allows us to store usernames directly without requiring auth

-- Drop ALL policies on post_comments table before altering column
DO $$
DECLARE
    pol record;
BEGIN
    FOR pol IN 
        SELECT policyname 
        FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'post_comments'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.post_comments', pol.policyname);
    END LOOP;
END $$;

-- Drop the foreign key constraint first
ALTER TABLE public.post_comments 
DROP CONSTRAINT IF EXISTS post_comments_user_id_fkey;

-- Change user_id column type from UUID to text
ALTER TABLE public.post_comments 
ALTER COLUMN user_id TYPE text USING user_id::text;

-- Recreate basic policies for post_comments
CREATE POLICY "PostComments: select" 
ON public.post_comments FOR SELECT 
USING (true);

CREATE POLICY "PostComments: author insert" 
ON public.post_comments FOR INSERT 
WITH CHECK (auth.uid()::text = user_id);

CREATE POLICY "PostComments: author update" 
ON public.post_comments FOR UPDATE 
USING (auth.uid()::text = user_id);

CREATE POLICY "PostComments: author delete" 
ON public.post_comments FOR DELETE 
USING (auth.uid()::text = user_id);

-- Delete any existing comments (optional - remove if you want to keep data)
-- TRUNCATE TABLE public.post_comments;
