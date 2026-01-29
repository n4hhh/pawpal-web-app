import { useQuery } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';

export interface ShopItem {
  id: string;
  title: string;
  description?: string;
  price: number;
  images?: string[];
  stock?: number;
}

export function useShop() {
  return useQuery<ShopItem[], Error>({
    queryKey: ['shop_items'],
    queryFn: async ({ signal }) => {
      try {
        // perform the supabase request with async/await
        const req = supabase.from('shop_items').select('*');

        // If react-query provides a signal, attach a small abort guard
        const abortPromise = new Promise<null>((resolve) => {
          if (signal) {
            if (signal.aborted) return resolve(null);
            const onAbort = () => resolve(null);
            signal.addEventListener('abort', onAbort, { once: true });
          }
        });

        // Run the request and race with abort signal
        const resPromise = (async () => {
          const res: any = await req;
          const { data, error } = res;
          if (error) throw error;
          return data as ShopItem[] | null;
        })();

        const data = await Promise.race([resPromise, abortPromise]);
        if (!data) return [];
        return data.map((d) => ({ ...d, price: Number(d.price) }));
      } catch (err: any) {
        // eslint-disable-next-line no-console
        console.error('useShop error', err);
        return [];
      }
    },
    staleTime: 1000 * 60,
  });
}

export default useShop;
