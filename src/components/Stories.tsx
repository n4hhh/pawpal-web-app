import { useState } from 'react';
import { Plus } from 'lucide-react';
import { Avatar, AvatarImage, AvatarFallback } from '@/components/ui/avatar';
import { useStories } from '@/hooks/useStories';
import { StoryViewer } from './StoryViewer';
import { CreateStory } from './CreateStory';

export function Stories() {
  const { data: storyGroups, isLoading } = useStories();
  const [selectedGroupIndex, setSelectedGroupIndex] = useState<number | null>(null);
  const [showCreateStory, setShowCreateStory] = useState(false);

  if (isLoading) {
    return (
      <div className="flex gap-4 overflow-x-auto pb-4 px-4 scrollbar-hide">
        {[...Array(5)].map((_, i) => (
          <div key={i} className="flex flex-col items-center gap-2 flex-shrink-0">
            <div className="w-16 h-16 rounded-full bg-muted animate-pulse" />
            <div className="w-12 h-3 bg-muted rounded animate-pulse" />
          </div>
        ))}
      </div>
    );
  }

  const formatTimeAgo = (dateString: string) => {
    const date = new Date(dateString);
    const now = new Date();
    const hours = Math.floor((now.getTime() - date.getTime()) / (1000 * 60 * 60));
    
    if (hours < 1) return 'now';
    if (hours < 24) return `${hours}h`;
    return `${Math.floor(hours / 24)}d`;
  };

  return (
    <>
      <div className="flex gap-4 overflow-x-auto py-4 px-4 scrollbar-hide">
        {/* Add Story Button */}
        <button
          onClick={() => setShowCreateStory(true)}
          className="flex flex-col items-center gap-2 flex-shrink-0"
        >
          <div className="relative">
            <Avatar className="w-16 h-16 ring-2 ring-background">
              <AvatarImage src="/placeholder-avatar.png" />
              <AvatarFallback>You</AvatarFallback>
            </Avatar>
            <div className="absolute bottom-0 right-0 w-5 h-5 bg-primary rounded-full flex items-center justify-center ring-2 ring-background">
              <Plus className="w-3 h-3 text-primary-foreground" />
            </div>
          </div>
          <span className="text-xs text-muted-foreground">Your Story</span>
        </button>

        {/* Story Groups */}
        {storyGroups?.map((group, index) => (
          <button
            key={group.user_id}
            onClick={() => setSelectedGroupIndex(index)}
            className="flex flex-col items-center gap-2 flex-shrink-0"
          >
            <div className="relative">
              <Avatar 
                className={`w-16 h-16 ring-2 ${
                  group.hasViewed 
                    ? 'ring-muted' 
                    : 'ring-primary ring-offset-2 ring-offset-background'
                }`}
              >
                <AvatarImage src={group.avatar} />
                <AvatarFallback>{group.username[0]?.toUpperCase()}</AvatarFallback>
              </Avatar>
            </div>
            <div className="flex flex-col items-center">
              <span className="text-xs truncate max-w-[60px]">{group.username}</span>
              <span className="text-[10px] text-muted-foreground">
                {formatTimeAgo(group.stories[0].created_at)}
              </span>
            </div>
          </button>
        ))}
      </div>

      {selectedGroupIndex !== null && storyGroups && (
        <StoryViewer
          storyGroups={storyGroups}
          initialGroupIndex={selectedGroupIndex}
          onClose={() => setSelectedGroupIndex(null)}
        />
      )}

      <CreateStory
        open={showCreateStory}
        onOpenChange={setShowCreateStory}
      />
    </>
  );
}
