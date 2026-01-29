import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '@/hooks/useAuth';
import { supabase } from '@/lib/supabase';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Loader2 } from 'lucide-react';

export default function SignUp() {
  const navigate = useNavigate();
  const { signUpWithEmail } = useAuth();

  const [formData, setFormData] = useState({
    email: '',
    password: '',
    confirmPassword: '',
    username: '',
    displayName: '',
    bio: '',
    avatar: null as File | null,
  });

  const [previewAvatar, setPreviewAvatar] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  function handleInputChange(e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }));
  }

  function handleAvatarChange(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (file) {
      setFormData((prev) => ({
        ...prev,
        avatar: file,
      }));

      // Create preview
      const reader = new FileReader();
      reader.onloadend = () => {
        setPreviewAvatar(reader.result as string);
      };
      reader.readAsDataURL(file);
    }
  }

  async function uploadAvatar(userId: string, file: File): Promise<string | null> {
    if (!file) return null;

    const timestamp = Date.now();
    const filename = `${userId}/${timestamp}`;

    const { data, error } = await supabase.storage
      .from('avatars')
      .upload(filename, file, {
        cacheControl: '3600',
        upsert: false,
      });

    if (error) {
      console.error('Avatar upload error:', error);
      return null;
    }

    const { data: urlData } = supabase.storage
      .from('avatars')
      .getPublicUrl(data.path);

    return urlData?.publicUrl || null;
  }

  async function handleSignUp(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setSuccess(null);

    // Validation
    if (!formData.email || !formData.password || !formData.username || !formData.displayName) {
      setError('Vui lòng điền tất cả các trường bắt buộc');
      return;
    }

    if (formData.password !== formData.confirmPassword) {
      setError('Mật khẩu xác nhận không khớp');
      return;
    }

    if (formData.password.length < 6) {
      setError('Mật khẩu phải có ít nhất 6 ký tự');
      return;
    }

    setLoading(true);

    try {
      // Sign up with email and password
      console.log('Starting sign up process...');
      const { data: authData, error: authError } = await signUpWithEmail(
        formData.email,
        formData.password
      );

      if (authError) {
        console.error('Auth error:', authError);
        setError(`Lỗi xác thực: ${authError.message}`);
        setLoading(false);
        return;
      }

      const userId = authData?.user?.id;
      if (!userId) {
        console.error('No user ID returned');
        setError('Không thể tạo tài khoản');
        setLoading(false);
        return;
      }

      console.log('User created:', userId);

      // Upload avatar if exists
      let avatarUrl = null;
      if (formData.avatar) {
        console.log('Uploading avatar...');
        avatarUrl = await uploadAvatar(userId, formData.avatar);
        console.log('Avatar URL:', avatarUrl);
      }

      // Create user profile
      console.log('Creating user profile...');
      const { data: profileData, error: profileError } = await supabase
        .from('users')
        .insert([
          {
            id: userId,
            email: formData.email,
            username: formData.username,
            display_name: formData.displayName,
            bio: formData.bio || null,
            avatar: avatarUrl || null,
          },
        ])
        .select();

      if (profileError) {
        console.error('Profile creation error:', profileError);
        setError(`Lỗi tạo hồ sơ: ${profileError.message}`);
        setLoading(false);
        return;
      }

      console.log('Profile created:', profileData);
      
      // Check if email confirmation is required
      const { data: { user: signUpUser } } = await supabase.auth.getUser();
      const isEmailConfirmationRequired = !signUpUser?.email_confirmed_at;
      
      if (isEmailConfirmationRequired) {
        setSuccess(
          '✅ Đăng ký thành công!\n\n' +
          '📧 Vui lòng kiểm tra email để xác nhận tài khoản.\n' +
          'Sau khi xác nhận, bạn có thể đăng nhập.\n\n' +
          'Nếu không tìm thấy email, kiểm tra thư mục Spam.\n' +
          '(Chuyển đến trang login trong 5 giây...)'
        );
        setTimeout(() => navigate('/login'), 5000);
      } else {
        setSuccess(
          '✅ Đăng ký thành công!\n' +
          'Bạn có thể đăng nhập ngay bây giờ.\n' +
          '(Chuyển đến trang login trong 3 giây...)'
        );
        setTimeout(() => navigate('/login'), 3000);
      }
    } catch (err) {
      const error = err as Error;
      console.error('Unexpected error:', error);
      setError(`Lỗi: ${error?.message ?? 'Đã xảy ra lỗi không xác định'}`);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="min-h-screen bg-gradient-to-b from-blue-50 to-white flex items-center justify-center px-4 py-8">
      <div className="max-w-2xl w-full">
        <Card className="p-8 shadow-lg">
          <div className="text-center mb-8">
            <h1 className="text-3xl font-bold text-gray-900">Đăng Ký</h1>
            <p className="text-gray-600 mt-2">Tạo tài khoản PawPal của bạn</p>
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

          <form onSubmit={handleSignUp} className="space-y-6">
            {/* Email and Password Section */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="email">Email *</Label>
                <Input
                  id="email"
                  type="email"
                  name="email"
                  placeholder="you@example.com"
                  value={formData.email}
                  onChange={handleInputChange}
                  required
                  disabled={loading}
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="username">Tên Đăng Nhập *</Label>
                <Input
                  id="username"
                  type="text"
                  name="username"
                  placeholder="username"
                  value={formData.username}
                  onChange={handleInputChange}
                  required
                  disabled={loading}
                />
              </div>
            </div>

            {/* Password Section */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="password">Mật Khẩu *</Label>
                <Input
                  id="password"
                  type="password"
                  name="password"
                  placeholder="••••••••"
                  value={formData.password}
                  onChange={handleInputChange}
                  required
                  disabled={loading}
                />
                <p className="text-xs text-gray-500">Tối thiểu 6 ký tự</p>
              </div>

              <div className="space-y-2">
                <Label htmlFor="confirmPassword">Xác Nhận Mật Khẩu *</Label>
                <Input
                  id="confirmPassword"
                  type="password"
                  name="confirmPassword"
                  placeholder="••••••••"
                  value={formData.confirmPassword}
                  onChange={handleInputChange}
                  required
                  disabled={loading}
                />
              </div>
            </div>

            {/* Display Name */}
            <div className="space-y-2">
              <Label htmlFor="displayName">Tên Hiển Thị *</Label>
              <Input
                id="displayName"
                type="text"
                name="displayName"
                placeholder="Ví dụ: Minh Nguyễn"
                value={formData.displayName}
                onChange={handleInputChange}
                required
                disabled={loading}
              />
            </div>

            {/* Bio */}
            <div className="space-y-2">
              <Label htmlFor="bio">Tiểu Sử</Label>
              <Textarea
                id="bio"
                name="bio"
                placeholder="Giới thiệu một chút về bạn..."
                value={formData.bio}
                onChange={handleInputChange}
                disabled={loading}
                rows={3}
              />
            </div>

            {/* Avatar Upload */}
            <div className="space-y-2">
              <Label htmlFor="avatar">Ảnh Đại Diện</Label>
              <div className="flex items-start gap-4">
                <div className="flex-1">
                  <Input
                    id="avatar"
                    type="file"
                    accept="image/*"
                    onChange={handleAvatarChange}
                    disabled={loading}
                  />
                  <p className="text-xs text-gray-500 mt-1">Chỉ hỗ trợ hình ảnh (PNG, JPG, GIF)</p>
                </div>
              </div>

              {previewAvatar && (
                <div className="mt-4">
                  <p className="text-sm font-medium mb-2">Xem trước:</p>
                  <img
                    src={previewAvatar}
                    alt="Avatar preview"
                    className="h-24 w-24 rounded-full object-cover border-2 border-gray-200"
                  />
                </div>
              )}
            </div>

            {/* Submit Button */}
            <Button
              type="submit"
              className="w-full"
              disabled={loading}
            >
              {loading ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Đang đăng ký...
                </>
              ) : (
                'Đăng Ký'
              )}
            </Button>
          </form>

          <div className="text-center mt-6">
            <p className="text-gray-600">
              Đã có tài khoản?{' '}
              <button
                onClick={() => navigate('/login')}
                className="text-blue-600 hover:text-blue-800 font-semibold transition-colors"
              >
                Đăng nhập
              </button>
            </p>
          </div>
        </Card>
      </div>
    </div>
  );
}
