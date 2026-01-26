import { Layout } from "@/components/Layout";
import { ShoppingBag, Search, Star, Filter, Grid, List } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";

import pet1 from "@/assets/pet1.jpg";
import pet2 from "@/assets/pet2.jpg";
import pet3 from "@/assets/pet3.jpg";
import pet4 from "@/assets/pet4.jpg";
import pet5 from "@/assets/pet5.jpg";

const categories = ["All", "Food", "Toys", "Accessories", "Health", "Grooming"];

const products = [
  {
    id: "1",
    name: "Premium Dog Food",
    description: "High-quality nutrition for your furry friend",
    price: 29.99,
    rating: 4.8,
    reviews: 234,
    image: pet1,
    category: "Food",
    badge: "Best Seller",
  },
  {
    id: "2",
    name: "Catnip Mouse Toy",
    description: "Interactive toy to keep your cat entertained",
    price: 9.99,
    rating: 4.5,
    reviews: 89,
    image: pet2,
    category: "Toys",
  },
  {
    id: "3",
    name: "Cozy Pet Bed",
    description: "Ultra-soft bed for maximum comfort",
    price: 49.99,
    rating: 4.9,
    reviews: 156,
    image: pet3,
    category: "Accessories",
    badge: "New",
  },
  {
    id: "4",
    name: "Pet Vitamins",
    description: "Essential vitamins for a healthy pet",
    price: 19.99,
    rating: 4.7,
    reviews: 67,
    image: pet4,
    category: "Health",
  },
  {
    id: "5",
    name: "Grooming Kit",
    description: "Complete grooming set for all pet types",
    price: 34.99,
    rating: 4.6,
    reviews: 123,
    image: pet5,
    category: "Grooming",
    badge: "Popular",
  },
  {
    id: "6",
    name: "Interactive Ball",
    description: "Smart toy that moves on its own",
    price: 24.99,
    rating: 4.4,
    reviews: 78,
    image: pet1,
    category: "Toys",
  },
];

export default function Shop() {
  return (
    <Layout>
      <div className="container mx-auto px-4 lg:px-8 py-8">
        {/* Header */}
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-8">
          <div>
            <h1 className="text-3xl font-bold text-foreground mb-2">Pet Shop</h1>
            <p className="text-muted-foreground">Everything your furry friend needs</p>
          </div>
          
          {/* Search */}
          <div className="relative w-full md:w-80">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
            <Input
              placeholder="Search products..."
              className="pl-10 bg-card border-border"
            />
          </div>
        </div>

        <div className="grid lg:grid-cols-4 gap-8">
          {/* Sidebar Filters */}
          <aside className="hidden lg:block">
            <Card className="p-5 sticky top-24">
              <div className="flex items-center gap-2 mb-4">
                <Filter className="w-5 h-5 text-primary" />
                <h3 className="font-bold text-foreground">Categories</h3>
              </div>
              <div className="space-y-2">
                {categories.map((category) => (
                  <Button
                    key={category}
                    variant={category === "All" ? "default" : "ghost"}
                    className="w-full justify-start"
                  >
                    {category}
                  </Button>
                ))}
              </div>

              <div className="mt-6 pt-6 border-t border-border">
                <h4 className="font-medium text-foreground mb-3">Price Range</h4>
                <div className="space-y-2">
                  {["Under $25", "$25 - $50", "$50 - $100", "Over $100"].map((range) => (
                    <label key={range} className="flex items-center gap-2 cursor-pointer">
                      <input type="checkbox" className="rounded border-border" />
                      <span className="text-sm text-muted-foreground">{range}</span>
                    </label>
                  ))}
                </div>
              </div>
            </Card>
          </aside>

          {/* Products Grid */}
          <div className="lg:col-span-3">
            {/* Mobile Categories */}
            <div className="flex gap-2 overflow-x-auto pb-4 scrollbar-hide lg:hidden">
              {categories.map((category, index) => (
                <Button
                  key={category}
                  variant={index === 0 ? "default" : "outline"}
                  size="sm"
                  className="rounded-full whitespace-nowrap"
                >
                  {category}
                </Button>
              ))}
            </div>

            {/* View Toggle & Results Count */}
            <div className="flex items-center justify-between mb-6">
              <p className="text-muted-foreground">{products.length} products</p>
              <div className="flex items-center gap-2">
                <Button variant="ghost" size="icon">
                  <Grid className="w-4 h-4" />
                </Button>
                <Button variant="ghost" size="icon">
                  <List className="w-4 h-4" />
                </Button>
              </div>
            </div>

            {/* Products */}
            <div className="grid sm:grid-cols-2 xl:grid-cols-3 gap-6">
              {products.map((product) => (
                <Card
                  key={product.id}
                  className="overflow-hidden group hover:shadow-lg transition-shadow cursor-pointer"
                >
                  <div className="relative aspect-square overflow-hidden">
                    <img
                      src={product.image}
                      alt={product.name}
                      className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                    />
                    {product.badge && (
                      <Badge className="absolute top-3 left-3 bg-primary text-primary-foreground">
                        {product.badge}
                      </Badge>
                    )}
                  </div>
                  <div className="p-4">
                    <h3 className="font-semibold text-foreground mb-1 group-hover:text-primary transition-colors">
                      {product.name}
                    </h3>
                    <p className="text-sm text-muted-foreground mb-3 line-clamp-2">
                      {product.description}
                    </p>
                    <div className="flex items-center gap-1 mb-3">
                      <Star className="w-4 h-4 fill-peach text-peach" />
                      <span className="text-sm font-medium text-foreground">
                        {product.rating}
                      </span>
                      <span className="text-sm text-muted-foreground">
                        ({product.reviews} reviews)
                      </span>
                    </div>
                    <div className="flex items-center justify-between">
                      <span className="text-xl font-bold text-primary">${product.price}</span>
                      <Button size="sm" className="rounded-full gap-2">
                        <ShoppingBag className="w-4 h-4" />
                        Add
                      </Button>
                    </div>
                  </div>
                </Card>
              ))}
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
}
