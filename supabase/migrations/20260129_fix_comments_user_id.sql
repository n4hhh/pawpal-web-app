-- Fix post_comments table to use text for user_id instead of UUID
-- This allows us to store usernames directly without requiring auth

-- Drop the foreign key constraint first
ALTER TABLE public.post_comments 
DROP CONSTRAINT IF EXISTS post_comments_user_id_fkey;

-- Change user_id column type from UUID to text
ALTER TABLE public.post_comments 
ALTER COLUMN user_id TYPE text USING user_id::text;

-- Delete any existing comments (optional - remove if you want to keep data)
-- TRUNCATE TABLE public.post_comments;
