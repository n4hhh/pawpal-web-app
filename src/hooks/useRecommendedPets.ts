import { useQuery } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import type { Pet } from '@/data/mockData';
import { getRecommendedPets, type MatchingFilters } from '@/lib/matching';

export interface RecommendedPet extends Pet {
  compatibilityScore: number;
}

interface UseRecommendedPetsOptions {
  limit?: number;
  filters?: MatchingFilters;
  excludeIds?: string[];
  enabled?: boolean;
}

/**
 * Hook to fetch recommended pets based on matching algorithm
 * Returns pets sorted by compatibility score
 */
export function useRecommendedPets(options: UseRecommendedPetsOptions = {}) {
  const { limit = 5, filters, excludeIds = [], enabled = true } = options;

  return useQuery<RecommendedPet[], Error>({
    queryKey: ['recommended-pets', limit, filters, excludeIds],
    queryFn: async () => {
      // Fetch pets from database (is_active column doesn't exist)
      let query = supabase
        .from('pets')
        .select('*');

      // Exclude specific pet IDs (e.g., already matched)
      if (excludeIds.length > 0) {
        query = query.not('id', 'in', `(${excludeIds.join(',')})`);
      }

      // Apply distance filter if specified
      if (filters?.maxDistance) {
        // Note: This is a simple client-side filter
        // For production, implement PostGIS for geospatial queries
        query = query.limit(50);
      }

      const { data, error } = await query;

      if (error) throw error;

      if (!data || data.length === 0) {
        return [];
      }

      // Map database records to Pet format
      const pets = data.map((pet: any) => ({
        id: pet.id,
        name: pet.name,
        age: pet.age,
        breed: pet.breed,
        location: pet.location,
        image: pet.avatar || pet.images?.[0] || '',
        images: pet.images || [],
        bio: pet.bio,
        owner: pet.owner_id,
        gender: pet.gender,
        size: pet.size,
      })) as Pet[];

      // Calculate compatibility scores and sort
      const recommended = getRecommendedPets(pets, filters, limit);

      return recommended as RecommendedPet[];
    },
    staleTime: 1000 * 60 * 10, // 10 minutes
    enabled,
  });
}

/**
 * Hook to get nearby pets (sorted by distance)
 */
export function useNearbyPets(options: { limit?: number; maxDistance?: number } = {}) {
  const { limit = 10, maxDistance = 10 } = options;

  return useRecommendedPets({
    limit,
    filters: { maxDistance },
  });
}

/**
 * Hook to get pets filtered by species
 */
export function usePetsBySpecies(
  species: string[],
  options: { limit?: number } = {}
) {
  const { limit = 10 } = options;

  return useRecommendedPets({
    limit,
    filters: { preferredSpecies: species },
  });
}
