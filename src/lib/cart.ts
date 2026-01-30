export type CartItem = {
  id: string;
  title: string;
  price: number;
  quantity: number;
  image?: string;
};

const KEY = 'pawpal_cart_v1';

export function getCart(): CartItem[] {
  try {
    const raw = localStorage.getItem(KEY);
    return raw ? JSON.parse(raw) : [];
  } catch (err) {
    return [];
  }
}

export function saveCart(items: CartItem[]) {
  localStorage.setItem(KEY, JSON.stringify(items));
}

export function addToCart(item: Omit<CartItem, 'quantity'>, qty = 1) {
  const cart = getCart();
  const existingIdx = cart.findIndex((c) => c.id === item.id);
  let newCart: CartItem[];
  if (existingIdx >= 0) {
    newCart = cart.map((c, i) => (i === existingIdx ? { ...c, quantity: (c.quantity || 0) + qty } : c));
  } else {
    newCart = [...cart, { ...item, quantity: qty }];
  }
  saveCart(newCart);
  return newCart;
}

export function updateQty(itemId: string, qty: number) {
  const cart = getCart();
  let newCart: CartItem[];
  if (qty <= 0) {
    newCart = cart.filter((c) => c.id !== itemId);
  } else {
    newCart = cart.map((c) => (c.id === itemId ? { ...c, quantity: qty } : c));
  }
  saveCart(newCart);
  return newCart;
}

export function clearCart() {
  saveCart([]);
}

export function cartTotal(items: CartItem[]) {
  return items.reduce((s, it) => s + it.price * (it.quantity || 1), 0);
}
