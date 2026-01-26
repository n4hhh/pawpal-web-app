import { Layout } from "@/components/Layout";
import { Avatar, AvatarImage, AvatarFallback } from "@/components/ui/avatar";
import { mockPets } from "@/data/mockData";
import { MessageCircle, Search, Phone, Video, MoreVertical, Send } from "lucide-react";
import { Card } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { useState } from "react";

const conversations = [
  {
    pet: mockPets[0],
    lastMessage: "Would love to meet up for a playdate!",
    time: "2m ago",
    unread: true,
  },
  {
    pet: mockPets[1],
    lastMessage: "That sounds purr-fect! 😺",
    time: "1h ago",
    unread: true,
  },
  {
    pet: mockPets[2],
    lastMessage: "See you at the dog park!",
    time: "3h ago",
    unread: false,
  },
  {
    pet: mockPets[3],
    lastMessage: "Thanks for the treat recommendation!",
    time: "1d ago",
    unread: false,
  },
];

const Messages = () => {
  const [selectedConvo, setSelectedConvo] = useState(conversations[0]);

  return (
    <Layout>
      <div className="container mx-auto px-4 lg:px-8 py-8">
        <div className="grid lg:grid-cols-3 gap-6 h-[calc(100vh-12rem)]">
          {/* Conversations List */}
          <Card className="lg:col-span-1 flex flex-col overflow-hidden">
            {/* Search */}
            <div className="p-4 border-b border-border">
              <div className="relative">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                <Input placeholder="Search messages..." className="pl-10" />
              </div>
            </div>

            {/* New Matches */}
            <div className="p-4 border-b border-border">
              <h2 className="text-sm font-bold text-muted-foreground mb-3">NEW MATCHES</h2>
              <div className="flex gap-3 overflow-x-auto pb-2">
                {mockPets.slice(0, 4).map((pet) => (
                  <button
                    key={pet.id}
                    className="flex flex-col items-center gap-1 flex-shrink-0 group"
                  >
                    <div className="w-14 h-14 rounded-full p-0.5 gradient-coral group-hover:scale-105 transition-transform">
                      <Avatar className="w-full h-full">
                        <AvatarImage src={pet.image} alt={pet.name} />
                        <AvatarFallback>{pet.name[0]}</AvatarFallback>
                      </Avatar>
                    </div>
                    <span className="text-xs font-medium text-foreground">{pet.name}</span>
                  </button>
                ))}
              </div>
            </div>

            {/* Conversations */}
            <div className="flex-1 overflow-y-auto">
              <h2 className="text-sm font-bold text-muted-foreground px-4 py-3">MESSAGES</h2>
              <div className="space-y-1 px-2">
                {conversations.map((conv, index) => (
                  <button
                    key={index}
                    onClick={() => setSelectedConvo(conv)}
                    className={`w-full flex items-center gap-3 p-3 rounded-xl transition-colors ${
                      selectedConvo.pet.id === conv.pet.id ? 'bg-muted' : 'hover:bg-muted/50'
                    }`}
                  >
                    <Avatar className="w-12 h-12 flex-shrink-0">
                      <AvatarImage src={conv.pet.image} alt={conv.pet.name} />
                      <AvatarFallback>{conv.pet.name[0]}</AvatarFallback>
                    </Avatar>
                    <div className="flex-1 text-left min-w-0">
                      <div className="flex items-center justify-between mb-1">
                        <h3 className="font-bold text-foreground">{conv.pet.name}</h3>
                        <span className="text-xs text-muted-foreground">{conv.time}</span>
                      </div>
                      <p className={`text-sm truncate ${conv.unread ? 'text-foreground font-medium' : 'text-muted-foreground'}`}>
                        {conv.lastMessage}
                      </p>
                    </div>
                    {conv.unread && (
                      <div className="w-3 h-3 rounded-full bg-primary flex-shrink-0" />
                    )}
                  </button>
                ))}
              </div>
            </div>
          </Card>

          {/* Chat Area */}
          <Card className="lg:col-span-2 flex flex-col overflow-hidden">
            {/* Chat Header */}
            <div className="flex items-center justify-between p-4 border-b border-border">
              <div className="flex items-center gap-3">
                <Avatar className="w-10 h-10">
                  <AvatarImage src={selectedConvo.pet.image} alt={selectedConvo.pet.name} />
                  <AvatarFallback>{selectedConvo.pet.name[0]}</AvatarFallback>
                </Avatar>
                <div>
                  <h3 className="font-bold text-foreground">{selectedConvo.pet.name}</h3>
                  <p className="text-xs text-muted-foreground">Active now</p>
                </div>
              </div>
              <div className="flex items-center gap-2">
                <Button variant="ghost" size="icon">
                  <Phone className="w-5 h-5" />
                </Button>
                <Button variant="ghost" size="icon">
                  <Video className="w-5 h-5" />
                </Button>
                <Button variant="ghost" size="icon">
                  <MoreVertical className="w-5 h-5" />
                </Button>
              </div>
            </div>

            {/* Messages */}
            <div className="flex-1 overflow-y-auto p-4 space-y-4">
              <div className="flex justify-start">
                <div className="max-w-[70%] bg-muted rounded-2xl rounded-bl-sm px-4 py-3">
                  <p className="text-foreground">Hey there! I love your profile! 🐾</p>
                  <span className="text-xs text-muted-foreground mt-1 block">10:30 AM</span>
                </div>
              </div>
              <div className="flex justify-end">
                <div className="max-w-[70%] gradient-coral text-primary-foreground rounded-2xl rounded-br-sm px-4 py-3">
                  <p>Thank you! Your pet is adorable too! Would love to set up a playdate.</p>
                  <span className="text-xs opacity-80 mt-1 block">10:32 AM</span>
                </div>
              </div>
              <div className="flex justify-start">
                <div className="max-w-[70%] bg-muted rounded-2xl rounded-bl-sm px-4 py-3">
                  <p className="text-foreground">{selectedConvo.lastMessage}</p>
                  <span className="text-xs text-muted-foreground mt-1 block">10:35 AM</span>
                </div>
              </div>
            </div>

            {/* Message Input */}
            <div className="p-4 border-t border-border">
              <div className="flex items-center gap-3">
                <Input 
                  placeholder="Type a message..." 
                  className="flex-1"
                />
                <Button className="rounded-full gradient-coral text-primary-foreground">
                  <Send className="w-5 h-5" />
                </Button>
              </div>
            </div>
          </Card>
        </div>
      </div>
    </Layout>
  );
};

export default Messages;
