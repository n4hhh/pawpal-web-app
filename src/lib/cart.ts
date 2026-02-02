// Shopping cart utilities using localStorage

export interface CartItem {
  id: string;
  title: string;
  price: number;
  quantity: number;
  image?: string;
}

const CART_KEY = 'pawpal_cart';

export function getCart(): CartItem[] {
  try {
    const cart = localStorage.getItem(CART_KEY);
    return cart ? JSON.parse(cart) : [];
  } catch (error) {
    console.error('Error reading cart:', error);
    return [];
  }
}

export function saveCart(cart: CartItem[]): void {
  try {
    localStorage.setItem(CART_KEY, JSON.stringify(cart));
  } catch (error) {
    console.error('Error saving cart:', error);
  }
}

export function addToCart(item: Omit<CartItem, 'quantity'>, quantity = 1): void {
  const cart = getCart();
  const existingItem = cart.find((i) => i.id === item.id);

  if (existingItem) {
    existingItem.quantity += quantity;
  } else {
    cart.push({ ...item, quantity });
  }

  saveCart(cart);
}

export function updateQty(itemId: string, quantity: number): void {
  const cart = getCart();
  const item = cart.find((i) => i.id === itemId);

  if (item) {
    if (quantity <= 0) {
      removeFromCart(itemId);
    } else {
      item.quantity = quantity;
      saveCart(cart);
    }
  }
}

export function removeFromCart(itemId: string): void {
  const cart = getCart().filter((i) => i.id !== itemId);
  saveCart(cart);
}

export function clearCart(): void {
  localStorage.removeItem(CART_KEY);
}

export function cartTotal(items: CartItem[]): number {
  return items.reduce((total, item) => total + item.price * item.quantity, 0);
}

export function getCartItemCount(): number {
  return getCart().reduce((count, item) => count + item.quantity, 0);
}
