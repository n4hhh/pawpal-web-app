import { X, Heart, RotateCcw, Star } from "lucide-react";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";

interface SwipeButtonsProps {
  onPass: () => void;
  onLike: () => void;
  onUndo?: () => void;
  onSuperLike?: () => void;
  canUndo?: boolean;
}

export function SwipeButtons({
  onPass,
  onLike,
  onUndo,
  onSuperLike,
  canUndo = false,
}: SwipeButtonsProps) {
  return (
    <div className="flex items-center justify-center gap-4">
      {/* Undo button */}
      <Button
        variant="outline"
        size="icon"
        onClick={onUndo}
        disabled={!canUndo}
        className={cn(
          "w-12 h-12 rounded-full border-2 border-muted-foreground/30 bg-card shadow-soft transition-all hover:scale-105",
          !canUndo && "opacity-50"
        )}
      >
        <RotateCcw className="w-5 h-5 text-muted-foreground" />
      </Button>
      
      {/* Pass button */}
      <Button
        variant="outline"
        size="icon"
        onClick={onPass}
        className="w-16 h-16 rounded-full border-2 border-destructive bg-card shadow-card transition-all hover:scale-110 hover:bg-destructive/10"
      >
        <X className="w-8 h-8 text-destructive" />
      </Button>
      
      {/* Super Like button */}
      <Button
        variant="outline"
        size="icon"
        onClick={onSuperLike}
        className="w-12 h-12 rounded-full border-2 border-accent bg-card shadow-soft transition-all hover:scale-105 hover:bg-accent/10"
      >
        <Star className="w-5 h-5 text-accent" />
      </Button>
      
      {/* Like button */}
      <Button
        variant="outline"
        size="icon"
        onClick={onLike}
        className="w-16 h-16 rounded-full border-2 border-mint bg-card shadow-card transition-all hover:scale-110 hover:bg-mint/10"
      >
        <Heart className="w-8 h-8 text-mint" fill="currentColor" />
      </Button>
    </div>
  );
}
