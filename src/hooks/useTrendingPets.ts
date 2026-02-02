import { useQuery } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import type { Pet } from '@/data/mockData';
import { calculateTrendingScore, getTopTrending } from '@/lib/trending';

export interface TrendingPet extends Pet {
  viewCount: number;
  likeCount: number;
  matchCount: number;
  trendingScore: number;
  lastTrendingUpdate?: string;
}

interface UseTrendingPetsOptions {
  limit?: number;
  enabled?: boolean;
}

/**
 * Hook to fetch and manage trending pets
 * Fetches pets from the database with their engagement metrics
 * and calculates trending scores client-side if needed
 */
export function useTrendingPets(options: UseTrendingPetsOptions = {}) {
  const { limit = 10, enabled = true } = options;

  return useQuery<TrendingPet[], Error>({
    queryKey: ['trending-pets', limit],
    queryFn: async () => {
      // Fetch regular pets (trending_pets view doesn't exist in this database)
      const { data, error } = await supabase
        .from('pets')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(limit * 5); // Fetch more to calculate trending from

      if (error) throw error;

      if (!data || data.length === 0) {
        return [];
      }

      // Map and calculate trending scores
      const petsWithScores = data.map((pet: any) => {
        const viewCount = pet.view_count || 0;
        const likeCount = pet.like_count || 0;
        const matchCount = pet.match_count || 0;
        const createdAt = new Date(pet.created_at);

        const trendingScore = calculateTrendingScore({
          viewCount,
          likeCount,
          matchCount,
          createdAt,
        });

        return {
          id: pet.id,
          name: pet.name,
          age: pet.age,
          breed: pet.breed,
          location: pet.location,
          image: pet.avatar || pet.images?.[0] || '',
          images: pet.images || [],
          bio: pet.bio,
          owner: pet.owner_id,
          viewCount,
          likeCount,
          matchCount,
          trendingScore,
          gender: pet.gender,
          size: pet.size,
        } as TrendingPet;
      });

      // Return top trending pets
      return getTopTrending(petsWithScores, limit);
    },
    staleTime: 1000 * 60 * 5, // 5 minutes
    enabled,
  });
}

/**
 * Hook to track when a pet is viewed
 * Increments the view count for engagement tracking
 */
export function useTrackPetView() {
  const trackView = async (petId: string) => {
    try {
      // Increment view count
      const { error } = await supabase.rpc('increment_pet_view', {
        pet_id: petId,
      });

      if (error) {
        // Fallback: manual increment if RPC doesn't exist
        const { data: pet } = await supabase
          .from('pets')
          .select('view_count')
          .eq('id', petId)
          .single();

        if (pet) {
          await supabase
            .from('pets')
            .update({ view_count: (pet.view_count || 0) + 1 })
            .eq('id', petId);
        }
      }
    } catch (error) {
      console.error('Error tracking pet view:', error);
    }
  };

  return { trackView };
}

/**
 * Hook to track when a pet is liked
 * Increments the like count for engagement tracking
 */
export function useTrackPetLike() {
  const trackLike = async (petId: string) => {
    try {
      const { error } = await supabase.rpc('increment_pet_like', {
        pet_id: petId,
      });

      if (error) {
        // Fallback: manual increment
        const { data: pet } = await supabase
          .from('pets')
          .select('like_count')
          .eq('id', petId)
          .single();

        if (pet) {
          await supabase
            .from('pets')
            .update({ like_count: (pet.like_count || 0) + 1 })
            .eq('id', petId);
        }
      }
    } catch (error) {
      console.error('Error tracking pet like:', error);
    }
  };

  return { trackLike };
}

/**
 * Hook to track when a pet gets matched
 * Increments the match count for engagement tracking
 */
export function useTrackPetMatch() {
  const trackMatch = async (petId: string) => {
    try {
      const { error } = await supabase.rpc('increment_pet_match', {
        pet_id: petId,
      });

      if (error) {
        // Fallback: manual increment
        const { data: pet } = await supabase
          .from('pets')
          .select('match_count')
          .eq('id', petId)
          .single();

        if (pet) {
          await supabase
            .from('pets')
            .update({ match_count: (pet.match_count || 0) + 1 })
            .eq('id', petId);
        }
      }
    } catch (error) {
      console.error('Error tracking pet match:', error);
    }
  };

  return { trackMatch };
}
