import { useQuery } from '@tanstack/react-query';
import { supabase, hasSupabaseEnv } from '@/lib/supabase';
import { mockPets } from '@/data/mockData';
import type { Pet } from '@/data/mockData';

export function usePets() {
  return useQuery<Pet[], Error>({
    queryKey: ['pets'],
    queryFn: async () => {
      if (!hasSupabaseEnv) return mockPets as Pet[];

      const timeoutMs = 8000;
      const timeoutPromise = new Promise<null>((resolve) =>
        setTimeout(() => resolve(null), timeoutMs)
      );

      const requestPromise = (async () => {
        const { data, error } = await supabase.from('pets').select('*');
        if (error) throw error;
        return (data ?? []) as Pet[];
      })();

      const data = await Promise.race([requestPromise, timeoutPromise]);
      if (!data) return mockPets as Pet[];
      return data as Pet[];
    },
    staleTime: 1000 * 60, // 1 minute
  });
}
