import React from 'react';
import { Sheet, SheetContent, SheetTrigger } from '@/components/ui/sheet';
import { Button } from '@/components/ui/button';
import { X, ShoppingBag, Trash } from 'lucide-react';
import { useCart } from '@/context/CartProvider';
import { cartTotal } from '@/lib/cart';
import { useAuth } from '@/hooks/useAuth';

export default function CartDrawer() {
  const [open, setOpen] = React.useState(false);
  const { items, update, clear, count } = useCart();
  const { user } = useAuth();

  const handleCheckout = async () => {
    if (!user) {
      alert('Please sign in to checkout');
      return;
    }
    try {
      // call serverless endpoint to create order
      const res = await fetch('/api/create-order', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ items, profileId: user?.id }),
      });
      const data = await res.json();
      if (res.ok) {
        alert('Order created: ' + data.orderId);
        clear();
        setOpen(false);
      } else {
        console.error(data);
        alert('Failed to create order');
      }
    } catch (err) {
      console.error(err);
      alert('Checkout failed');
    }
  };

  return (
    <Sheet open={open} onOpenChange={setOpen}>
      <SheetTrigger asChild>
        <Button variant="ghost" size="icon">
          <ShoppingBag className="w-5 h-5" />
          {count > 0 && <span className="absolute -top-1 -right-1 inline-flex items-center justify-center px-2 py-1 text-xs font-bold leading-none text-white bg-red-600 rounded-full">{count}</span>}
        </Button>
      </SheetTrigger>
      <SheetContent side="right" className="w-96">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-bold">Your Cart</h3>
          <Button variant="ghost" size="icon" onClick={() => setOpen(false)}>
            <X className="w-4 h-4" />
          </Button>
        </div>

        <div className="space-y-3 overflow-y-auto max-h-[60vh] mb-4">
          {items.length === 0 && <p className="text-muted-foreground">Your cart is empty</p>}
          {items.map((it) => (
            <div key={it.id} className="flex items-center gap-3 p-2 border rounded">
              <img src={it.image} alt={it.title} className="w-16 h-16 object-cover rounded" />
              <div className="flex-1">
                <div className="flex items-center justify-between">
                  <div>
                    <div className="font-semibold">{it.title}</div>
                    <div className="text-sm text-muted-foreground">${it.price}</div>
                  </div>
                  <div className="flex items-center gap-2">
                    <input type="number" className="w-16 border rounded p-1 text-sm" value={it.quantity} onChange={(e) => update(it.id, Number(e.target.value))} />
                    <Button variant="ghost" size="icon" onClick={() => update(it.id, 0)}>
                      <Trash className="w-4 h-4" />
                    </Button>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>

        <div className="mt-auto">
          <div className="flex items-center justify-between mb-4">
            <span className="font-bold">Total</span>
            <span className="font-bold">${cartTotal(items).toFixed(2)}</span>
          </div>
          <Button className="w-full rounded-full" onClick={handleCheckout}>
            Checkout
          </Button>
        </div>
      </SheetContent>
    </Sheet>
  );
}
