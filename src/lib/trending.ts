/**
 * Trending Algorithm Utilities
 * 
 * Calculates trending scores for pets based on engagement metrics and time decay.
 * Algorithm factors:
 * - Engagement weights: views (1x), likes (3x), matches (5x)
 * - Time decay: older content gets reduced score
 * - Recency boost: content from last 24 hours gets 2x boost
 */

export interface TrendingMetrics {
  viewCount: number;
  likeCount: number;
  matchCount: number;
  createdAt: Date;
}

export interface TrendingPet {
  id: string;
  trendingScore: number;
  metrics: TrendingMetrics;
}

/**
 * Calculate trending score for a pet
 * @param metrics - Engagement metrics for the pet
 * @returns Calculated trending score
 */
export function calculateTrendingScore(metrics: TrendingMetrics): number {
  const { viewCount, likeCount, matchCount, createdAt } = metrics;
  
  // Calculate base engagement score with weighted factors
  const baseScore = (viewCount * 1.0) + (likeCount * 3.0) + (matchCount * 5.0);
  
  // Calculate age in hours
  const ageInHours = (Date.now() - createdAt.getTime()) / (1000 * 60 * 60);
  
  // Apply time decay factor
  let timeFactor: number;
  
  if (ageInHours < 24) {
    // Recent content (< 24 hours) gets a 2x boost
    timeFactor = 2.0;
  } else if (ageInHours < 168) {
    // Content < 7 days: gradual linear decay from 1.0 to 0.5
    timeFactor = 1.0 - ((ageInHours - 24) / 288);
  } else {
    // Content > 7 days: exponential decay for older content
    timeFactor = 0.5 * Math.exp(-ageInHours / 1680);
  }
  
  return baseScore * timeFactor;
}

/**
 * Sort pets by trending score in descending order
 * @param pets - Array of pets with trending data
 * @returns Sorted array of pets by trending score
 */
export function sortByTrending<T extends { trendingScore: number }>(pets: T[]): T[] {
  return [...pets].sort((a, b) => b.trendingScore - a.trendingScore);
}

/**
 * Get top N trending pets
 * @param pets - Array of pets with trending data
 * @param limit - Number of top trending pets to return (default: 10)
 * @returns Array of top trending pets
 */
export function getTopTrending<T extends { trendingScore: number }>(
  pets: T[],
  limit: number = 10
): T[] {
  return sortByTrending(pets).slice(0, limit);
}

/**
 * Check if a pet is currently trending (score above threshold)
 * @param trendingScore - The pet's trending score
 * @param threshold - Minimum score to be considered trending (default: 10)
 * @returns Boolean indicating if pet is trending
 */
export function isTrending(trendingScore: number, threshold: number = 10): boolean {
  return trendingScore >= threshold;
}

/**
 * Calculate trending velocity (rate of score change)
 * Used for detecting rapidly rising pets
 * @param currentScore - Current trending score
 * @param previousScore - Previous trending score
 * @param timeElapsed - Time elapsed in hours
 * @returns Velocity (score change per hour)
 */
export function calculateTrendingVelocity(
  currentScore: number,
  previousScore: number,
  timeElapsed: number
): number {
  if (timeElapsed === 0) return 0;
  return (currentScore - previousScore) / timeElapsed;
}

/**
 * Get trending badge label based on score
 * @param trendingScore - The pet's trending score
 * @returns Badge label string
 */
export function getTrendingBadge(trendingScore: number): string | null {
  if (trendingScore >= 100) return '🔥 Hot';
  if (trendingScore >= 50) return '⭐ Trending';
  if (trendingScore >= 20) return '📈 Rising';
  return null;
}
