/**
 * Pet Matching & Recommendation Algorithm
 * 
 * Suggests compatible pets based on multiple factors:
 * - Location proximity
 * - Size compatibility
 * - Activity level
 * - Age compatibility
 * - User preferences
 */

export interface MatchingPet {
  id: string;
  name: string;
  breed: string;
  location: string;
  size?: string;
  age?: string;
  gender?: string;
  image: string;
}

export interface MatchingFilters {
  userLocation?: string;
  preferredSpecies?: string[];
  preferredSize?: string[];
  preferredAge?: string[];
  maxDistance?: number;
}

/**
 * Extract distance in miles from location string
 * @param location - Location string like "2 miles away"
 * @returns Distance in miles or Infinity if not found
 */
function extractDistance(location: string): number {
  const match = location.match(/(\d+)\s*miles?\s*away/i);
  return match && match[1] ? parseInt(match[1], 10) : Infinity;
}

/**
 * Calculate compatibility score between two pets
 * @param pet - Pet to score
 * @param filters - User preferences and filters
 * @returns Compatibility score (0-100)
 */
export function calculateCompatibilityScore(
  pet: MatchingPet,
  filters?: MatchingFilters
): number {
  let score = 50; // Base score

  if (!filters) return score;

  // Distance scoring (closer is better)
  const distance = extractDistance(pet.location);
  if (distance !== Infinity) {
    const maxDistance = filters.maxDistance || 25;
    if (distance <= maxDistance) {
      // Score: 0-30 points based on proximity
      score += Math.max(0, 30 - (distance / maxDistance) * 30);
    } else {
      score -= 20; // Penalty for being too far
    }
  }

  // Size compatibility (opposite sizes can still be friends!)
  if (filters.preferredSize && pet.size) {
    const sizeValue: { [key: string]: number } = {
      Small: 1,
      Medium: 2,
      Large: 3,
    };

    const petSize = sizeValue[pet.size] || 2;
    const preferredSizes = filters.preferredSize.map((s) => sizeValue[s] || 2);
    
    const sizeDiff = Math.min(...preferredSizes.map((s) => Math.abs(s - petSize)));
    score += Math.max(0, 15 - sizeDiff * 5);
  }

  // Age compatibility
  if (filters.preferredAge && pet.age) {
    if (filters.preferredAge.some((a) => pet.age?.includes(a))) {
      score += 10;
    }
  }

  // Species preference
  if (filters.preferredSpecies && pet.breed) {
    const matchesSpecies = filters.preferredSpecies.some((species) =>
      pet.breed.toLowerCase().includes(species.toLowerCase())
    );
    if (matchesSpecies) {
      score += 15;
    }
  }

  return Math.min(100, Math.max(0, score));
}

/**
 * Sort pets by compatibility score
 * @param pets - Array of pets to sort
 * @param filters - User preferences
 * @returns Sorted array with compatibility scores
 */
export function sortByCompatibility<T extends MatchingPet>(
  pets: T[],
  filters?: MatchingFilters
): Array<T & { compatibilityScore: number }> {
  const petsWithScores = pets.map((pet) => ({
    ...pet,
    compatibilityScore: calculateCompatibilityScore(pet, filters),
  }));

  return petsWithScores.sort((a, b) => b.compatibilityScore - a.compatibilityScore);
}

/**
 * Get top recommended pets
 * @param pets - Array of pets to filter
 * @param filters - User preferences
 * @param limit - Number of recommendations to return
 * @returns Array of top recommended pets
 */
export function getRecommendedPets<T extends MatchingPet>(
  pets: T[],
  filters?: MatchingFilters,
  limit: number = 5
): Array<T & { compatibilityScore: number }> {
  return sortByCompatibility(pets, filters).slice(0, limit);
}

/**
 * Filter pets by criteria
 * @param pets - Array of pets to filter
 * @param filters - Filtering criteria
 * @returns Filtered array of pets
 */
export function filterPets<T extends MatchingPet>(
  pets: T[],
  filters: MatchingFilters
): T[] {
  return pets.filter((pet) => {
    // Distance filter
    if (filters.maxDistance) {
      const distance = extractDistance(pet.location);
      if (distance > filters.maxDistance) return false;
    }

    // Species filter
    if (filters.preferredSpecies && filters.preferredSpecies.length > 0) {
      const matchesSpecies = filters.preferredSpecies.some((species) =>
        pet.breed.toLowerCase().includes(species.toLowerCase())
      );
      if (!matchesSpecies) return false;
    }

    // Size filter
    if (filters.preferredSize && filters.preferredSize.length > 0 && pet.size) {
      if (!filters.preferredSize.includes(pet.size)) return false;
    }

    // Age filter
    if (filters.preferredAge && filters.preferredAge.length > 0 && pet.age) {
      const matchesAge = filters.preferredAge.some((age) =>
        pet.age?.toLowerCase().includes(age.toLowerCase())
      );
      if (!matchesAge) return false;
    }

    return true;
  });
}

/**
 * Get compatibility badge based on score
 * @param score - Compatibility score
 * @returns Badge label or null
 */
export function getCompatibilityBadge(score: number): string | null {
  if (score >= 90) return '💯 Perfect Match';
  if (score >= 75) return '⭐ Great Match';
  if (score >= 60) return '✨ Good Match';
  return null;
}

/**
 * Shuffle array (Fisher-Yates algorithm)
 * Useful for randomizing recommendations
 */
export function shufflePets<T>(pets: T[]): T[] {
  const shuffled = [...pets];
  for (let i = shuffled.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    const temp = shuffled[i];
    const swap = shuffled[j];
    if (temp !== undefined && swap !== undefined) {
      shuffled[i] = swap;
      shuffled[j] = temp;
    }
  }
  return shuffled;
}
