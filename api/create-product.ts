import { VercelRequest, VercelResponse } from '@vercel/node';
import { createClient } from '@supabase/supabase-js';

// Vercel serverless function: POST /api/create-product
// Body: { title, description, price, images?: string[], stock?: number }
// Requires SUPABASE_SERVICE_ROLE_KEY in server env.

export default async function handler(req: VercelRequest, res: VercelResponse) {
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method Not Allowed' });
  const SUPABASE_URL = process.env.SUPABASE_URL || process.env.VITE_SUPABASE_URL;
  const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
  console.log('create-product handler invoked');
  console.log('env keys:', Object.keys(process.env).filter((key) => key.startsWith('SUPABASE_')));
  console.log('env present:', { hasUrl: !!SUPABASE_URL, hasServiceRole: !!SUPABASE_SERVICE_ROLE_KEY });
  if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
    console.error('create-product: missing server env vars');
    return res.status(500).json({ error: 'Missing Supabase server env vars' });
  }

  try {
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
    const body = req.body || {};
    console.log('create-product body:', body);
    const { title, description = '', price = 0, images = [], stock = 0 } = body;

    if (!title || !price) return res.status(400).json({ error: 'title and price are required' });

    const payload = [{ title, description, price: Number(price), images, stock: Number(stock) }];
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
