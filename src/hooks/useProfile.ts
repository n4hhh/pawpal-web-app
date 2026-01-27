import { useQuery } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';

export function useProfile(userId?: string) {
  return useQuery(['profile', userId], async () => {
    if (!userId) return null;
    const { data, error } = await supabase.from('users').select('*').eq('id', userId).single();
    if (error) throw error;
    return data;
  }, { enabled: !!userId });
}

export async function upsertProfile(user: { id: string; email?: string | null; user_metadata?: any; display_name?: string | null; avatar?: string | null }) {
  if (!user?.id) return null;
  const payload: any = { id: user.id, email: user.email };
  if (user.user_metadata) payload.user_metadata = user.user_metadata;
  if (user.display_name) payload.display_name = user.display_name;
  if (user.avatar) payload.avatar = user.avatar;
  const { data, error } = await supabase.from('users').upsert(payload);
  if (error) {
    // eslint-disable-next-line no-console
    console.warn('upsertProfile error', error);
  }
  return data;
}
