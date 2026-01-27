import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import { upsertProfile } from './useProfile';

export type User = {
  id: string;
  email?: string | null;
  user_metadata?: Record<string, unknown>;
};

export function useAuth() {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let mounted = true;

    async function getSessionUser() {
      const { data } = await supabase.auth.getSession();
      if (!mounted) return;
      const sessionUser = data?.session?.user;
      setUser(
        sessionUser
          ? { id: sessionUser.id, email: sessionUser.email, user_metadata: sessionUser.user_metadata }
          : null
      );
      setLoading(false);
    }

    getSessionUser();

    const { data: listener } = supabase.auth.onAuthStateChange(async (_event, session) => {
      const sUser = session?.user;
      const userObj = sUser ? { id: sUser.id, email: sUser.email, user_metadata: sUser.user_metadata } : null;
      setUser(userObj);
      setLoading(false);
      if (userObj) {
        // derive display name and avatar from user_metadata if available
        const metadata: any = userObj.user_metadata ?? {};
        const display_name = metadata.full_name || metadata.name || metadata.preferred_username || null;
        const avatar = metadata.avatar_url || metadata.picture || metadata.avatar || null;
        const payload = { ...userObj, display_name, avatar };
        try {
          await upsertProfile(payload as any);
        } catch (err) {
          // eslint-disable-next-line no-console
          console.warn('Error upserting profile', err);
        }
      }
    });

    return () => {
      mounted = false;
      listener?.subscription.unsubscribe();
    };
  }, []);

  async function signUpWithEmail(email: string, password: string) {
    const res = await supabase.auth.signUp({ email, password });
    return res;
  }

  async function signInWithEmail(email: string, password: string) {
    const res = await supabase.auth.signInWithPassword({ email, password });
    return res;
  }

  async function signOut() {
    await supabase.auth.signOut();
    setUser(null);
  }

  async function signInWithProvider(provider: 'google' | 'facebook') {
    return supabase.auth.signInWithOAuth({ provider });
  }

  return {
    user,
    loading,
    signUpWithEmail,
    signInWithEmail,
    signOut,
    signInWithProvider,
  };
}
