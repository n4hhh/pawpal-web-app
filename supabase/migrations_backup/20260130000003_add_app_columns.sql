-- Add columns that the app expects for feed_posts
-- This allows the current app code to work without modifications

ALTER TABLE public.feed_posts 
ADD COLUMN IF NOT EXISTS pet_name text,
ADD COLUMN IF NOT EXISTS owner_name text,
ADD COLUMN IF NOT EXISTS time_ago text;
