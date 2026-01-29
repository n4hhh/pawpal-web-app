import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '@/hooks/useAuth';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Loader2 } from 'lucide-react';

export default function Login() {
  const navigate = useNavigate();
  const { signInWithEmail, signInWithProvider } = useAuth();
  
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [oauthLoading, setOauthLoading] = useState<'google' | 'facebook' | null>(null);

  async function handleEmailSignIn(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setSuccess(null);
    setLoading(true);

    try {
      const { error: authError } = await signInWithEmail(email, password);
      if (authError) {
        setError(authError.message);
      } else {
        setSuccess('Đăng nhập thành công!');
        setTimeout(() => navigate('/'), 2000);
      }
    } catch (err) {
      const error = err as Error;
      setError(error?.message ?? 'Đã xảy ra lỗi');
    } finally {
      setLoading(false);
    }
  }

  async function handleOAuthSignIn(provider: 'google' | 'facebook') {
    setError(null);
    setOauthLoading(provider);

    try {
      const { error: authError } = await signInWithProvider(provider);
      if (authError) {
        setError(authError.message);
      }
    } catch (err) {
      const error = err as Error;
      setError(error?.message ?? 'Đã xảy ra lỗi');
    } finally {
      setOauthLoading(null);
    }
  }

  return (
    <div className="min-h-screen bg-gradient-to-b from-blue-50 to-white flex items-center justify-center px-4">
      <div className="max-w-md w-full">
        <Card className="p-8 shadow-lg">
          <div className="text-center mb-8">
            <h1 className="text-3xl font-bold text-gray-900">Đăng Nhập</h1>
            <p className="text-gray-600 mt-2">Chào mừng trở lại PawPal</p>
          </div>

          {error && (
            <Alert variant="destructive" className="mb-4">
              <AlertDescription>{error}</AlertDescription>
            </Alert>
          )}

          {success && (
            <Alert className="mb-4 bg-green-50 border-green-200">
              <AlertDescription className="text-green-800">{success}</AlertDescription>
            </Alert>
          )}

          <form onSubmit={handleEmailSignIn} className="space-y-4 mb-6">
            <div className="space-y-2">
              <Label htmlFor="email">Email</Label>
              <Input
                id="email"
                type="email"
                placeholder="you@example.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                disabled={loading}
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="password">Mật Khẩu</Label>
              <Input
                id="password"
                type="password"
                placeholder="••••••••"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                disabled={loading}
              />
            </div>

            <Button
              type="submit"
              className="w-full"
              disabled={loading}
            >
              {loading ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Đang đăng nhập...
                </>
              ) : (
                'Đăng Nhập'
              )}
            </Button>
          </form>

          <div className="relative mb-6">
            <div className="absolute inset-0 flex items-center">
              <div className="w-full border-t border-gray-300" />
            </div>
            <div className="relative flex justify-center text-sm">
              <span className="px-2 bg-white text-gray-500">hoặc</span>
            </div>
          </div>

          <div className="space-y-3 mb-6">
            <Button
              type="button"
              variant="outline"
              className="w-full"
              onClick={() => handleOAuthSignIn('google')}
              disabled={oauthLoading !== null}
            >
              {oauthLoading === 'google' ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Đang kết nối...
                </>
              ) : (
                <>
                  <svg className="mr-2 h-4 w-4" viewBox="0 0 24 24">
                    <path
                      fill="currentColor"
                      d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
                    />
                    <path
                      fill="currentColor"
                      d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
                    />
                    <path
                      fill="currentColor"
                      d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
                    />
                    <path
                      fill="currentColor"
                      d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
                    />
                  </svg>
                  Đăng nhập với Google
                </>
              )}
            </Button>

            <Button
              type="button"
              variant="outline"
              className="w-full"
              onClick={() => handleOAuthSignIn('facebook')}
              disabled={oauthLoading !== null}
            >
              {oauthLoading === 'facebook' ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Đang kết nối...
                </>
              ) : (
                <>
                  <svg className="mr-2 h-4 w-4" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z" />
                  </svg>
                  Đăng nhập với Facebook
                </>
              )}
            </Button>
          </div>

          <div className="text-center">
            <p className="text-gray-600">
              Chưa có tài khoản?{' '}
              <button
                onClick={() => navigate('/signup')}
                className="text-blue-600 hover:text-blue-800 font-semibold transition-colors"
              >
                Đăng ký ngay
              </button>
            </p>
          </div>
        </Card>
      </div>
    </div>
  );
}
