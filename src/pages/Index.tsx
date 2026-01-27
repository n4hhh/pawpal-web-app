import { Layout } from "@/components/Layout";
import { FeedPost } from "@/components/FeedPost";
import { feedPosts, mockPets } from "@/data/mockData";
import { useFeed } from "@/hooks/useFeed";
import { usePets } from "@/hooks/usePets";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarImage, AvatarFallback } from "@/components/ui/avatar";
import { TrendingUp, Users, Sparkles } from "lucide-react";

const Index = () => {
  const { data: pets } = usePets();
  const { data: feed } = useFeed();

  // Use feed data if available, fallback to mock
  const displayFeed = feed ?? feedPosts;

  return (
    <Layout>
      <div className="container mx-auto px-4 lg:px-8 py-8">
        <div className="grid lg:grid-cols-3 gap-8">
          {/* Main Feed */}
          <div className="lg:col-span-2 space-y-6">
            {/* Stories */}
            <Card className="p-4">
              <div className="flex gap-4 overflow-x-auto pb-2 scrollbar-hide">
                {[
                  "Add Story",
                  "Max",
                  "Luna",
                  "Bruno",
                  "Whiskers",
                  "Cooper",
                ].map((name, i) => (
                  <div key={i} className="flex flex-col items-center gap-2 flex-shrink-0">
                    <div className={`w-16 h-16 rounded-full p-0.5 ${i === 0 ? 'border-2 border-dashed border-muted-foreground' : 'gradient-coral'}`}>
                      <div className="w-full h-full rounded-full bg-muted flex items-center justify-center overflow-hidden">
                        {i === 0 ? (
                          <span className="text-2xl text-muted-foreground">+</span>
                        ) : (
                          <img
                            src={
                              (pets ?? mockPets)[Math.min(i - 1, (pets ?? mockPets).length - 1)]?.image
                            }
                            alt={name}
                            className="w-full h-full object-cover"
                          />
                        )}
                      </div>
                    </div>
                    <span className="text-xs font-medium text-foreground truncate w-16 text-center">
                      {name}
                    </span>
                  </div>
                ))}
              </div>
            </Card>

              {/* Feed Posts */}
              {(displayFeed ?? []).length > 0 ? (
                displayFeed.map((post, index) => (
                  <FeedPost key={index} {...post} />
                ))
              ) : (
                <p className="text-center text-muted-foreground">No feed posts available</p>
              )}
          </div>

          {/* Sidebar */}
          <aside className="hidden lg:block space-y-6">
            {/* Trending Pets */}
            <Card className="p-5">
              <div className="flex items-center gap-2 mb-4">
                <TrendingUp className="w-5 h-5 text-primary" />
                <h3 className="font-bold text-foreground">Trending Pets</h3>
              </div>
              <div className="space-y-3">
                {(pets ?? mockPets).slice(0, 3).map((pet, index) => (
                  <div key={pet.id} className="flex items-center gap-3 p-2 rounded-lg hover:bg-muted transition-colors cursor-pointer">
                    <span className="text-sm font-bold text-muted-foreground w-4">{index + 1}</span>
                    <Avatar className="w-10 h-10">
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
            </Card>

            {/* Suggested Matches */}
            <Card className="p-5">
              <div className="flex items-center gap-2 mb-4">
                <Sparkles className="w-5 h-5 text-peach" />
                <h3 className="font-bold text-foreground">Find New Friends</h3>
              </div>
              <div className="space-y-3">
                {(pets ?? mockPets).slice(2, 5).map((pet) => (
                  <div key={pet.id} className="flex items-center gap-3">
                    <Avatar className="w-12 h-12">
                      <AvatarImage src={pet.image} alt={pet.name} />
                      <AvatarFallback>{pet.name[0]}</AvatarFallback>
                    </Avatar>
                    <div className="flex-1 min-w-0">
                      <p className="font-semibold text-foreground text-sm">{pet.name}</p>
                      <p className="text-xs text-muted-foreground">{pet.location}</p>
                    </div>
                    <Button size="sm" variant="outline" className="rounded-full text-xs">
                      Match
                    </Button>
                  </div>
                ))}
              </div>
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
              <Button variant="secondary" className="w-full rounded-full font-bold">
                Start Matching
              </Button>
            </Card>
          </aside>
        </div>
      </div>
    </Layout>
  );
};

export default Index;
