# Cấu Hình Xác Thực (Authentication Setup)

## 1. Tạo file .env.local

Tạo file `.env.local` ở thư mục gốc của dự án với nội dung sau:

```
VITE_SUPABASE_URL=your_supabase_url_here
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key_here
```

## 2. Lấy Supabase Credentials

1. Truy cập [supabase.com](https://supabase.com)
2. Tạo một dự án mới hoặc sử dụng dự án hiện tại
3. Vào Project Settings → API
4. Copy `Project URL` và `anon public key`
5. Dán vào file `.env.local`

## 3. Cấu Hình Google OAuth (Tùy chọn nhưng được khuyến khích)

Để sử dụng tính năng đăng nhập bằng Google:

### Tạo Google OAuth App
1. Truy cập [Google Cloud Console](https://console.cloud.google.com)
2. Tạo dự án mới hoặc chọn dự án hiện tại
3. Vào APIs & Services → Credentials
4. Click "Create Credentials" → OAuth 2.0 Client ID
5. Chọn "Web application"
6. Thêm Authorized redirect URIs:
   - `http://localhost:5173` (cho dev)
   - `https://yourdomain.com` (cho production)
   - `https://yourdomain.com/auth/callback` (callback từ Supabase)
7. Copy Client ID và Client Secret

### Cấu Hình Trong Supabase
1. Vào Project Settings → Authentication → Providers
2. Tìm Google và bật nó
3. Nhập Google Client ID và Client Secret
4. Lưu thay đổi

## 4. Cấu Hình Database (Nếu cần lưu profile người dùng)

Tạo bảng `profiles` trong Supabase để lưu thông tin người dùng:

```sql
CREATE TABLE profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT,
  phone_number TEXT,
  age INTEGER,
  bio TEXT,
  favorite_breed TEXT,
  avatar_url TEXT,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
  
  CONSTRAINT profiles_pkey PRIMARY KEY (id)
);

-- Tạo RLS policy
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);
```

## 5. Sử Dụng useAuth Hook

```tsx
import { useAuth } from '@/context/AuthContext';

const MyComponent = () => {
  const { user, loading, signOut } = useAuth();

  if (loading) return <div>Đang tải...</div>;
  
  if (!user) return <div>Vui lòng đăng nhập</div>;

  return (
    <div>
      <p>Xin chào, {user.email}</p>
      <button onClick={signOut}>Đăng Xuất</button>
    </div>
  );
};
```

## 6. Tính Năng Đã Được Thêm

✅ Trang Đăng Nhập (`/login`)
  - Đăng nhập bằng email/password
  - Đăng nhập bằng Google
  - Link đến trang đăng ký

✅ Trang Đăng Ký (`/signup`)
  - Tạo tài khoản mới bằng email/password
  - Thu thập thông tin cơ bản người dùng:
    - Tên đầy đủ
    - Email
    - Mật khẩu
    - Số điện thoại (tùy chọn)
    - Tuổi (tùy chọn)
    - Giống chó/mèo yêu thích (tùy chọn)
    - Tiểu sử (tùy chọn)
  - Đăng ký bằng Google
  - Link đến trang đăng nhập

✅ Protected Routes
  - Tất cả các trang app (/, /match, /shop, /messages, /profile) đều được bảo vệ
  - Chỉ người dùng đã xác thực mới có thể truy cập
  - Tự động chuyển hướng đến /login nếu chưa đăng nhập

✅ Auth Context
  - Quản lý trạng thái xác thực toàn bộ ứng dụng
  - Hook `useAuth()` để truy cập thông tin người dùng và phương thức đăng xuất

## 7. Tiếp Theo (Bước Tùy Chọn)

- Thêm trang hồ sơ người dùng để cập nhật thông tin
- Thêm xác minh email
- Thêm reset mật khẩu
- Thêm 2FA (Two-Factor Authentication)
- Lưu profile người dùng vào database
