import { Layout } from "@/components/Layout";
import { ShoppingBag, Search, Star, Filter, Grid, List } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";

import { useShop } from '@/hooks/useShop';
import ProductCard from '@/components/ProductCard';

const categories = ["All", "Food", "Toys", "Accessories", "Health", "Grooming"];

export default function Shop() {
  const { data: items = [] } = useShop();

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
              <p className="text-muted-foreground">{items.length} products</p>
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
              {(items || []).map((product) => (
                <ProductCard key={product.id} item={product} />
              ))}
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
}
