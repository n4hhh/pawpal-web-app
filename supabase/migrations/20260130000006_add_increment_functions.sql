-- Add RPC functions for incrementing pet engagement metrics
-- These functions atomically increment counters and update trending scores

-- Function to increment pet view count
CREATE OR REPLACE FUNCTION increment_pet_view(pet_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE public.pets
  SET view_count = COALESCE(view_count, 0) + 1
  WHERE id = pet_id AND is_active = true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to increment pet like count
CREATE OR REPLACE FUNCTION increment_pet_like(pet_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE public.pets
  SET like_count = COALESCE(like_count, 0) + 1
  WHERE id = pet_id AND is_active = true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to increment pet match count
CREATE OR REPLACE FUNCTION increment_pet_match(pet_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE public.pets
  SET match_count = COALESCE(match_count, 0) + 1
  WHERE id = pet_id AND is_active = true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions to anon and authenticated users
GRANT EXECUTE ON FUNCTION increment_pet_view(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION increment_pet_like(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION increment_pet_match(UUID) TO anon, authenticated;
