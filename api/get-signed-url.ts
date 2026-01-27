import { VercelRequest, VercelResponse } from '@vercel/node';
import { createClient } from '@supabase/supabase-js';

// Vercel serverless function: GET /api/get-signed-url?path=folder/file.jpg
export default async function handler(req: VercelRequest, res: VercelResponse) {
  const path = (req.query.path as string) || '';
  if (!path) return res.status(400).json({ error: 'path query param required' });

  const SUPABASE_URL = process.env.SUPABASE_URL;
  const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
    return res.status(500).json({ error: 'Missing Supabase server env vars' });
  }

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

  try {
    const { data, error } = await supabase.storage.from('pets').createSignedUrl(path, 60);
    if (error) return res.status(500).json({ error });
    return res.json({ url: data?.signedUrl });
  } catch (err) {
    return res.status(500).json({ error: String(err) });
  }
}
