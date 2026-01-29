import { useEffect, useState } from "react";
import { Layout } from "@/components/Layout";
import { Avatar, AvatarImage, AvatarFallback } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { mockPets } from "@/data/mockData";
import { Settings, Edit3, Grid3X3, Heart, MapPin, Calendar, Camera, Star, Award } from "lucide-react";
import { useAuth } from "@/hooks/useAuth";
import { supabase } from "@/lib/supabase";

interface UserProfile {
  id: string;
  email: string;
  username: string;
  display_name: string;
  bio: string | null;
  avatar: string | null;
}

const Profile = () => {
  const { user, loading: userLoading } = useAuth();
  const [userProfile, setUserProfile] = useState<UserProfile | null>(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    async function fetchUserProfile() {
      if (!user?.id) {
        console.log('No user ID available yet');
        return;
      }

      setLoading(true);
      console.log('Fetching profile for user:', user.id);

      try {
        const { data, error } = await supabase
          .from('users')
          .select('id, email, username, display_name, avatar, bio, created_at')
          .eq('id', user.id)
          .single();

        if (error) {
          console.error('Error fetching profile:', error.message);
          setUserProfile(null);
        } else {
          console.log('Profile fetched successfully:', data);
          setUserProfile(data);
        }
      } catch (err) {
        console.error('Unexpected error:', err);
      } finally {
        setLoading(false);
      }
    }

    if (!userLoading) {
      fetchUserProfile();
    }
  }, [user?.id, userLoading]);

  const myPet = userProfile || {
    name: 'Loading...',
    owner: 'user',
    image: mockPets[0].image,
    bio: 'Loading profile...',
    breed: '-',
    age: '-',
    location: '-'
  };
  return (
    <Layout>
      <div className="container mx-auto px-4 lg:px-8 py-8">
        <div className="grid lg:grid-cols-3 gap-8">
          {/* Profile Sidebar */}
          <aside className="lg:col-span-1">
            <Card className="p-6 text-center">
              {/* Avatar */}
              <div className="relative inline-block mb-4">
                <Avatar className="w-32 h-32 ring-4 ring-primary/20">
                  <AvatarImage src={userProfile?.avatar || mockPets[0].image} alt={userProfile?.display_name} />
                  <AvatarFallback className="text-3xl">{userProfile?.display_name?.[0] || 'U'}</AvatarFallback>
                </Avatar>
                <button className="absolute bottom-0 right-0 w-10 h-10 rounded-full gradient-coral flex items-center justify-center shadow-soft">
                  <Camera className="w-5 h-5 text-primary-foreground" />
                </button>
              </div>

              <h2 className="text-2xl font-extrabold text-foreground">{userProfile?.display_name || 'User'}</h2>
              <p className="text-muted-foreground mb-4">@{userProfile?.username || 'username'}</p>

              {/* Stats */}
              <div className="flex justify-center gap-8 mb-6">
                <div className="text-center">
                  <p className="text-2xl font-bold text-foreground">24</p>
                  <p className="text-xs text-muted-foreground">Posts</p>
                </div>
                <div className="text-center">
                  <p className="text-2xl font-bold text-foreground">1.2k</p>
                  <p className="text-xs text-muted-foreground">Followers</p>
                </div>
                <div className="text-center">
                  <p className="text-2xl font-bold text-foreground">89</p>
                  <p className="text-xs text-muted-foreground">Matches</p>
                </div>
              </div>

              {/* Actions */}
              <div className="flex gap-3">
                <Button className="flex-1 gradient-coral text-primary-foreground font-bold rounded-full shadow-soft hover:scale-105 transition-transform">
                  <Edit3 className="w-4 h-4 mr-2" />
                  Edit Profile
                </Button>
                <Button variant="outline" size="icon" className="rounded-full">
                  <Settings className="w-5 h-5" />
                </Button>
              </div>
            </Card>

            {/* Pet Info Card */}
            <Card className="p-5 mt-6">
              <h3 className="font-bold text-foreground mb-4">About {userProfile?.display_name || 'User'}</h3>
              <p className="text-sm text-muted-foreground mb-4">{userProfile?.bio || 'No bio yet'}</p>

              <div className="space-y-3">
                <div className="flex items-center gap-3 text-sm">
                  <div className="w-9 h-9 rounded-full bg-coral-light flex items-center justify-center">
                    <Heart className="w-4 h-4 text-primary" />
                  </div>
                  <span className="text-muted-foreground">{userProfile?.email || '-'}</span>
                </div>
              </div>
            </Card>

            {/* Achievements */}
            <Card className="p-5 mt-6">
              <div className="flex items-center gap-2 mb-4">
                <Award className="w-5 h-5 text-peach" />
                <h3 className="font-bold text-foreground">Achievements</h3>
              </div>
              <div className="flex gap-3">
                {["🏆", "⭐", "💫", "🎉"].map((emoji, i) => (
                  <div key={i} className="w-12 h-12 rounded-full bg-muted flex items-center justify-center text-xl">
                    {emoji}
                  </div>
                ))}
              </div>
            </Card>
          </aside>

          {/* Main Content */}
          <div className="lg:col-span-2">
            <Tabs defaultValue="posts" className="w-full">
              <TabsList className="w-full grid grid-cols-3 mb-6">
                <TabsTrigger value="posts" className="gap-2">
                  <Grid3X3 className="w-4 h-4" />
                  Posts
                </TabsTrigger>
                <TabsTrigger value="liked" className="gap-2">
                  <Heart className="w-4 h-4" />
                  Liked
                </TabsTrigger>
                <TabsTrigger value="reviews" className="gap-2">
                  <Star className="w-4 h-4" />
                  Reviews
                </TabsTrigger>
              </TabsList>

              <TabsContent value="posts">
                <div className="grid grid-cols-3 gap-3">
                  {[...mockPets, ...mockPets].map((pet, index) => (
                    <div key={index} className="aspect-square rounded-xl overflow-hidden group cursor-pointer">
                      <img
                        src={pet.image}
                        alt={`Post ${index + 1}`}
                        className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                      />
                    </div>
                  ))}
                </div>
              </TabsContent>

              <TabsContent value="liked">
                <div className="grid grid-cols-3 gap-3">
                  {mockPets.slice(0, 6).map((pet, index) => (
                    <div key={index} className="aspect-square rounded-xl overflow-hidden group cursor-pointer relative">
                      <img
                        src={pet.image}
                        alt={`Liked ${index + 1}`}
                        className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                      />
                      <div className="absolute inset-0 bg-foreground/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
                        <Heart className="w-8 h-8 text-primary-foreground fill-current" />
                      </div>
                    </div>
                  ))}
                </div>
              </TabsContent>

              <TabsContent value="reviews">
                <div className="space-y-4">
                  {[1, 2, 3].map((i) => (
                    <Card key={i} className="p-4">
                      <div className="flex items-start gap-3">
                        <Avatar className="w-10 h-10">
                          <AvatarImage src={mockPets[i].image} alt={mockPets[i].name} />
                          <AvatarFallback>{mockPets[i].name[0]}</AvatarFallback>
                        </Avatar>
                        <div className="flex-1">
                          <div className="flex items-center justify-between mb-1">
                            <h4 className="font-semibold text-foreground">{mockPets[i].name}</h4>
                            <div className="flex gap-0.5">
                              {[1, 2, 3, 4, 5].map((star) => (
                                <Star key={star} className="w-4 h-4 fill-peach text-peach" />
                              ))}
                            </div>
                          </div>
                          <p className="text-sm text-muted-foreground">
                            Amazing playdate! Our pets had so much fun together. Would definitely recommend! 🐾
                          </p>
                        </div>
                      </div>
                    </Card>
                  ))}
                </div>
              </TabsContent>
            </Tabs>
          </div>
        </div>
      </div>
    </Layout>
  );
};

export default Profile;
