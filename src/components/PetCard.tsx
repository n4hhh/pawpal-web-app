import { Heart, MapPin, Sparkles } from "lucide-react";
import { cn } from "@/lib/utils";

interface PetCardProps {
  name: string;
  age: string;
  breed: string;
  location: string;
  image: string;
  bio: string;
  className?: string;
  onLike?: () => void;
  onPass?: () => void;
  isSwipingRight?: boolean;
  isSwipingLeft?: boolean;
}

export function PetCard({
  name,
  age,
  breed,
  location,
  image,
  bio,
  className,
  isSwipingRight,
  isSwipingLeft,
}: PetCardProps) {
  return (
    <div
      className={cn(
        "relative w-full max-w-sm bg-card rounded-2xl overflow-hidden shadow-card transition-all duration-300",
        isSwipingRight && "animate-swipe-right",
        isSwipingLeft && "animate-swipe-left",
        className
      )}
    >
      {/* Image */}
      <div className="relative aspect-[4/5] overflow-hidden">
        <img
          src={image}
          alt={name}
          className="w-full h-full object-cover"
        />
        
        {/* Gradient overlay */}
        <div className="absolute inset-0 bg-gradient-to-t from-foreground/80 via-transparent to-transparent" />
        
        {/* Like/Pass indicators */}
        {isSwipingRight && (
          <div className="absolute top-8 left-8 px-4 py-2 border-4 border-mint rounded-lg rotate-[-20deg]">
            <span className="text-2xl font-extrabold text-mint">LIKE</span>
          </div>
        )}
        {isSwipingLeft && (
          <div className="absolute top-8 right-8 px-4 py-2 border-4 border-destructive rounded-lg rotate-[20deg]">
            <span className="text-2xl font-extrabold text-destructive">NOPE</span>
          </div>
        )}
        
        {/* Info overlay */}
        <div className="absolute bottom-0 left-0 right-0 p-6 text-primary-foreground">
          <div className="flex items-center gap-2 mb-1">
            <h3 className="text-2xl font-bold">{name}</h3>
            <span className="text-xl font-semibold">{age}</span>
            <Sparkles className="w-5 h-5 text-peach ml-auto" />
          </div>
          
          <p className="text-sm font-medium opacity-90 mb-2">{breed}</p>
          
          <div className="flex items-center gap-1 text-sm opacity-80">
            <MapPin className="w-4 h-4" />
            <span>{location}</span>
          </div>
        </div>
      </div>
      
      {/* Bio section */}
      <div className="p-4 bg-card">
        <p className="text-sm text-muted-foreground line-clamp-2">{bio}</p>
      </div>
    </div>
  );
}
