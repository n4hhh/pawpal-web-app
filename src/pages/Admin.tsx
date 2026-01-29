import { useState } from 'react';
import { Layout } from '@/components/Layout';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { Textarea } from '@/components/ui/textarea';
import { useAuth } from '@/hooks/useAuth';

export default function Admin() {
  const { user } = useAuth();
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [price, setPrice] = useState('0');
  const [images, setImages] = useState('');
  const [stock, setStock] = useState('0');
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState<string | null>(null);

  const devAdminId = import.meta.env.VITE_DEV_ADMIN_ID || '';
  const isAdmin = user?.id && devAdminId && user.id === devAdminId;

  async function handleSubmit(e: any) {
    e.preventDefault();
    if (!isAdmin) return setMessage('Not authorized');
    setLoading(true);
    setMessage(null);
    try {
      const payload = {
        title,
        description,
        price: Number(price),
        images: images ? images.split(',').map((s) => s.trim()) : [],
        stock: Number(stock),
      };
      const res = await fetch('/api/create-product', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });

      let data: any = null;
      const contentType = res.headers.get('content-type') || '';
      if (contentType.includes('application/json')) {
        try {
          data = await res.json();
        } catch (err) {
          data = { error: 'Invalid JSON response' };
        }
      } else {
        const text = await res.text();
        data = { error: text || res.statusText };
      }

      if (res.ok) {
        setMessage('Product created');
        setTitle('');
        setDescription('');
        setPrice('0');
        setImages('');
        setStock('0');
      } else {
        setMessage(data?.error || 'Failed');
      }
    } catch (err: any) {
      setMessage(String(err));
    } finally {
      setLoading(false);
    }
  }

  if (!isAdmin) {
    return (
      <Layout>
        <div className="container mx-auto p-8">
          <h2 className="text-xl font-bold">Admin</h2>
          <p className="text-muted-foreground">You are not authorized to access this page.</p>
        </div>
      </Layout>
    );
  }

  return (
    <Layout>
      <div className="container mx-auto p-8">
        <h2 className="text-2xl font-bold mb-4">Admin — Create Product</h2>
        <form onSubmit={handleSubmit} className="space-y-4 max-w-lg">
          <div>
            <label className="block text-sm font-medium mb-1">Title</label>
            <Input value={title} onChange={(e) => setTitle(e.target.value)} required />
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">Description</label>
            <Textarea value={description} onChange={(e) => setDescription(e.target.value)} />
          </div>
          <div className="grid grid-cols-3 gap-2">
            <div>
              <label className="block text-sm font-medium mb-1">Price</label>
              <Input value={price} onChange={(e) => setPrice(e.target.value)} required />
            </div>
            <div>
              <label className="block text-sm font-medium mb-1">Stock</label>
              <Input value={stock} onChange={(e) => setStock(e.target.value)} required />
            </div>
            <div>
              <label className="block text-sm font-medium mb-1">Images (comma separated URLs)</label>
              <Input value={images} onChange={(e) => setImages(e.target.value)} />
            </div>
          </div>
          <div>
            <Button type="submit" disabled={loading}>{loading ? 'Creating...' : 'Create Product'}</Button>
          </div>
          {message && <div className="text-sm text-muted-foreground">{message}</div>}
        </form>
      </div>
    </Layout>
  );
}
