import { supabase } from './supabase';
import { User } from '@supabase/supabase-js';

export interface AuthUser {
  id: string;
  email: string;
  user_metadata?: {
    full_name?: string;
    avatar_url?: string;
  };
}

// Sign up with email and password
export const signUpWithEmail = async (email: string, password: string, userData: {
  fullName: string;
  phoneNumber?: string;
  age?: number;
  bio?: string;
  favoriteBreed?: string;
}) => {
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
  });

  if (error) throw error;

  // Save user profile to profiles table
  if (data.user) {
    const { error: profileError } = await supabase
      .from('profiles')
      .upsert({
        id: data.user.id,
        email,
        full_name: userData.fullName,
        phone_number: userData.phoneNumber,
        age: userData.age,
        bio: userData.bio,
        favorite_breed: userData.favoriteBreed,
      }, {
        onConflict: 'id'
      });

    if (profileError) throw profileError;
  }

  return data;
};

// Sign in with email and password
export const signInWithEmail = async (email: string, password: string) => {
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  });

  if (error) throw error;
  return data;
};

// Sign in with Google
export const signInWithGoogle = async () => {
  const { data, error } = await supabase.auth.signInWithOAuth({
    provider: 'google',
    options: {
      redirectTo: `${window.location.origin}/`,
    },
  });

  if (error) throw error;
  return data;
};

// Create or update profile for OAuth users
export const createOrUpdateProfile = async (user: User) => {
  if (!user) return;

  const { error } = await supabase
    .from('profiles')
    .upsert({
      id: user.id,
      email: user.email,
      full_name: user.user_metadata?.full_name || user.email?.split('@')[0],
      avatar_url: user.user_metadata?.avatar_url,
    }, {
      onConflict: 'id'
    });

  if (error) throw error;
};

// Sign out
export const signOut = async () => {
  const { error } = await supabase.auth.signOut();
  if (error) throw error;
};

// Get current session
export const getSession = async () => {
  const { data, error } = await supabase.auth.getSession();
  if (error) throw error;
  return data.session;
};

// Get current user
export const getCurrentUser = async () => {
  const { data, error } = await supabase.auth.getUser();
  if (error) throw error;
  return data.user;
};
