-- Add trending metrics to pets table
-- This migration adds columns to track engagement and calculate trending scores

-- Add engagement metrics columns
ALTER TABLE public.pets 
ADD COLUMN IF NOT EXISTS view_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS like_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS match_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS trending_score NUMERIC(10,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS last_trending_update TIMESTAMPTZ DEFAULT now();

-- Create indexes for trending queries
CREATE INDEX IF NOT EXISTS idx_pets_trending_score ON public.pets(trending_score DESC);
CREATE INDEX IF NOT EXISTS idx_pets_created_trending ON public.pets(created_at DESC, trending_score DESC);

-- Create a function to update trending scores
-- Trending algorithm: 
-- - Weights: views (1x), likes (3x), matches (5x)
-- - Time decay: content older than 7 days gets reduced score
-- - Recency boost: content from last 24 hours gets 2x boost
CREATE OR REPLACE FUNCTION calculate_trending_score(
  p_view_count INTEGER,
  p_like_count INTEGER,
  p_match_count INTEGER,
  p_created_at TIMESTAMPTZ
) RETURNS NUMERIC AS $$
DECLARE
  base_score NUMERIC;
  time_factor NUMERIC;
  age_hours NUMERIC;
BEGIN
  -- Calculate base engagement score
  base_score := (p_view_count * 1.0) + (p_like_count * 3.0) + (p_match_count * 5.0);
  
  -- Calculate age in hours
  age_hours := EXTRACT(EPOCH FROM (now() - p_created_at)) / 3600;
  
  -- Apply time decay factor
  IF age_hours < 24 THEN
    -- Recent content (< 24 hours) gets a 2x boost
    time_factor := 2.0;
  ELSIF age_hours < 168 THEN
    -- Content < 7 days: gradual decay from 1.0 to 0.5
    time_factor := 1.0 - ((age_hours - 24) / 288);
  ELSE
    -- Content > 7 days: reduced but still visible
    time_factor := 0.5 * EXP(-age_hours / 1680);
  END IF;
  
  RETURN base_score * time_factor;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Create a function to update all trending scores
CREATE OR REPLACE FUNCTION update_all_trending_scores() RETURNS void AS $$
BEGIN
  UPDATE public.pets
  SET 
    trending_score = calculate_trending_score(view_count, like_count, match_count, created_at),
    last_trending_update = now()
  WHERE is_active = true;
END;
$$ LANGUAGE plpgsql;

-- Create triggers to auto-update trending score when metrics change
CREATE OR REPLACE FUNCTION update_pet_trending_score() RETURNS TRIGGER AS $$
BEGIN
  NEW.trending_score := calculate_trending_score(
    NEW.view_count, 
    NEW.like_count, 
    NEW.match_count, 
    NEW.created_at
  );
  NEW.last_trending_update := now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_trending_score
  BEFORE INSERT OR UPDATE OF view_count, like_count, match_count
  ON public.pets
  FOR EACH ROW
  EXECUTE FUNCTION update_pet_trending_score();

-- Create a view for trending pets (top 20)
CREATE OR REPLACE VIEW trending_pets AS
SELECT 
  id,
  owner_id,
  name,
  age,
  breed,
  gender,
  size,
  location,
  images,
  avatar,
  bio,
  view_count,
  like_count,
  match_count,
  trending_score,
  created_at
FROM public.pets
WHERE is_active = true
ORDER BY trending_score DESC, created_at DESC
LIMIT 20;

-- Grant permissions
GRANT SELECT ON trending_pets TO anon, authenticated;

-- Initialize trending scores for existing pets
SELECT update_all_trending_scores();
