import React from 'react';
import { Card } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { ShoppingBag, Star } from 'lucide-react';
import { useCart } from '@/context/CartProvider';

export default function ProductCard({ item }: { item: any }) {
  const { add } = useCart();

  return (
    <Card className="overflow-hidden group hover:shadow-lg transition-shadow">
      <div className="relative aspect-square overflow-hidden">
        <img src={(item.images && item.images[0]) || item.image} alt={item.title} className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300" />
        {item.badge && (
          <Badge className="absolute top-3 left-3 bg-primary text-primary-foreground">{item.badge}</Badge>
        )}
      </div>
      <div className="p-4">
        <h3 className="font-semibold text-foreground mb-1 group-hover:text-primary transition-colors">{item.title}</h3>
        <p className="text-sm text-muted-foreground mb-3 line-clamp-2">{item.description}</p>
        <div className="flex items-center gap-1 mb-3">
          <Star className="w-4 h-4 fill-peach text-peach" />
          <span className="text-sm font-medium text-foreground">{item.rating ?? 4.5}</span>
          <span className="text-sm text-muted-foreground">({item.reviews ?? 10} reviews)</span>
        </div>
        <div className="flex items-center justify-between">
          <span className="text-xl font-bold text-primary">${item.price}</span>
          <Button size="sm" className="rounded-full gap-2" onClick={() => add({ id: item.id, title: item.title, price: Number(item.price), image: (item.images && item.images[0]) || item.image })}>
            <ShoppingBag className="w-4 h-4" />
            Add
          </Button>
        </div>
      </div>
    </Card>
  );
}
