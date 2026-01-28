import { useState, useEffect } from "react";
import {
  Dialog,
  DialogContent,
  DialogTitle,
  DialogDescription,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Avatar, AvatarImage, AvatarFallback } from "@/components/ui/avatar";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Heart, Send, Loader2, MessageCircle, MoreHorizontal } from "lucide-react";
import { supabase } from "@/lib/supabase";
import { useToast } from "@/hooks/use-toast";

interface Comment {
  id: string;
  user_id: string;
  content: string;
  created_at: string;
  username?: string;
  avatar?: string;
}

interface CommentsDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  postId: string;
  commentCount: number;
  onCommentAdded?: () => void;
  // Post details
  postImage?: string;
  postCaption?: string;
  postLikes?: number;
  petName?: string;
  ownerName?: string;
  avatar?: string;
  timeAgo?: string;
}

export function CommentsDialog({
  open,
  onOpenChange,
  postId,
  commentCount,
  onCommentAdded,
  postImage,
  postCaption,
  postLikes,
  petName,
  ownerName,
  avatar,
  timeAgo,
}: CommentsDialogProps) {
  const [comments, setComments] = useState<Comment[]>([]);
  const [newComment, setNewComment] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [username, setUsername] = useState("");
  const [isLiked, setIsLiked] = useState(false);
  const [likeCount, setLikeCount] = useState(postLikes || 0);
  const [isLiking, setIsLiking] = useState(false);
  const { toast } = useToast();

  useEffect(() => {
    if (open && postId) {
      fetchComments();
    }
  }, [open, postId]);

  const fetchComments = async () => {
    setIsLoading(true);
    try {
      const { data, error } = await supabase
        .from("post_comments")
        .select("*")
        .eq("post_id", postId)
        .order("created_at", { ascending: true });

      if (error) throw error;
      setComments(data || []);
    } catch (error) {
      console.error("Error fetching comments:", error);
      toast({
        title: "Error",
        description: "Failed to load comments",
        variant: "destructive",
      });
    } finally {
      setIsLoading(false);
    }
  };

  const handleLike = async () => {
    if (!postId || isLiking) return;
    
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
        .eq('id', postId);

      if (error) throw error;
    } catch (error) {
      console.error("Error updating like:", error);
      // Revert on error
      setIsLiked(!newIsLiked);
      setLikeCount(newIsLiked ? newCount - 1 : newCount + 1);
      toast({
        title: "Error",
        description: "Failed to update like",
        variant: "destructive",
      });
    } finally {
      setIsLiking(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newComment.trim() || !username.trim()) {
      toast({
        title: "Missing fields",
        description: "Please enter your name and comment",
        variant: "destructive",
      });
      return;
    }

    setIsSubmitting(true);
    try {
      // Insert comment with username as text
      const { error: commentError } = await supabase
        .from("post_comments")
        .insert({
          post_id: postId,
          user_id: username.trim(), // Store username as text
          content: newComment.trim(),
        });

      if (commentError) {
        console.error("Comment error:", commentError);
        throw commentError;
      }

      // Update comment count
      const { error: updateError } = await supabase
        .from("feed_posts")
        .update({ comments: commentCount + 1 })
        .eq("id", postId);

      if (updateError) throw updateError;

      toast({
        title: "Comment posted!",
        description: "Your comment has been added.",
      });

      setNewComment("");
      fetchComments();
      if (onCommentAdded) onCommentAdded();
    } catch (error) {
      console.error("Error posting comment:", error);
      toast({
        title: "Error",
        description: "Failed to post comment",
        variant: "destructive",
      });
    } finally {
      setIsSubmitting(false);
    }
  };

  const formatTimeAgo = (dateString: string) => {
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
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-[900px] h-[90vh] flex flex-col p-0 gap-0 [&>button]:hidden overflow-hidden">
        <DialogTitle className="sr-only">Post Details</DialogTitle>
        <DialogDescription className="sr-only">
          View post and comments from {petName}
        </DialogDescription>
        <div className="grid md:grid-cols-2 h-full">
          {/* Left side - Post Image */}
          <div className="bg-black hidden md:flex items-center justify-center">
            <img
              src={postImage}
              alt="Post"
              className="w-full h-full object-contain"
            />
          </div>

          {/* Right side - Post details and Comments */}
          <div className="flex flex-col h-full">
            {/* Post Header */}
            <div className="px-4 py-3 border-b flex items-center gap-3">
              <Avatar className="w-8 h-8">
                <AvatarImage src={avatar} />
                <AvatarFallback className="bg-primary/10 text-primary">
                  {petName?.[0]?.toUpperCase() || "P"}
                </AvatarFallback>
              </Avatar>
              <div className="flex-1 flex items-center gap-2">
                <h4 className="font-semibold text-sm">{petName}</h4>
                <span className="text-muted-foreground">•</span>
                <Button 
                  variant="ghost" 
                  size="sm" 
                  className="h-auto p-0 text-primary font-semibold hover:text-primary/80 hover:bg-transparent"
                >
                  Follow
                </Button>
              </div>
              <Button variant="ghost" size="icon" className="w-8 h-8">
                <MoreHorizontal className="w-5 h-5" />
              </Button>
            </div>

            {/* Mobile - Post Image */}
            <div className="md:hidden bg-black">
              <img
                src={postImage}
                alt="Post"
                className="w-full aspect-square object-cover"
              />
            </div>

            {/* Comments Section - Caption + Comments */}
            <ScrollArea className="flex-1">
              <div className="px-4 py-3 space-y-4">
                {/* Original Caption as first "comment" */}
                <div className="flex gap-3">
                  <Avatar className="w-8 h-8 flex-shrink-0">
                    <AvatarImage src={avatar} />
                    <AvatarFallback className="bg-primary/10 text-primary text-xs">
                      {petName?.[0]?.toUpperCase() || "P"}
                    </AvatarFallback>
                  </Avatar>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-baseline gap-2">
                      <span className="font-semibold text-sm">{petName}</span>
                      <span className="text-xs text-muted-foreground">{timeAgo}</span>
                    </div>
                    <p className="text-sm mt-1 break-words">{postCaption}</p>
                  </div>
                </div>

                {/* All Comments */}
                {isLoading ? (
                  <div className="flex items-center justify-center h-32">
                    <Loader2 className="w-6 h-6 animate-spin text-muted-foreground" />
                  </div>
                ) : comments.length === 0 ? (
                  <div className="flex flex-col items-center justify-center h-24 text-center">
                    <p className="text-sm text-muted-foreground">No comments yet</p>
                  </div>
                ) : (
                  <>
                    {comments.map((comment) => (
                      <div key={comment.id} className="flex gap-3">
                        <Avatar className="w-8 h-8 flex-shrink-0">
                          <AvatarImage src={comment.avatar} />
                          <AvatarFallback className="bg-primary/10 text-primary text-xs">
                            {comment.user_id?.[0]?.toUpperCase() || "U"}
                          </AvatarFallback>
                        </Avatar>
                        <div className="flex-1 min-w-0">
                          <div className="flex items-baseline gap-2">
                            <span className="font-semibold text-sm">
                              {comment.user_id}
                            </span>
                            <span className="text-xs text-muted-foreground">
                              {formatTimeAgo(comment.created_at)}
                            </span>
                          </div>
                          <p className="text-sm mt-1 break-words">{comment.content}</p>
                        </div>
                      </div>
                    ))}
                  </>
                )}
              </div>
            </ScrollArea>

            {/* Like Bar */}
            <div className="px-4 py-2 border-t">
              <div className="flex items-center gap-4">
                <Heart 
                  className="w-6 h-6 cursor-pointer hover:scale-110 transition-all" 
                  fill={isLiked ? "currentColor" : "none"}
                  onClick={handleLike}
                  style={{ color: isLiked ? "#ef4444" : "currentColor" }}
                />
                <MessageCircle className="w-6 h-6 cursor-pointer" />
                <Send className="w-6 h-6 cursor-pointer" />
              </div>
              <div className="mt-2">
                <span className="text-sm font-semibold">{likeCount?.toLocaleString()} likes</span>
              </div>
            </div>

            {/* Comment Input */}
            <div className="border-t px-4 py-3">
              <form onSubmit={handleSubmit} className="space-y-2">
                <Input
                  placeholder="Your name (required)"
                  value={username}
                  onChange={(e) => setUsername(e.target.value)}
                  disabled={isSubmitting}
                  className="text-xs"
                />
                <div className="flex items-center gap-2">
                  <Input
                    placeholder="Add a comment..."
                    value={newComment}
                    onChange={(e) => setNewComment(e.target.value)}
                    disabled={isSubmitting}
                    className="flex-1 border-0 focus-visible:ring-0 px-0"
                  />
                  <Button
                    type="submit"
                    variant="ghost"
                    size="sm"
                    disabled={isSubmitting || !username.trim() || !newComment.trim()}
                    className="text-primary font-semibold hover:text-primary/80 px-0"
                  >
                    {isSubmitting ? (
                      <Loader2 className="w-4 h-4 animate-spin" />
                    ) : (
                      "Post"
                    )}
                  </Button>
                </div>
              </form>
            </div>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  );
}
