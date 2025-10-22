# 🚀 Quick Deploy Guide

## TL;DR

```powershell
# 1. Stop & rebuild everything
docker-compose down
docker-compose build --no-cache

# 2. Start all services
docker-compose up -d

# 3. Wait 60 seconds
Start-Sleep -Seconds 60

# 4. Import sample data
.\run-init-with-data.ps1

# 5. Test
# Open: http://localhost:8222/swagger-ui.html
# Or open: swagger-ui.html in browser
```

---

## 📊 What Was Fixed

### 1. Auth Service
- ✅ Xử lý register/login/verify TRỰC TIẾP (không gọi User Service)
- ✅ Tạo Entity + Repository cho User và Role
- ✅ Password hashing với BCrypt
- ✅ Email verification
- ✅ JWT token generation

### 2. Exception Handlers
- ✅ Tất cả 6 services có RFC 7807 error format
- ✅ Consistent error codes
- ✅ Trace IDs cho debugging

### 3. Gateway
- ✅ Port 8080 → 8222
- ✅ Routes configured đúng

### 4. Docker Compose
- ✅ Port mapping đúng
- ✅ Dependencies order đúng

---

## 🎯 Test Nhanh

### Login
```bash
POST http://localhost:8222/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

### Get User
```bash
GET http://localhost:8222/users/3
Authorization: Bearer YOUR_TOKEN
```

### Test Error
```bash
POST http://localhost:8222/auth/register
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "123",
  "roleName": "INVALID_ROLE"
}
```

**Expected:** RFC 7807 error response với `errorCode`, `traceId`, `timestamp`

---

## 📚 Documentation

| File | Purpose |
|------|---------|
| `swagger-ui.html` | Interactive API docs (mở bằng browser) |
| `SYSTEM-CHECK-COMPLETE.md` | Chi tiết đầy đủ |
| `WHAT-CHANGED.md` | Tóm tắt thay đổi |
| `GLOBAL-EXCEPTION-HANDLING.md` | Error handling guide |
| `REBUILD-AND-TEST.md` | Step-by-step guide |

---

## ✅ All Systems Go!

Sau khi chạy xong các lệnh trên:
- ✅ 9 services running
- ✅ Sample data imported
- ✅ Swagger UI accessible
- ✅ Error handling standardized
- ✅ Ready for testing

**Happy Coding!** 🎉



