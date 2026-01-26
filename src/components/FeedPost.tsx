import { Heart, MessageCircle, Share2, MoreHorizontal } from "lucide-react";
import { useState } from "react";
import { Avatar, AvatarImage, AvatarFallback } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";

interface FeedPostProps {
  petName: string;
  ownerName: string;
  avatar: string;
  image: string;
  caption: string;
  likes: number;
  comments: number;
  timeAgo: string;
}

export function FeedPost({
  petName,
  ownerName,
  avatar,
  image,
  caption,
  likes,
  comments,
  timeAgo,
}: FeedPostProps) {
  const [isLiked, setIsLiked] = useState(false);
  const [likeCount, setLikeCount] = useState(likes);

  const handleLike = () => {
    setIsLiked(!isLiked);
    setLikeCount(isLiked ? likeCount - 1 : likeCount + 1);
  };

  return (
    <article className="bg-card rounded-2xl overflow-hidden shadow-soft border border-border">
      {/* Header */}
      <div className="flex items-center justify-between p-4">
        <div className="flex items-center gap-3">
          <Avatar className="w-10 h-10 ring-2 ring-primary/20">
            <AvatarImage src={avatar} alt={petName} />
            <AvatarFallback className="bg-coral-light text-primary font-bold">
              {petName[0]}
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
        <img
          src={image}
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
          <Button variant="ghost" size="icon" className="hover:scale-110 transition-all">
            <MessageCircle className="w-6 h-6" />
          </Button>
          <Button variant="ghost" size="icon" className="hover:scale-110 transition-all">
            <Share2 className="w-6 h-6" />
          </Button>
        </div>

        {/* Likes count */}
        <p className="font-bold text-sm mb-2">{likeCount.toLocaleString()} likes</p>

        {/* Caption */}
        <p className="text-sm">
          <span className="font-bold">{petName}</span>{" "}
          <span className="text-foreground/80">{caption}</span>
        </p>

        {/* Comments and time */}
        <div className="mt-2 space-y-1">
          <button className="text-sm text-muted-foreground hover:text-foreground transition-colors">
            View all {comments} comments
          </button>
          <p className="text-xs text-muted-foreground">{timeAgo}</p>
        </div>
      </div>
    </article>
  );
}
