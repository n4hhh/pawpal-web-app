import { Layout } from "@/components/Layout";
import { FeedPost } from "@/components/FeedPost";
import { Stories } from "@/components/Stories";
import { feedPosts, mockPets } from "@/data/mockData";
import { useFeed } from "@/hooks/useFeed";
import { usePets } from "@/hooks/usePets";
import { useTrendingPets, useTrackPetView } from "@/hooks/useTrendingPets";
import { useRecommendedPets } from "@/hooks/useRecommendedPets";
import { getTrendingBadge } from "@/lib/trending";
import { getCompatibilityBadge } from "@/lib/matching";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarImage, AvatarFallback } from "@/components/ui/avatar";
import { TrendingUp, Users, Sparkles, Flame, Heart } from "lucide-react";
import { useNavigate } from "react-router-dom";

const Index = () => {
  const navigate = useNavigate();
  const { data: pets } = usePets();
  const { data: feed, isLoading } = useFeed();
  const { data: trendingPets, isLoading: isTrendingLoading } = useTrendingPets({ limit: 3 });
  const { data: recommendedPets, isLoading: isRecommendedLoading } = useRecommendedPets({ 
    limit: 3,
    filters: { maxDistance: 10 } // Recommend pets within 10 miles
  });
  const { trackView } = useTrackPetView();

  // Use feed data if available, fallback to mock
  const displayFeed = feed ?? feedPosts;
  
  // Use trending pets if available, fallback to regular pets
  const displayTrendingPets = trendingPets ?? (pets ?? mockPets).slice(0, 3);
  
  // Use recommended pets if available, fallback to regular pets
  const displayRecommendedPets = recommendedPets ?? (pets ?? mockPets).slice(2, 5);

  return (
    <Layout>
      <div className="container mx-auto px-4 lg:px-8 py-8">

        <div className="grid lg:grid-cols-3 gap-8">
          {/* Main Feed */}
          <div className="lg:col-span-2 space-y-6">
            {/* Stories */}
            <div className="bg-card rounded-lg border border-border overflow-hidden">
              <Stories />
            </div>

            {/* Feed Posts */}
            {isLoading ? (
              <Card className="p-8 text-center">
                <p className="text-muted-foreground">Loading feed...</p>
              </Card>
            ) : (displayFeed ?? []).length > 0 ? (
              displayFeed.map((post, index) => (
                <FeedPost key={post.id || index} {...post} />
              ))
            ) : (
              <Card className="p-8 text-center">
                <p className="text-muted-foreground mb-4">No posts yet</p>
                <p className="text-sm text-muted-foreground">Be the first to share a moment!</p>
              </Card>
            )}
          </div>

          {/* Sidebar */}
          <aside className="hidden lg:block space-y-6">
            <div className="sticky top-8 space-y-6">
            {/* Trending Pets */}
            <Card className="p-5">
              <div className="flex items-center gap-2 mb-4">
                <TrendingUp className="w-5 h-5 text-primary" />
                <h3 className="font-bold text-foreground">Trending Pets</h3>
              </div>
              {isTrendingLoading ? (
                <p className="text-sm text-muted-foreground text-center py-4">Loading...</p>
              ) : (
                <div className="space-y-3">
                  {displayTrendingPets.map((pet, index) => (
                    <button
                      key={pet.id}
                      onClick={() => trackView(pet.id)}
                      className="w-full flex items-center gap-3 p-2 rounded-lg hover:bg-muted transition-colors cursor-pointer"
                    >
                      <span className="text-sm font-bold text-muted-foreground w-4">{index + 1}</span>
                      <div className="relative">
                        <Avatar className="w-10 h-10">
                          <AvatarImage src={pet.image} alt={pet.name} />
                          <AvatarFallback>{pet.name[0]}</AvatarFallback>
                        </Avatar>
                        {'trendingScore' in pet && getTrendingBadge(pet.trendingScore) && (
                          <div className="absolute -top-1 -right-1 bg-gradient-to-r from-coral to-peach rounded-full p-0.5">
                            <Flame className="w-2.5 h-2.5 text-white" />
                          </div>
                        )}
                      </div>
                      <div className="flex-1 min-w-0 text-left">
                        <p className="font-semibold text-foreground text-sm">{pet.name}</p>
                        <p className="text-xs text-muted-foreground truncate">{pet.breed}</p>
                      </div>
                      {'trendingScore' in pet && getTrendingBadge(pet.trendingScore) && (
                        <span className="text-[10px] font-bold text-coral">
                          {getTrendingBadge(pet.trendingScore)}
                        </span>
                      )}
                    </button>
                  ))}
                </div>
              )}
            </Card>

            {/* Suggested Matches */}
            <Card className="p-5">
              <div className="flex items-center gap-2 mb-4">
                <Sparkles className="w-5 h-5 text-peach" />
                <h3 className="font-bold text-foreground">Find New Friends</h3>
              </div>
              {isRecommendedLoading ? (
                <p className="text-sm text-muted-foreground text-center py-4">Loading...</p>
              ) : (
                <div className="space-y-3">
                  {displayRecommendedPets.map((pet) => (
                    <div key={pet.id} className="flex items-center gap-3">
                      <div className="relative">
                        <Avatar className="w-12 h-12">
                          <AvatarImage src={pet.image} alt={pet.name} />
                          <AvatarFallback>{pet.name[0]}</AvatarFallback>
                        </Avatar>
                        {'compatibilityScore' in pet && pet.compatibilityScore >= 75 && (
                          <div className="absolute -bottom-1 -right-1 bg-gradient-to-r from-peach to-coral rounded-full p-0.5">
                            <Heart className="w-2.5 h-2.5 text-white fill-white" />
                          </div>
                        )}
                      </div>
                      <div className="flex-1 min-w-0">
                        <p className="font-semibold text-foreground text-sm">{pet.name}</p>
                        <p className="text-xs text-muted-foreground">{pet.location}</p>
                        {'compatibilityScore' in pet && getCompatibilityBadge(pet.compatibilityScore) && (
                          <p className="text-[10px] font-medium text-peach">
                            {getCompatibilityBadge(pet.compatibilityScore)}
                          </p>
                        )}
                      </div>
                      <Button size="sm" variant="outline" className="rounded-full text-xs">
                        Match
                      </Button>
                    </div>
                  ))}
                </div>
              )}
            </Card>

            {/* Community Stats */}
            <Card className="p-5 gradient-coral text-primary-foreground">
              <div className="flex items-center gap-2 mb-3">
                <Users className="w-5 h-5" />
                <h3 className="font-bold">Join the Pack!</h3>
              </div>
              <p className="text-sm opacity-90 mb-4">
                Over 50,000 pets have found their perfect playmates on PawPals.
              </p>
              <Button 
                variant="secondary" 
                className="w-full rounded-full font-bold"
                onClick={() => navigate('/match')}
              >
                Start Matching
              </Button>
            </Card>
            </div>
          </aside>
        </div>
      </div>
    </Layout>
  );
};

export default Index;
