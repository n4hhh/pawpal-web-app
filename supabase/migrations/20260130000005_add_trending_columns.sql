-- Add trending metrics to pets table

ALTER TABLE public.pets 
ADD COLUMN IF NOT EXISTS view_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS like_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS match_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS trending_score NUMERIC(10,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS last_trending_update TIMESTAMPTZ DEFAULT now(),
ADD COLUMN IF NOT EXISTS gender text;

-- Indexes
CREATE INDEX IF NOT EXISTS idx_pets_trending_score 
  ON public.pets(trending_score DESC);

CREATE INDEX IF NOT EXISTS idx_pets_created_trending 
  ON public.pets(created_at DESC, trending_score DESC);

-- Trending score function
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
  base_score := (p_view_count * 1.0) 
              + (p_like_count * 3.0) 
              + (p_match_count * 5.0);

  age_hours := EXTRACT(EPOCH FROM (now() - p_created_at)) / 3600;

  IF age_hours < 24 THEN
    time_factor := 2.0;
  ELSIF age_hours < 168 THEN
    time_factor := 1.0 - ((age_hours - 24) / 288);
  ELSE
    time_factor := 0.5 * EXP(-age_hours / 1680);
  END IF;

  RETURN base_score * time_factor;
END;
$$ LANGUAGE plpgsql STABLE;

-- Update all pets
CREATE OR REPLACE FUNCTION update_all_trending_scores() 
RETURNS void AS $$
BEGIN
  UPDATE public.pets
  SET 
    trending_score = calculate_trending_score(
      view_count, like_count, match_count, created_at
    ),
    last_trending_update = now()
  WHERE is_active = true;
END;
$$ LANGUAGE plpgsql;

-- Trigger function
CREATE OR REPLACE FUNCTION update_pet_trending_score() 
RETURNS TRIGGER AS $$
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

-- Trigger (SAFE)
DROP TRIGGER IF EXISTS trigger_update_trending_score ON public.pets;
CREATE TRIGGER trigger_update_trending_score
  BEFORE INSERT OR UPDATE OF view_count, like_count, match_count
  ON public.pets
  FOR EACH ROW
  EXECUTE FUNCTION update_pet_trending_score();

-- View
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

GRANT SELECT ON trending_pets TO anon, authenticated;

-- Initialize
SELECT update_all_trending_scores();
