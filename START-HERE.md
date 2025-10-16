# 🎯 START HERE - Interview Microservices System

## 📖 Bạn Đang Ở Đây

Đây là hệ thống Interview Microservices hoàn chỉnh với:
- ✅ 6 business services
- ✅ Global exception handling (RFC 7807)
- ✅ API Gateway + Service Discovery
- ✅ Sample data và documentation

---

## 🚀 Quick Start (5 phút)

```powershell
# 1. Build & Start
docker-compose down
docker-compose build --no-cache
docker-compose up -d

# 2. Wait 60s
Start-Sleep -Seconds 60

# 3. Import data
.\run-init-with-data.ps1

# 4. Test
# Open: swagger-ui.html in browser
```

**Done!** 🎉

---

## 📚 Documentation Map

### 🚀 **Để Deploy:**
1. **`QUICK-DEPLOY.md`** ← BẮT ĐẦU TỪ ĐÂY (nhanh nhất)
2. `REBUILD-AND-TEST.md` (chi tiết từng bước)

### 🔍 **Để Hiểu System:**
3. **`SYSTEM-CHECK-COMPLETE.md`** ← ĐỌC FILE NÀY (kiểm tra toàn bộ)
4. `WHAT-CHANGED.md` (tóm tắt thay đổi)

### 🐛 **Về Error Handling:**
5. `GLOBAL-EXCEPTION-HANDLING.md` (hướng dẫn chi tiết)
6. `ERROR-CODES.md` (danh sách error codes)
7. `EXCEPTION-HANDLING-COMPLETE.md` (implementation details)

### 🌐 **Về APIs:**
8. **`swagger-ui.html`** ← MỞ FILE NÀY BẰNG BROWSER
9. `INTERVIEW_APIS_COMPLETE.postman_collection.json` (import vào Postman)
10. `POSTMAN-GUIDE.md` (hướng dẫn dùng Postman)

---

## 🎯 Common Tasks

### Task 1: Chạy Hệ Thống Lần Đầu
```powershell
docker-compose build --no-cache
docker-compose up -d
.\run-init-with-data.ps1
```

### Task 2: Xem Swagger UI
- **All Services:** Mở `swagger-ui.html` bằng browser
- **Gateway:** http://localhost:8222/swagger-ui.html
- **Auth:** http://localhost:8081/swagger-ui.html
- Các service khác tương tự...

### Task 3: Test APIs
1. Import `INTERVIEW_APIS_COMPLETE.postman_collection.json` vào Postman
2. Run request "Login"
3. Copy token
4. Dùng token cho các request khác

### Task 4: Kiểm Tra Services
```powershell
docker-compose ps        # Xem status
docker-compose logs -f   # Xem logs real-time
```

### Task 5: Xem Sample Data
```powershell
# Login với test accounts
# Email: user@example.com
# Password: password123

# Hoặc
# Email: admin@example.com  
# Password: password123
```

---

## 🏗️ Architecture

```
                    [Client/Frontend]
                           ↓
                    [API Gateway :8222]
                           ↓
              ┌────────────┼────────────┐
              ↓            ↓            ↓
       [Auth :8081]  [User :8082]  [Question :8083]
              ↓            ↓            ↓
       [Exam :8084]  [Career :8085]  [News :8086]
              ↓            ↓            ↓
          [PostgreSQL :5432] + [Redis :6379]
```

**Service Discovery:** Eureka (http://localhost:8761)  
**Config Server:** Spring Cloud Config (http://localhost:8888)

---

## 🔑 Key Features

### 1. Authentication (Auth Service)
- ✅ Register với role (USER, RECRUITER, ADMIN)
- ✅ Login → JWT token
- ✅ Email verification
- ✅ Password encryption (BCrypt)
- ✅ Token refresh

### 2. User Management (User Service)
- ✅ Profile management
- ✅ ELO score system
- ✅ Role updates (ADMIN only)
- ✅ Status updates (ADMIN only)

### 3. Questions (Question Service)
- ✅ Question bank management
- ✅ Fields & difficulty levels
- ✅ Multiple choice / coding questions

### 4. Exams (Exam Service)
- ✅ Create exams from question pool
- ✅ Submit answers
- ✅ Auto-grading
- ✅ Exam history

### 5. Careers (Career Service)
- ✅ Job postings
- ✅ Search & filter
- ✅ Application tracking

### 6. News (News Service)
- ✅ Tech news & announcements
- ✅ Recruitment news
- ✅ Categories

### 7. Global Exception Handling
- ✅ RFC 7807 standard
- ✅ Consistent error codes
- ✅ Trace IDs for debugging
- ✅ Detailed validation errors

---

## 🧪 Test Credentials

| Email | Password | Role |
|-------|----------|------|
| admin@example.com | password123 | ADMIN |
| recruiter@example.com | password123 | RECRUITER |
| user@example.com | password123 | USER |

---

## 📊 Service Ports

| Service | Port | URL |
|---------|------|-----|
| **Gateway** | **8222** | **http://localhost:8222** |
| Auth | 8081 | http://localhost:8081 |
| User | 8082 | http://localhost:8082 |
| Question | 8083 | http://localhost:8083 |
| Exam | 8084 | http://localhost:8084 |
| Career | 8085 | http://localhost:8085 |
| News | 8086 | http://localhost:8086 |
| Discovery | 8761 | http://localhost:8761 |
| Config | 8888 | http://localhost:8888 |
| PostgreSQL | 5432 | localhost:5432 |
| Redis | 6379 | localhost:6379 |

---

## ❓ FAQ

### Q: Services không start?
```powershell
docker-compose logs <service-name>
# Kiểm tra lỗi cụ thể
```

### Q: Swagger UI bị lỗi 500?
1. Đợi services start đủ 60s
2. Kiểm tra: `docker-compose ps` (tất cả phải "Up")
3. Rebuild: `docker-compose build --no-cache <service>`

### Q: Login bị lỗi 401?
- Check email/password đúng chưa
- User phải status "ACTIVE" (không phải "PENDING")
- Nếu vừa register, cần verify email trước

### Q: Error response không có traceId?
- Service chưa được rebuild với exception handlers mới
- Run: `docker-compose build --no-cache`

---

## 🆘 Need Help?

1. **Quick Deploy Issue?** → Đọc `QUICK-DEPLOY.md`
2. **API Error?** → Đọc `ERROR-CODES.md`
3. **System Architecture?** → Đọc `SYSTEM-CHECK-COMPLETE.md`
4. **Postman?** → Đọc `POSTMAN-GUIDE.md`

---

## ✅ System Status

**Last Check:** 2025-10-10  
**Status:** ✅ All Systems Ready  
**Services:** 9/9 Verified  
**Exception Handlers:** ✅ RFC 7807 Compliant  
**Documentation:** ✅ Complete  

---

## 🎉 You're All Set!

Hệ thống đã sẵn sàng. Bắt đầu với:

```powershell
# Quick deploy
.\QUICK-DEPLOY.md  # Đọc file này

# Hoặc chạy trực tiếp
docker-compose build --no-cache
docker-compose up -d
.\run-init-with-data.ps1
```

**Happy Coding!** 🚀
