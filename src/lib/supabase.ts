import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL as string;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY as string;

if (!supabaseUrl || !supabaseAnonKey) {
  // In dev, it's fine to rely on mock data; warn to configure env when connecting for real
  // eslint-disable-next-line no-console
  console.warn('VITE_SUPABASE_URL or VITE_SUPABASE_ANON_KEY is not set. Supabase client will still be created but requests will fail.');
}

export const supabase = createClient(supabaseUrl ?? '', supabaseAnonKey ?? '');

export default supabase;
