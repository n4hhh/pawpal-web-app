import { useState } from 'react';
import { useAuth } from '@/hooks/useAuth';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';

export default function Auth() {
  const { user, loading, signInWithEmail, signUpWithEmail, signOut, signInWithProvider } = useAuth() as any;
  const [mode, setMode] = useState<'signin' | 'signup'>('signin');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [message, setMessage] = useState<string | null>(null);

  async function submit(e: React.FormEvent) {
    e.preventDefault();
    setMessage(null);
    try {
      if (mode === 'signin') {
        const res = await signInWithEmail(email, password);
        if (res.error) setMessage(res.error.message);
        else setMessage('Signed in');
      } else {
        const res = await signUpWithEmail(email, password);
        if (res.error) setMessage(res.error.message);
        else setMessage('Check your email for confirmation (if enabled)');
      }
    } catch (err: any) {
      setMessage(err?.message ?? String(err));
    }
  }

  return (
    <div className="container mx-auto px-4 lg:px-8 py-8">
      <div className="max-w-md mx-auto">
        <Card className="p-6">
          <h2 className="text-xl font-bold mb-4">{mode === 'signin' ? 'Sign In' : 'Sign Up'}</h2>
          <form onSubmit={submit} className="space-y-3">
            <input
              className="w-full p-2 border rounded"
              placeholder="Email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              type="email"
              required
            />
            <input
              className="w-full p-2 border rounded"
              placeholder="Password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              type="password"
              required
            />
            <div className="flex gap-2">
              <Button type="submit">{mode === 'signin' ? 'Sign In' : 'Create Account'}</Button>
              <Button variant="ghost" onClick={() => setMode(mode === 'signin' ? 'signup' : 'signin')}>
                {mode === 'signin' ? 'Go to Sign Up' : 'Go to Sign In'}
              </Button>
            </div>
          </form>
          <div className="mt-3 flex gap-2">
            <Button variant="outline" onClick={() => signInWithProvider('google')}>Sign in with Google</Button>
            <Button variant="outline" onClick={() => signInWithProvider('facebook')}>Sign in with Facebook</Button>
          </div>
          {message && <p className="mt-3 text-sm text-red-500">{message}</p>}
          <div className="mt-4">
            {loading ? (
              <p>Loading...</p>
            ) : user ? (
              <div>
                <p>Signed in as {user.email ?? user.id}</p>
                <Button variant="ghost" onClick={() => signOut()}>Sign out</Button>
              </div>
            ) : null}
          </div>
        </Card>
      </div>
    </div>
  );
}
