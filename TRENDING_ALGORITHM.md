# Trending Pets Algorithm

## Overview

The trending pets feature identifies and displays the most popular and engaging pets on the platform. The algorithm combines engagement metrics with time-based factors to surface pets that are currently generating the most interest.

## Algorithm Components

### 1. Engagement Metrics

The algorithm tracks three key metrics:

- **View Count** (weight: 1x): Number of times a pet profile has been viewed
- **Like Count** (weight: 3x): Number of right swipes/likes the pet has received
- **Match Count** (weight: 5x): Number of successful matches the pet has made

### 2. Base Score Calculation

```
Base Score = (views × 1) + (likes × 3) + (matches × 5)
```

The weights reflect the relative value of each engagement type:
- Views are basic engagement
- Likes show genuine interest
- Matches represent the strongest signal

### 3. Time Decay Factor

Content freshness is crucial for trending. The algorithm applies time-based multipliers:

| Content Age | Time Factor | Description |
|------------|-------------|-------------|
| < 24 hours | 2.0x | Recent content boost |
| 24h - 7 days | 1.0 - 0.5x | Gradual linear decay |
| > 7 days | 0.5x × exp(-age/1680) | Exponential decay |

### 4. Final Trending Score

```
Trending Score = Base Score × Time Factor
```

## Implementation

### Database Schema

The `pets` table includes these columns:
- `view_count`: INTEGER - Total profile views
- `like_count`: INTEGER - Total likes received
- `match_count`: INTEGER - Total matches made
- `trending_score`: NUMERIC - Calculated trending score
- `last_trending_update`: TIMESTAMPTZ - Last score update

### Automatic Updates

- **Trigger-based**: Trending scores are automatically recalculated when engagement metrics change
- **View**: The `trending_pets` view provides pre-filtered top 20 trending pets
- **Functions**: RPC functions handle atomic metric increments

### Client-side Fallback

If the database view is unavailable, the React hook calculates scores client-side using the same algorithm.

## API Usage

### Fetching Trending Pets

```typescript
import { useTrendingPets } from '@/hooks/useTrendingPets';

function MyComponent() {
  const { data: trendingPets, isLoading } = useTrendingPets({ limit: 10 });
  // ...
}
```

### Tracking Engagement

```typescript
import { useTrackPetView, useTrackPetLike, useTrackPetMatch } from '@/hooks/useTrendingPets';

function PetProfile({ petId }) {
  const { trackView } = useTrackPetView();
  const { trackLike } = useTrackPetLike();
  const { trackMatch } = useTrackPetMatch();

  // Track when pet is viewed
  useEffect(() => {
    trackView(petId);
  }, [petId]);

  // Track when pet is liked
  const handleLike = () => {
    trackLike(petId);
  };

  // Track when match occurs
  const handleMatch = () => {
    trackMatch(petId);
  };
}
```

## Trending Badges

The algorithm provides visual badges based on score thresholds:

- 🔥 **Hot** (score ≥ 100): Extremely trending
- ⭐ **Trending** (score ≥ 50): Highly popular
- 📈 **Rising** (score ≥ 20): Growing interest

## Database Migrations

Apply these migrations to enable trending functionality:

1. `20260130000005_add_trending_columns.sql` - Adds trending columns and calculation functions
2. `20260130000006_add_increment_functions.sql` - Adds RPC functions for metric tracking

## Performance Considerations

- **Indexes**: Created on `trending_score DESC` and `(created_at DESC, trending_score DESC)`
- **View Materialization**: The `trending_pets` view can be materialized for better performance
- **Batch Updates**: Use the `update_all_trending_scores()` function for bulk recalculation
- **Caching**: React Query caches results for 5 minutes by default

## Future Enhancements

Potential improvements to the algorithm:

1. **Location-based trending**: Weight pets closer to the user
2. **Personalization**: Adjust scores based on user preferences
3. **Category trending**: Separate trending by species/breed
4. **Velocity tracking**: Detect rapidly rising pets
5. **Time windows**: Offer "trending today" vs "trending this week"
6. **A/B testing**: Experiment with different weight values

## Monitoring

Key metrics to monitor:

- Average trending score distribution
- Score decay rate over time
- Engagement metric ratios
- Query performance on trending views
- Cache hit rates

## Troubleshooting

### Scores not updating
- Verify triggers are enabled
- Check RPC function permissions
- Ensure engagement tracking is called

### Poor trending results
- Adjust weight multipliers
- Modify time decay curve
- Verify sufficient data volume

### Performance issues
- Check index usage
- Consider materialized views
- Review query execution plans
