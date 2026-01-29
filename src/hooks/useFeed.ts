import { useQuery } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { feedPosts as mockFeed } from '@/data/mockData';

type FeedPost = (typeof mockFeed)[number];

interface FeedPostDB {
  id: string;
  pet_name: string;
  owner_name: string;
  avatar: string;
  image: string;
  caption: string;
  likes: number;
  comments: number;
  time_ago: string;
  created_at: string;
}

// Format timestamp to relative time
function formatTimeAgo(dateString: string): string {
  const date = new Date(dateString);
  const now = new Date();
  const seconds = Math.floor((now.getTime() - date.getTime()) / 1000);

  if (seconds < 5) return "Just now";
  if (seconds < 60) return `${seconds}s`;
  if (seconds < 3600) return `${Math.floor(seconds / 60)}m`;
  if (seconds < 86400) return `${Math.floor(seconds / 3600)}h`;
  if (seconds < 604800) return `${Math.floor(seconds / 86400)}d`;
  if (seconds < 2592000) return `${Math.floor(seconds / 604800)}w`;
  if (seconds < 31536000) return `${Math.floor(seconds / 2592000)}mo`;
  return `${Math.floor(seconds / 31536000)}y`;
}

// Transform DB snake_case to component camelCase
function transformFeedPost(dbPost: FeedPostDB): FeedPost & { id: string } {
  return {
    id: dbPost.id,
    petName: dbPost.pet_name,
    ownerName: dbPost.owner_name,
    avatar: dbPost.avatar,
    image: dbPost.image,
    caption: dbPost.caption,
    likes: dbPost.likes,
    comments: dbPost.comments,
    timeAgo: formatTimeAgo(dbPost.created_at),
  };
}

export function useFeed() {
  return useQuery<FeedPost[], Error>({
    queryKey: ['feed'],
    queryFn: async () => {
      try {
        const { data, error } = await supabase
          .from('feed_posts')
          .select('*')
          .order('created_at', { ascending: false });
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
