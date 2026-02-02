-- Seed data for testing the trending pets algorithm
-- Run this after applying the trending migrations

-- Update existing pets with engagement metrics for testing
UPDATE public.pets
SET 
  view_count = floor(random() * 100)::INTEGER,
  like_count = floor(random() * 50)::INTEGER,
  match_count = floor(random() * 20)::INTEGER
WHERE is_active = true;

-- Update trending scores for all pets
SELECT update_all_trending_scores();

-- Create some hot trending pets (recent with high engagement)
INSERT INTO public.pets (
  name, age, breed, gender, size, location, images, avatar, bio, 
  view_count, like_count, match_count, is_active, created_at
)
VALUES
  (
    'Luna', '3 yrs', 'Husky', 'Female', 'Large', '3 miles away',
    ARRAY['https://images.unsplash.com/photo-1568572933382-74d440642117?w=400'],
    'https://images.unsplash.com/photo-1568572933382-74d440642117?w=100',
    'Energetic and loves the snow! Looking for an adventure buddy. 🎿❄️',
    150, 85, 35, true, now() - interval '12 hours'
  ),
  (
    'Milo', '1 yr', 'Golden Doodle', 'Male', 'Medium', '1 mile away',
    ARRAY['https://images.unsplash.com/photo-1537151608828-ea2b11777ee8?w=400'],
    'https://images.unsplash.com/photo-1537151608828-ea2b11777ee8?w=100',
    'Super friendly and loves everyone! Best cuddle buddy ever. 🧸',
    200, 120, 45, true, now() - interval '6 hours'
  ),
  (
    'Bella', '2 yrs', 'Persian Cat', 'Female', 'Small', '4 miles away',
    ARRAY['https://images.unsplash.com/photo-1543852786-1cf6624b9987?w=400'],
    'https://images.unsplash.com/photo-1543852786-1cf6624b9987?w=100',
    'Sophisticated and loves gourmet treats. Seeking refined company. 👑',
    180, 95, 40, true, now() - interval '18 hours'
  ),
  (
    'Charlie', '4 yrs', 'Beagle', 'Male', 'Small', '2 miles away',
    ARRAY['https://images.unsplash.com/photo-1505628346881-b72b27e84530?w=400'],
    'https://images.unsplash.com/photo-1505628346881-b72b27e84530?w=100',
    'Professional sniffer and treat enthusiast. Let''s explore together! 🐕',
    95, 60, 25, true, now() - interval '2 days'
  ),
  (
    'Daisy', '6 mo', 'Corgi', 'Female', 'Small', '5 miles away',
    ARRAY['https://images.unsplash.com/photo-1546527868-ccb7ee7dfa6a?w=400'],
    'https://images.unsplash.com/photo-1546527868-ccb7ee7dfa6a?w=100',
    'Puppy with big personality! Short legs, big heart. 🐾💕',
    250, 140, 55, true, now() - interval '3 hours'
  )
ON CONFLICT DO NOTHING;

-- Update trending scores after inserting new data
SELECT update_all_trending_scores();

-- Verify trending pets
SELECT 
  name, 
  breed,
  view_count,
  like_count,
  match_count,
  trending_score,
  created_at
FROM trending_pets
ORDER BY trending_score DESC
LIMIT 10;
