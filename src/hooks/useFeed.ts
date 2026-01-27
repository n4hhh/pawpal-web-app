import { useQuery } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { feedPosts as mockFeed } from '@/data/mockData';

type FeedPost = (typeof mockFeed)[number];

interface FeedPostDB {
  pet_name: string;
  owner_name: string;
  avatar: string;
  image: string;
  caption: string;
  likes: number;
  comments: number;
  time_ago: string;
}

// Transform DB snake_case to component camelCase
function transformFeedPost(dbPost: FeedPostDB): FeedPost {
  return {
    petName: dbPost.pet_name,
    ownerName: dbPost.owner_name,
    avatar: dbPost.avatar,
    image: dbPost.image,
    caption: dbPost.caption,
    likes: dbPost.likes,
    comments: dbPost.comments,
    timeAgo: dbPost.time_ago,
  };
}

export function useFeed() {
  return useQuery<FeedPost[], Error>({
    queryKey: ['feed'],
    queryFn: async () => {
      try {
        const { data, error } = await supabase.from('feed_posts').select('*');
        if (error) {
          // eslint-disable-next-line no-console
          console.warn('Error fetching feed:', error);
          throw error;
        }
        if (!data || data.length === 0) {
          // eslint-disable-next-line no-console
          console.warn('No feed data returned from Supabase');
          return mockFeed;
        }
        return data.map(transformFeedPost);
      } catch (err) {
        // eslint-disable-next-line no-console
        console.error('useFeed error:', err);
        // Fallback to mock data on error
        return mockFeed;
      }
    },
    staleTime: 1000 * 30,
  });
}
