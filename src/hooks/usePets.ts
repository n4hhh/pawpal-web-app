import { useQuery } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import type { Pet } from '@/data/mockData';

export function usePets() {
  return useQuery<Pet[], Error>({
    queryKey: ['pets'],
    queryFn: async () => {
      const { data, error } = await supabase.from('pets').select('*');
      if (error) throw error;
      return (data ?? []) as Pet[];
    },
    staleTime: 1000 * 60, // 1 minute
  });
}
