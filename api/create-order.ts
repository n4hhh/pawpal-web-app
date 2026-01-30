import { VercelRequest, VercelResponse } from '@vercel/node';
import { createClient } from '@supabase/supabase-js';

// Vercel serverless function: POST /api/create-order
// Uses SUPABASE_SERVICE_ROLE_KEY to perform privileged inserts (orders + order_items)

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

export default async function handler(req: VercelRequest, res: VercelResponse) {
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method Not Allowed' });
  if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
    return res.status(500).json({ error: 'Missing Supabase server env vars' });
  }

  try {
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
    const body = req.body || {};
    const items = body.items || [];
    const profileId = body.profileId || null; // ideally validate via auth

    if (!profileId) {
      return res.status(400).json({ error: 'missing profileId' });
    }

    const total = items.reduce((s: number, it: any) => s + Number(it.price) * Number(it.quantity || 1), 0);

    const { data: orderData, error: orderErr } = await supabase.from('orders').insert([{ profile_id: profileId, total }]).select().single();
    if (orderErr) throw orderErr;

    const orderId = orderData.id;
    const orderItems = items.map((it: any) => ({ order_id: orderId, item_id: it.id, quantity: it.quantity || 1, price: Number(it.price) }));

    const { error: oiErr } = await supabase.from('order_items').insert(orderItems);
    if (oiErr) throw oiErr;

    return res.status(200).json({ ok: true, orderId });
  } catch (err: any) {
    console.error('create-order error', err);
    return res.status(500).json({ error: err.message || String(err) });
  }
}
