import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';

export interface Story {
  id: string;
  user_id: string;
  media_url: string;
  media_type: 'image' | 'video';
  caption?: string;
  created_at: string;
  expires_at: string;
  view_count: number;
  username?: string;
  avatar?: string;
  hasViewed?: boolean;
}

export interface StoryGroup {
  user_id: string;
  username: string;
  avatar: string;
  stories: Story[];
  hasViewed: boolean;
}

export function useStories() {
  return useQuery<StoryGroup[], Error>({
    queryKey: ['stories'],
    queryFn: async () => {
      const { data: { user } } = await supabase.auth.getUser();
      
      // Get all non-expired stories
      const { data: stories, error } = await supabase
        .from('stories')
        .select('*')
        .gt('expires_at', new Date().toISOString())
        .order('created_at', { ascending: false });

      if (error) throw error;

      // Get user profiles
      const userIds = [...new Set(stories?.map(s => s.user_id) || [])];
      const { data: profiles } = await supabase
        .from('profiles')
        .select('id, full_name, avatar_url')
        .in('id', userIds);

      // Get viewed stories for current user
      const { data: views } = user ? await supabase
        .from('story_views')
        .select('story_id')
        .eq('viewer_id', user.id) : { data: [] };

      const viewedStoryIds = new Set(views?.map(v => v.story_id) || []);

      // Group stories by user
      const grouped = (stories || []).reduce((acc, story) => {
        const profile = profiles?.find(p => p.id === story.user_id);
        const storyWithProfile = {
          ...story,
          username: profile?.full_name || 'Anonymous User',
          avatar: profile?.avatar_url || '/placeholder-avatar.png',
          hasViewed: viewedStoryIds.has(story.id),
        };

        const existing = acc.find(g => g.user_id === story.user_id);
        if (existing) {
          existing.stories.push(storyWithProfile);
          if (!storyWithProfile.hasViewed) {
            existing.hasViewed = false;
          }
        } else {
          acc.push({
            user_id: story.user_id,
            username: storyWithProfile.username,
            avatar: storyWithProfile.avatar,
            stories: [storyWithProfile],
            hasViewed: storyWithProfile.hasViewed,
          });
        }
        return acc;
      }, [] as StoryGroup[]);

      return grouped;
    },
    staleTime: 1000 * 60, // 1 minute
  });
}

export function useCreateStory() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ media_url, media_type, caption }: { 
      media_url: string; 
      media_type: 'image' | 'video';
      caption?: string;
    }) => {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) throw new Error('Not authenticated');

      const { data, error } = await supabase
        .from('stories')
        .insert({
          user_id: user.id,
          media_url,
          media_type,
          caption,
        })
        .select()
        .single();

      if (error) throw error;
      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['stories'] });
    },
  });
}

export function useMarkStoryViewed() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (storyId: string) => {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return;

      const { error } = await supabase
        .from('story_views')
        .insert({
          story_id: storyId,
          viewer_id: user.id,
        });

      if (error && !error.message.includes('duplicate')) {
        throw error;
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['stories'] });
    },
  });
}
