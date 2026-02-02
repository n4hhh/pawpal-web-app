export interface CartItem {
  id: string;
  title: string;
  price: number;
  image: string;
  quantity: number;
}

const CART_KEY = 'pawpal-cart';

export function getCart(): CartItem[] {
  try {
    const raw = localStorage.getItem(CART_KEY);
    return raw ? JSON.parse(raw) : [];
  } catch {
    return [];
  }
}

function saveCart(items: CartItem[]): CartItem[] {
  localStorage.setItem(CART_KEY, JSON.stringify(items));
  return items;
}

export function addToCart(item: Omit<CartItem, 'quantity'>, qty = 1): CartItem[] {
  const current = getCart();
  const existing = current.find((it) => it.id === item.id);
  
  if (existing) {
    existing.quantity += qty;
  } else {
    current.push({ ...item, quantity: qty });
  }
  
  return saveCart(current);
}

export function updateQty(id: string, qty: number): CartItem[] {
  const current = getCart();
  
  if (qty <= 0) {
    return saveCart(current.filter((it) => it.id !== id));
  }
  
  const item = current.find((it) => it.id === id);
  if (item) {
    item.quantity = qty;
  }
  
  return saveCart(current);
}

export function clearCart(): void {
  localStorage.removeItem(CART_KEY);
}

export function cartTotal(items: CartItem[]): number {
  return items.reduce((sum, item) => sum + item.price * item.quantity, 0);
}
