# Hướng Dẫn Import và Sử Dụng Postman Collection

## 📋 Mục Lục
1. [Import Collection và Environment](#import-collection-và-environment)
2. [Cấu Hình Environment](#cấu-hình-environment)
3. [Quy Trình Làm Việc](#quy-trình-làm-việc)
4. [Danh Sách Endpoints](#danh-sách-endpoints)
5. [Test Scripts và Auto-Save Token](#test-scripts-và-auto-save-token)

---

## 🚀 Import Collection và Environment

### Bước 1: Import Environment
1. Mở Postman
2. Click **Import** (góc trên bên trái)
3. Chọn file: `ABC-Interview-Environment.postman_environment.json`
4. Click **Import**

### Bước 2: Import Collection
1. Click **Import** lại
2. Chọn file: `ABC-Interview-Complete-Collection.postman_collection.json`
3. Click **Import**

### Bước 3: Chọn Environment
1. Click dropdown ở góc trên bên phải (No Environment)
2. Chọn: **ABC Interview Platform - Development**

✅ **Hoàn tất!** Bây giờ bạn đã sẵn sàng để test API.

---

## ⚙️ Cấu Hình Environment

### Các Biến Môi Trường Quan Trọng

| Biến | Giá Trị Mặc Định | Mô Tả |
|------|------------------|-------|
| `base_url` | `http://localhost:8080` | URL của API Gateway |
| `access_token` | (auto-set) | JWT access token (tự động lưu sau khi login) |
| `refresh_token` | (auto-set) | JWT refresh token (tự động lưu) |
| `verify_token` | (auto-set) | Token xác thực email (tự động lưu sau register) |

**Lưu ý**: Các token sẽ được tự động lưu vào environment sau khi bạn:
- Đăng ký (`Register New User`)
- Đăng nhập (`Login`)
- Verify account (`Verify Account`)
- Refresh token (`Refresh Token`)

---

## 🔄 Quy Trình Làm Việc

### Flow 1: Đăng Ký Tài Khoản Mới

```
1. Auth Service > Register New User
   ↓ (auto-save verify_token)
2. Auth Service > Verify Account
   ↓ (auto-save access_token)
3. ✅ Bạn đã có token, có thể gọi các API khác
```

### Flow 2: Đăng Nhập Với Tài Khoản Có Sẵn

```
1. Auth Service > Login
   ↓ (auto-save access_token & refresh_token)
2. ✅ Bạn đã có token, có thể gọi các API khác
```

### Flow 3: Tạo và Làm Bài Thi

```
1. Login (để lấy token)
2. Question Service > Questions > Get All Questions
3. Exam Service > Create Exam
4. Exam Service > Start Exam
5. Exam Service > Complete Exam
```

---

## 📚 Danh Sách Endpoints

### 🔐 Auth Service (4 endpoints)
- **POST** `/auth/register` - Đăng ký tài khoản mới
- **GET** `/auth/verify?token=xxx` - Xác thực email
- **POST** `/auth/login` - Đăng nhập
- **POST** `/auth/refresh` - Làm mới access token

### 👤 User Service (6 endpoints)
- **GET** `/users/roles` - Lấy danh sách roles (không cần token)
- **GET** `/users/{id}` - Lấy thông tin user
- **GET** `/users` - Lấy tất cả users (Admin only)
- **PUT** `/users/{id}` - Cập nhật user
- **PUT** `/users/{id}/role` - Cập nhật role (Admin only)
- **PUT** `/users/{id}/status` - Cập nhật status (Admin only)

### 📝 Question Service (10+ endpoints)

#### Fields
- **GET** `/questions/fields` - Lấy tất cả fields
- **POST** `/questions/fields` - Tạo field mới (Admin only)

#### Topics
- **GET** `/questions/topics` - Lấy tất cả topics
- **POST** `/questions/topics` - Tạo topic mới (Admin only)

#### Levels
- **GET** `/questions/levels` - Lấy tất cả levels

#### Question Types
- **GET** `/questions/question-types` - Lấy tất cả question types

#### Questions
- **GET** `/questions` - Lấy tất cả questions
- **GET** `/questions/{id}` - Lấy question theo ID
- **POST** `/questions` - Tạo question mới

### 📄 Exam Service (6+ endpoints)
- **GET** `/exams/types` - Lấy danh sách exam types
- **GET** `/exams` - Lấy tất cả exams
- **GET** `/exams/{id}` - Lấy exam theo ID
- **POST** `/exams` - Tạo exam mới
- **POST** `/exams/{id}/start` - Bắt đầu làm bài
- **POST** `/exams/{id}/complete` - Hoàn thành bài thi

### 📰 News Service (6+ endpoints)
- **GET** `/news/types` - Lấy danh sách news types
- **GET** `/news` - Lấy tất cả news
- **GET** `/news/{id}` - Lấy news theo ID
- **POST** `/news` - Tạo news mới
- **GET** `/recruitments` - Lấy tin tuyển dụng
- **POST** `/recruitments` - Tạo tin tuyển dụng

### 💼 Career Service (4 endpoints)
- **POST** `/career` - Tạo career preference
- **GET** `/career/preferences/{userId}` - Lấy preferences theo user
- **GET** `/career/{id}` - Lấy career theo ID
- **PUT** `/career/update/{id}` - Cập nhật career preference

---

## 🤖 Test Scripts và Auto-Save Token

Collection này có **Test Scripts tự động** để lưu token vào environment:

### Register New User
```javascript
if (pm.response.code === 201) {
    const jsonData = pm.response.json();
    pm.environment.set('access_token', jsonData.accessToken);
    pm.environment.set('verify_token', jsonData.verifyToken);
}
```

### Login
```javascript
if (pm.response.code === 200) {
    const jsonData = pm.response.json();
    pm.environment.set('access_token', jsonData.accessToken);
    pm.environment.set('refresh_token', jsonData.refreshToken);
}
```

➡️ **Không cần copy-paste token thủ công!**

---

## 🎯 Tài Khoản Mẫu

### Admin Account
```
Email: admin@example.com
Password: admin123
Role: ADMIN
```

Sử dụng tài khoản này để:
- Test các endpoint yêu cầu ADMIN role
- Quản lý users, questions, exams

---

## 🔍 Kiểm Tra Token

Sau khi login/register, kiểm tra environment variables:

1. Click vào **Environment quick look** (icon con mắt góc trên bên phải)
2. Xem giá trị của:
   - `access_token` (có giá trị => đã login thành công)
   - `refresh_token`
   - `verify_token` (sau register)

---

## ⚡ Tips và Best Practices

### 1. Thứ Tự Thực Thi
- Luôn **Login trước** khi test các endpoint có auth
- Test các endpoint **GET** trước khi test POST/PUT/DELETE

### 2. Authorization
- Hầu hết các request đã được cấu hình sẵn **Bearer Token**
- Token được lấy từ `{{access_token}}`
- Một số endpoint public không cần token:
  - `/auth/register`, `/auth/login`
  - `/users/roles`
  - `/questions/fields`, `/questions/topics`, `/questions/levels`
  - `/news` (public news)

### 3. Request Body
- Tất cả body đã có **sample data**
- Chỉnh sửa giá trị theo nhu cầu test
- Kiểm tra response để biết cấu trúc dữ liệu chính xác

### 4. Pagination
- Hầu hết GET list endpoints hỗ trợ pagination:
  - `?page=0&size=10`
- Default: page=0, size=20

---

## 🐛 Troubleshooting

### Lỗi 401 Unauthorized
- Token hết hạn hoặc không hợp lệ
- **Giải pháp**: Login lại hoặc dùng Refresh Token

### Lỗi 403 Forbidden
- Tài khoản không có quyền (role)
- **Giải pháp**: Dùng tài khoản Admin hoặc kiểm tra role requirements

### Lỗi 404 Not Found
- Endpoint không tồn tại hoặc service chưa khởi động
- **Giải pháp**: Kiểm tra service đang chạy (`docker-compose ps`)

### Token không được lưu tự động
- Kiểm tra Test script có chạy không (tab Tests trong request)
- Xem Console tab trong Postman để debug

---

## 📞 Hỗ Trợ

Nếu gặp vấn đề:
1. Kiểm tra services đang chạy: `docker-compose ps`
2. Xem logs: `docker logs interview-xxx-service`
3. Test endpoints với script: `.\test-endpoints-simple.ps1`

---

**Chúc bạn test API thành công! 🎉**
