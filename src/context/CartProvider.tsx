import React, { createContext, useContext, useEffect, useState } from 'react';
import { CartItem, addToCart as addToCartLS, getCart, updateQty as updateQtyLS, clearCart as clearCartLS } from '@/lib/cart';

type CartContextValue = {
  items: CartItem[];
  add: (item: Omit<CartItem, 'quantity'>, qty?: number) => void;
  update: (id: string, qty: number) => void;
  clear: () => void;
  count: number;
};

const CartContext = createContext<CartContextValue | undefined>(undefined);

export const CartProvider = ({ children }: { children: React.ReactNode }) => {
  const [items, setItems] = useState<CartItem[]>(() => getCart());

  useEffect(() => {
    const onStorage = () => setItems(getCart());
    window.addEventListener('storage', onStorage);
    return () => window.removeEventListener('storage', onStorage);
  }, []);

  const add = (item: Omit<CartItem, 'quantity'>, qty = 1) => {
    const updated = addToCartLS(item, qty);
    setItems(updated);
  };

  const update = (id: string, qty: number) => {
    const updated = updateQtyLS(id, qty);
    setItems(updated);
  };

  const clear = () => {
    clearCartLS();
    setItems([]);
  };

  const value: CartContextValue = {
    items,
    add,
    update,
    clear,
    count: items.reduce((s, it) => s + (it.quantity || 0), 0),
  };

  return <CartContext.Provider value={value}>{children}</CartContext.Provider>;
};

export function useCart() {
  const ctx = useContext(CartContext);
  if (!ctx) throw new Error('useCart must be used inside CartProvider');
  return ctx;
}
