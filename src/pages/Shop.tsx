import { Layout } from "@/components/Layout";
import { ShoppingBag, Search, Star, Filter, Grid, List } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { useMemo, useState } from "react";

import { useShop } from '@/hooks/useShop';
import ProductCard from '@/components/ProductCard';

const categories = ["All", "Food", "Toys", "Accessories", "Health", "Grooming", "Other"];

const priceRanges = [
  { label: "Any", min: null, max: null },
  { label: "Under $25", min: null, max: 25 },
  { label: "$25 - $50", min: 25, max: 50 },
  { label: "$50 - $100", min: 50, max: 100 },
  { label: "Over $100", min: 100, max: null },
];

const ratingFilters = [
  { label: "All", min: null },
  { label: "4★ & up", min: 4 },
  { label: "4.5★ & up", min: 4.5 },
];

export default function Shop() {
  const { data: items = [] } = useShop();
  const [query, setQuery] = useState("");
  const [selectedCategory, setSelectedCategory] = useState("All");
  const [selectedPrice, setSelectedPrice] = useState("Any");
  const [minRating, setMinRating] = useState<number | null>(null);

  const filteredItems = useMemo(() => {
    const lowerQuery = query.trim().toLowerCase();
    const priceRange = priceRanges.find((range) => range.label === selectedPrice) ?? priceRanges[0];

    return (items || []).filter((item) => {
      const title = (item.title || "").toLowerCase();
      const description = (item.description || "").toLowerCase();
      const category = (item.category || "Other").toLowerCase();
      const price = Number(item.price);
      const rating = Number(item.rating ?? 4.5);

      if (lowerQuery && !title.includes(lowerQuery) && !description.includes(lowerQuery)) {
        return false;
      }

      if (selectedCategory !== "All" && category !== selectedCategory.toLowerCase()) {
        return false;
      }

      if (priceRange.min !== null && price < priceRange.min) return false;
      if (priceRange.max !== null && price > priceRange.max) return false;

      if (minRating !== null && rating < minRating) return false;

      return true;
    });
  }, [items, query, selectedCategory, selectedPrice, minRating]);

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
              value={query}
              onChange={(event) => setQuery(event.target.value)}
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
                    variant={category === selectedCategory ? "default" : "ghost"}
                    className="w-full justify-start"
                    onClick={() => setSelectedCategory(category)}
                  >
                    {category}
                  </Button>
                ))}
              </div>

              <div className="mt-6 pt-6 border-t border-border">
                <h4 className="font-medium text-foreground mb-3">Price Range</h4>
                <div className="space-y-2">
                  {priceRanges.map((range) => (
                    <Button
                      key={range.label}
                      variant={range.label === selectedPrice ? "secondary" : "ghost"}
                      className="w-full justify-start"
                      onClick={() => setSelectedPrice(range.label)}
                    >
                      {range.label}
                    </Button>
                  ))}
                </div>
              </div>

              <div className="mt-6 pt-6 border-t border-border">
                <h4 className="font-medium text-foreground mb-3">Rating</h4>
                <div className="space-y-2">
                  {ratingFilters.map((rating) => (
                    <Button
                      key={rating.label}
                      variant={rating.min === minRating ? "secondary" : "ghost"}
                      className="w-full justify-start"
                      onClick={() => setMinRating(rating.min)}
                    >
                      {rating.label}
                    </Button>
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
                  variant={category === selectedCategory ? "default" : "outline"}
                  size="sm"
                  className="rounded-full whitespace-nowrap"
                  onClick={() => setSelectedCategory(category)}
                >
                  {category}
                </Button>
              ))}
            </div>

            {/* View Toggle & Results Count */}
            <div className="flex items-center justify-between mb-6">
              <p className="text-muted-foreground">{filteredItems.length} products</p>
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
              {filteredItems.map((product) => (
                <ProductCard key={product.id} item={product} />
              ))}
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
}
