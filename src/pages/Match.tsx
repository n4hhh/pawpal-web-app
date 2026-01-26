import { useState, useCallback } from "react";
import { Layout } from "@/components/Layout";
import { PetCard } from "@/components/PetCard";
import { SwipeButtons } from "@/components/SwipeButtons";
import { mockPets } from "@/data/mockData";
import { Sparkles, Filter, MapPin } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Avatar, AvatarImage, AvatarFallback } from "@/components/ui/avatar";

const Match = () => {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [swipeDirection, setSwipeDirection] = useState<"left" | "right" | null>(null);
  const [matchedPets, setMatchedPets] = useState<string[]>([]);
  const [showMatch, setShowMatch] = useState(false);

  const currentPet = mockPets[currentIndex];

  const handleSwipe = useCallback((direction: "left" | "right") => {
    setSwipeDirection(direction);
    
    if (direction === "right") {
      if (Math.random() > 0.7) {
        setMatchedPets([...matchedPets, currentPet.id]);
        setTimeout(() => setShowMatch(true), 400);
      }
    }

    setTimeout(() => {
      setSwipeDirection(null);
      setCurrentIndex((prev) => Math.min(prev + 1, mockPets.length));
    }, 400);
  }, [currentIndex, matchedPets, currentPet]);

  const handleUndo = useCallback(() => {
    if (currentIndex > 0) {
      setCurrentIndex((prev) => prev - 1);
    }
  }, [currentIndex]);

  const handleSuperLike = useCallback(() => {
    setMatchedPets([...matchedPets, currentPet.id]);
    setSwipeDirection("right");
    setTimeout(() => {
      setShowMatch(true);
      setSwipeDirection(null);
      setCurrentIndex((prev) => Math.min(prev + 1, mockPets.length));
    }, 400);
  }, [currentIndex, matchedPets, currentPet]);

  if (currentIndex >= mockPets.length) {
    return (
      <Layout>
        <div className="container mx-auto px-4 lg:px-8 py-8">
          <div className="max-w-lg mx-auto text-center py-16">
            <div className="w-24 h-24 rounded-full bg-coral-light mx-auto mb-6 flex items-center justify-center">
              <Sparkles className="w-12 h-12 text-primary" />
            </div>
            <h2 className="text-3xl font-bold text-foreground mb-3">
              You've seen them all!
            </h2>
            <p className="text-muted-foreground mb-8 text-lg">
              Check back later for new furry friends in your area.
            </p>
            <Button
              onClick={() => setCurrentIndex(0)}
              className="px-8 py-3 gradient-coral text-primary-foreground font-bold rounded-full shadow-card hover:scale-105 transition-transform"
            >
              Start Over
            </Button>
          </div>
        </div>
      </Layout>
    );
  }

  return (
    <Layout>
      <div className="container mx-auto px-4 lg:px-8 py-8">
        <div className="grid lg:grid-cols-3 gap-8">
          {/* Left Sidebar - Filters */}
          <aside className="hidden lg:block">
            <Card className="p-5 sticky top-24">
              <div className="flex items-center gap-2 mb-4">
                <Filter className="w-5 h-5 text-primary" />
                <h3 className="font-bold text-foreground">Filters</h3>
              </div>
              <div className="space-y-4">
                <div>
                  <label className="text-sm font-medium text-muted-foreground mb-2 block">Species</label>
                  <div className="flex flex-wrap gap-2">
                    {["All", "Dogs", "Cats", "Others"].map((type) => (
                      <Button key={type} variant={type === "All" ? "default" : "outline"} size="sm" className="rounded-full">
                        {type}
                      </Button>
                    ))}
                  </div>
                </div>
                <div>
                  <label className="text-sm font-medium text-muted-foreground mb-2 block">Distance</label>
                  <div className="flex items-center gap-2 text-sm text-foreground">
                    <MapPin className="w-4 h-4 text-muted-foreground" />
                    <span>Within 10 miles</span>
                  </div>
                </div>
                <div>
                  <label className="text-sm font-medium text-muted-foreground mb-2 block">Age</label>
                  <div className="flex flex-wrap gap-2">
                    {["Puppy", "Young", "Adult", "Senior"].map((age) => (
                      <Button key={age} variant="outline" size="sm" className="rounded-full">
                        {age}
                      </Button>
                    ))}
                  </div>
                </div>
              </div>
            </Card>
          </aside>

          {/* Main Card Area */}
          <div className="lg:col-span-1 flex flex-col items-center">
            <h2 className="text-2xl font-bold text-foreground mb-6 text-center">Find Your Pet's New Friend</h2>
            
            {/* Card Stack */}
            <div className="relative h-[520px] w-full max-w-sm mb-6">
              {mockPets.slice(currentIndex + 1, currentIndex + 3).reverse().map((pet, i) => (
                <div
                  key={pet.id}
                  className="absolute inset-0 flex justify-center"
                  style={{
                    transform: `scale(${0.95 - i * 0.05}) translateY(${(i + 1) * 10}px)`,
                    zIndex: 10 - i,
                    opacity: 0.5 - i * 0.2,
                  }}
                >
                  <PetCard {...pet} className="pointer-events-none" />
                </div>
              ))}
              
              <div className="absolute inset-0 flex justify-center" style={{ zIndex: 20 }}>
                <PetCard
                  {...currentPet}
                  isSwipingRight={swipeDirection === "right"}
                  isSwipingLeft={swipeDirection === "left"}
                />
              </div>
            </div>

            <SwipeButtons
              onPass={() => handleSwipe("left")}
              onLike={() => handleSwipe("right")}
              onUndo={handleUndo}
              onSuperLike={handleSuperLike}
              canUndo={currentIndex > 0}
            />
          </div>

          {/* Right Sidebar - Recent Matches */}
          <aside className="hidden lg:block">
            <Card className="p-5 sticky top-24">
              <div className="flex items-center gap-2 mb-4">
                <Sparkles className="w-5 h-5 text-peach" />
                <h3 className="font-bold text-foreground">Recent Matches</h3>
              </div>
              <div className="space-y-3">
                {mockPets.slice(0, 4).map((pet) => (
                  <div key={pet.id} className="flex items-center gap-3 p-2 rounded-lg hover:bg-muted transition-colors cursor-pointer">
                    <Avatar className="w-12 h-12 ring-2 ring-primary/20">
                      <AvatarImage src={pet.image} alt={pet.name} />
                      <AvatarFallback>{pet.name[0]}</AvatarFallback>
                    </Avatar>
                    <div className="flex-1 min-w-0">
                      <p className="font-semibold text-foreground text-sm">{pet.name}</p>
                      <p className="text-xs text-muted-foreground truncate">{pet.breed}</p>
                    </div>
                  </div>
                ))}
              </div>
              <Button variant="outline" className="w-full mt-4 rounded-full">
                View All Matches
              </Button>
            </Card>
          </aside>
        </div>
      </div>

      {/* Match Modal */}
      {showMatch && (
        <div 
          className="fixed inset-0 bg-foreground/60 backdrop-blur-sm flex items-center justify-center z-50 p-4"
          onClick={() => setShowMatch(false)}
        >
          <div 
            className="bg-card rounded-3xl p-8 text-center max-w-md w-full shadow-elevated animate-in zoom-in-75 duration-300"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="w-20 h-20 rounded-full gradient-mint mx-auto mb-4 flex items-center justify-center animate-float">
              <Sparkles className="w-10 h-10 text-primary-foreground" />
            </div>
            <h2 className="text-3xl font-extrabold text-foreground mb-2">
              It's a Match!
            </h2>
            <p className="text-muted-foreground mb-6">
              You and {currentPet.name} liked each other! Start a conversation now.
            </p>
            <div className="flex gap-3">
              <Button
                variant="outline"
                onClick={() => setShowMatch(false)}
                className="flex-1 rounded-full font-bold"
              >
                Keep Swiping
              </Button>
              <Button
                onClick={() => setShowMatch(false)}
                className="flex-1 gradient-mint text-primary-foreground font-bold rounded-full shadow-soft hover:scale-105 transition-transform"
              >
                Say Hello
              </Button>
            </div>
          </div>
        </div>
      )}
    </Layout>
  );
};

export default Match;
