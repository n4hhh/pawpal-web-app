import { Heart, MessageCircle, Share2, MoreHorizontal } from "lucide-react";
import { useState } from "react";
import { Avatar, AvatarImage, AvatarFallback } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { supabase } from "@/lib/supabase";
import { useQueryClient } from "@tanstack/react-query";
import { CommentsDialog } from "./CommentsDialog";

interface FeedPostProps {
  id?: string;
  petName?: string | null;
  ownerName?: string | null;
  avatar?: string | null;
  image?: string | string[] | null;
  caption?: string | null;
  likes?: number | null;
  comments?: number | null;
  timeAgo?: string | null;
}

export function FeedPost({
  id,
  petName = 'Pet',
  ownerName = 'owner',
  avatar = '',
  image = '',
  caption = '',
  likes = 0,
  comments = 0,
  timeAgo = '',
}: FeedPostProps) {
  const [isLiked, setIsLiked] = useState(false);
  const [likeCount, setLikeCount] = useState(likes || 0);
  const [isLiking, setIsLiking] = useState(false);
  const [commentCount, setCommentCount] = useState(comments || 0);
  const [commentsOpen, setCommentsOpen] = useState(false);
  const queryClient = useQueryClient();

  const handleLike = async () => {
    if (!id || isLiking) return;
    
    setIsLiking(true);
    const newIsLiked = !isLiked;
    const newCount = newIsLiked ? likeCount + 1 : likeCount - 1;
    
    // Optimistic update
    setIsLiked(newIsLiked);
    setLikeCount(newCount);

    try {
      // Update the likes count in the database
      const { error } = await supabase
        .from('feed_posts')
        .update({ likes: newCount })
        .eq('id', id);

      if (error) throw error;

      // Refresh the feed to get updated data
      queryClient.invalidateQueries({ queryKey: ["feed"] });
    } catch (error) {
      console.error("Error updating like:", error);
      // Revert on error
      setIsLiked(!newIsLiked);
      setLikeCount(newIsLiked ? newCount - 1 : newCount + 1);
    } finally {
      setIsLiking(false);
    }
  };

  const handleCommentAdded = () => {
    setCommentCount(commentCount + 1);
    queryClient.invalidateQueries({ queryKey: ["feed"] });
  };

  // Guard against missing data
  if (!petName || !image) {
    return null;
  }

  return (
    <article className="bg-card rounded-2xl overflow-hidden shadow-soft border border-border">
      {/* Header */}
      <div className="flex items-center justify-between p-4">
        <div className="flex items-center gap-3">
          <Avatar className="w-10 h-10 ring-2 ring-primary/20">
            <AvatarImage src={avatar ?? undefined} alt={petName ?? undefined} />
              <AvatarFallback className="bg-coral-light text-primary font-bold">
                {(petName && petName[0]) || (ownerName && ownerName[0]) || 'P'}
              </AvatarFallback>
          </Avatar>
          <div>
            <h4 className="font-bold text-foreground">{petName}</h4>
            <p className="text-xs text-muted-foreground">@{ownerName}</p>
          </div>
        </div>
        <Button variant="ghost" size="icon" className="text-muted-foreground">
          <MoreHorizontal className="w-5 h-5" />
        </Button>
      </div>

      {/* Image */}
      <div className="relative aspect-square">
        {/* support image as string or array; provide fallback placeholder */}
        <img
          src={Array.isArray(image) ? image[0] ?? '' : image ?? ''}
          alt={`Post by ${petName}`}
          className="w-full h-full object-cover"
        />
      </div>

      {/* Actions */}
      <div className="p-4">
        <div className="flex items-center gap-4 mb-3">
          <Button
            variant="ghost"
            size="icon"
            onClick={handleLike}
            className={cn(
              "transition-all hover:scale-110",
              isLiked && "text-primary"
            )}
          >
            <Heart
              className="w-6 h-6"
              fill={isLiked ? "currentColor" : "none"}
            />
          </Button>
          <Button 
            variant="ghost" 
            size="icon" 
            className="hover:scale-110 transition-all"
            onClick={() => setCommentsOpen(true)}
          >
            <MessageCircle className="w-6 h-6" />
          </Button>
          <Button variant="ghost" size="icon" className="hover:scale-110 transition-all">
            <Share2 className="w-6 h-6" />
          </Button>
        </div>

        {/* Likes count */}
        <p className="font-bold text-sm mb-2">{(likeCount ?? 0).toLocaleString()} likes</p>

        {/* Caption */}
        <p className="text-sm">
          <span className="font-bold">{petName}</span>{" "}
          <span className="text-foreground/80">{caption ?? ''}</span>
        </p>

        {/* Comments and time */}
        <div className="mt-2 space-y-1">
          <button 
            className="text-sm text-muted-foreground hover:text-foreground transition-colors"
            onClick={() => setCommentsOpen(true)}
          >
            View all {commentCount} comments
          </button>
          <p className="text-xs text-muted-foreground">{timeAgo}</p>
        </div>
      </div>

      {/* Comments Dialog */}
      {id && (
        <CommentsDialog
          open={commentsOpen}
          onOpenChange={setCommentsOpen}
          postId={id}
          commentCount={commentCount}
          onCommentAdded={handleCommentAdded}
          postImage={Array.isArray(image) ? image[0] : image ?? undefined}
          postCaption={caption ?? undefined}
          postLikes={likeCount}
          petName={petName ?? undefined}
          ownerName={ownerName ?? undefined}
          avatar={avatar ?? undefined}
          timeAgo={timeAgo ?? undefined}
        />
      )}
    </article>
  );
}
