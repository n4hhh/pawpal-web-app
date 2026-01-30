import { VercelRequest, VercelResponse } from '@vercel/node';
import { createClient } from '@supabase/supabase-js';

// Vercel serverless function: POST /api/create-product
// Body: { title, description, price, images?: string[], stock?: number, category?: string, rating?: number, reviews_count?: number }
// Requires SUPABASE_SERVICE_ROLE_KEY in server env.

export default async function handler(req: VercelRequest, res: VercelResponse) {
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method Not Allowed' });
  const SUPABASE_URL = process.env.SUPABASE_URL;
  const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
    console.error('create-product: missing server env vars');
    return res.status(500).json({ error: 'Missing Supabase server env vars' });
  }

  try {
    const body = req.body || {};
    const { title, description = '', price, images = [], stock = 0, category, rating, reviews_count } = body;

    const numericPrice = Number(price);
    const numericStock = Number(stock);
    const numericRating = Number(rating);
    const numericReviews = Number(reviews_count);
    const safeImages = Array.isArray(images) ? images.filter(Boolean).map(String) : [];
    const safeCategory = typeof category === 'string' && category.trim() ? category.trim() : null;

    if (!title || Number.isNaN(numericPrice)) {
      return res.status(400).json({ error: 'title and price are required' });
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
    const payload = [
      {
        title,
        description,
        price: numericPrice,
        images: safeImages,
        category: safeCategory,
        rating: Number.isNaN(numericRating) ? undefined : numericRating,
        reviews_count: Number.isNaN(numericReviews) ? undefined : numericReviews,
        stock: Number.isNaN(numericStock) ? 0 : numericStock,
      },
    ];
    const { data, error } = await supabase.from('shop_items').insert(payload).select().single();
    if (error) {
      console.error('supabase insert error:', error);
      throw error;
    }

    return res.status(200).json({ ok: true, item: data });
  } catch (err: any) {
    console.error('create-product error', err);
    return res.status(500).json({ error: err.message || String(err) });
  }
}
