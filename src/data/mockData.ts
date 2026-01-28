import pet1 from "@/assets/pet1.jpg";
import pet2 from "@/assets/pet2.jpg";
import pet3 from "@/assets/pet3.jpg";
import pet4 from "@/assets/pet4.jpg";
import pet5 from "@/assets/pet5.jpg";

export interface Pet {
  id: string;
  name: string;
  age: string;
  breed: string;
  location: string;
  image: string;
  bio: string;
  owner: string;
}

export const mockPets: Pet[] = [
  {
    id: "1",
    name: "Max",
    age: "2 yrs",
    breed: "Golden Retriever",
    location: "2 miles away",
    image: pet1,
    bio: "I love long walks in the park and belly rubs! Looking for a furry friend to play fetch with. 🎾",
    owner: "sarah_pawsome",
  },
  {
    id: "2",
    name: "Whiskers",
    age: "1 yr",
    breed: "Orange Tabby",
    location: "5 miles away",
    image: pet2,
    bio: "Professional napper and treat connoisseur. Seeking a cuddle buddy for lazy Sundays. 😸",
    owner: "cat_dad_mike",
  },
  {
    id: "3",
    name: "Bruno",
    age: "8 mo",
    breed: "French Bulldog",
    location: "1 mile away",
    image: pet3,
    bio: "Snort expert and zoomies champion! Want to be my partner in crime? 🐾",
    owner: "frenchie_lover",
  },
  {
    id: "4",
    name: "Luna",
    age: "3 yrs",
    breed: "Persian Cat",
    location: "3 miles away",
    image: pet4,
    bio: "Elegant lady seeking sophisticated playdates. Tea parties preferred. 👑",
    owner: "luna_queen",
  },
  {
    id: "5",
    name: "Cooper",
    age: "6 mo",
    breed: "Beagle",
    location: "4 miles away",
    image: pet5,
    bio: "Adventure seeker with a nose for fun! Let's sniff out new trails together! 🌲",
    owner: "beagle_adventures",
  },
];

export const feedPosts = [
  {
    id: "mock-1",
    petName: "Max",
    ownerName: "sarah_pawsome",
    avatar: pet1,
    image: pet1,
    caption: "Living my best life at the beach today! 🏖️ Who else loves the water?",
    likes: 234,
    comments: 18,
    timeAgo: "2 hours ago",
  },
  {
    id: "mock-2",
    petName: "Whiskers",
    ownerName: "cat_dad_mike",
    avatar: pet2,
    image: pet2,
    caption: "Caught me in my best pose. Yes, I woke up like this 💅",
    likes: 567,
    comments: 42,
    timeAgo: "5 hours ago",
  },
  {
    id: "mock-3",
    petName: "Bruno",
    ownerName: "frenchie_lover",
    avatar: pet3,
    image: pet3,
    caption: "Did someone say treats?! 👀🍖",
    likes: 891,
    comments: 56,
    timeAgo: "8 hours ago",
  },
];
