import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL as string | undefined;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY as string | undefined;

// Provide placeholder values if environment variables are not set
// This allows the app to run with mock data during development
const defaultUrl = 'https://placeholder.supabase.co';
const defaultKey = 'placeholder-anon-key';

export const hasSupabaseEnv = Boolean(supabaseUrl && supabaseAnonKey);

if (!hasSupabaseEnv) {
  // eslint-disable-next-line no-console
  console.warn('VITE_SUPABASE_URL or VITE_SUPABASE_ANON_KEY is not set. Using mock data. To connect to a real database, create a .env file with your Supabase credentials.');
}

export const supabase = createClient(
  supabaseUrl || defaultUrl,
  supabaseAnonKey || defaultKey
);

export default supabase;
