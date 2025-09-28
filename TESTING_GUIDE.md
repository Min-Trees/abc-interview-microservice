# Testing Guide - Interview Microservice ABC

Hướng dẫn test toàn bộ hệ thống Interview Microservice ABC để đảm bảo các API hoạt động đúng.

## 📁 Files Test

### 1. `test-data.json`
Chứa tất cả dữ liệu test cho các API endpoints:
- Test accounts (user, recruiter, admin)
- Sample requests cho tất cả services
- Test scenarios cho các workflow khác nhau

### 2. `postman-collection.json`
Postman collection hoàn chỉnh với:
- Tất cả API endpoints của hệ thống
- Pre-configured requests với sample data
- Environment variables
- Test scripts tự động

### 3. `test-system.ps1`
PowerShell script để test tự động:
- Health checks cho tất cả services
- Test các API endpoints chính
- Báo cáo kết quả chi tiết
- Hỗ trợ verbose mode

### 4. `test-api.sh`
Bash script đơn giản sử dụng curl:
- Test nhanh các endpoints
- Không cần dependencies phức tạp
- Chạy được trên Linux/Mac

## 🚀 Cách Sử Dụng

### Bước 1: Khởi động hệ thống
```bash
# Sử dụng Docker Compose
docker-compose up -d

# Hoặc sử dụng script có sẵn
./quick-setup.ps1
```

### Bước 2: Chạy test

#### Option 1: Sử dụng PowerShell (Windows)
```powershell
# Test cơ bản
.\test-system.ps1

# Test với verbose output
.\test-system.ps1 -Verbose

# Test với custom base URL
.\test-system.ps1 -BaseUrl "http://localhost:8080"
```

#### Option 2: Sử dụng Bash (Linux/Mac)
```bash
# Cấp quyền thực thi
chmod +x test-api.sh

# Chạy test
./test-api.sh
```

#### Option 3: Sử dụng Postman
1. Import file `postman-collection.json` vào Postman
2. Set environment variables:
   - `baseUrl`: http://localhost:8080
   - `authToken`: (sẽ được set tự động sau khi login)
3. Chạy collection hoặc từng request riêng lẻ

## 🔍 Test Scenarios

### 1. Health Check Test
Kiểm tra tất cả services đang chạy:
- Gateway Service (Port 8080)
- Auth Service (Port 8081)
- User Service (Port 8082)
- Career Service (Port 8084)
- Question Service (Port 8085)
- Exam Service (Port 8086)
- News Service (Port 8087)
- NLP Service (Port 8088)

### 2. Authentication Flow
1. Register new user
2. Login với credentials
3. Verify token
4. Refresh token

### 3. User Management
1. Create user profile
2. Update user role (Admin only)
3. Update user status (Admin only)
4. Apply ELO score

### 4. Question Management
1. Create field, topic, level, question type
2. Create question with options
3. Approve/reject question (Admin only)
4. Create sample answers

### 5. Exam Management
1. Create exam
2. Add questions to exam
3. Publish exam
4. Register for exam
5. Start/complete exam
6. Submit answers
7. Submit results

### 6. Career Preferences
1. Create career preference
2. Update career preference
3. Get career by user ID
4. Delete career preference

### 7. News & Recruitment
1. Create news article
2. Create recruitment post
3. Approve/publish news (Admin only)
4. Vote on news

### 8. NLP Services
1. Check question similarity
2. Grade essay answers
3. Grade exam answers

## 📊 Expected Results

### Successful Test Output
```
🚀 Starting Interview Microservice ABC System Tests...
Base URL: http://localhost:8080

🔍 Testing Health Checks...
✅ Gateway Service
✅ Auth Service
✅ User Service
✅ Career Service
✅ Question Service
✅ Exam Service
✅ News Service
✅ NLP Service

🔐 Testing Authentication Flow...
✅ User Login

👤 Testing User Service...
✅ User Registration
✅ User Login

❓ Testing Question Service...
✅ Create Field
✅ Create Topic
✅ Create Question

📝 Testing Exam Service...
✅ Create Exam
✅ Register for Exam

🎯 Testing Career Service...
✅ Create Career Preference

📰 Testing News Service...
✅ Create News
✅ Create Recruitment

🤖 Testing NLP Service...
✅ Check Question Similarity
✅ Grade Essay

📊 Test Results Summary:
Total Tests: 25
Passed: 25
Failed: 0
Success Rate: 100%

🎉 All tests passed! System is working correctly.
```

## 🐛 Troubleshooting

### Common Issues

1. **Services not starting**
   - Check Docker containers: `docker ps`
   - Check logs: `docker-compose logs [service-name]`
   - Ensure all environment variables are set

2. **Database connection issues**
   - Verify PostgreSQL is running
   - Check database credentials in environment variables
   - Run init.sql script

3. **Authentication failures**
   - Verify JWT_SECRET is set
   - Check if user exists in database
   - Verify password hashing

4. **CORS issues**
   - Check gateway configuration
   - Verify service URLs in gateway routes

### Debug Commands

```bash
# Check all containers
docker ps

# Check specific service logs
docker-compose logs auth-service

# Check service health directly
curl http://localhost:8081/actuator/health

# Check database connection
docker exec -it interview-postgres psql -U postgres -d authdb
```

## 📝 Custom Test Data

Để tạo test data tùy chỉnh, chỉnh sửa file `test-data.json`:

```json
{
  "test_accounts": {
    "custom_user": {
      "email": "custom@example.com",
      "password": "custom123",
      "role": "USER"
    }
  },
  "custom_scenarios": {
    "my_test": [
      "1. Create custom user",
      "2. Login with custom credentials",
      "3. Create custom data"
    ]
  }
}
```

## 🔧 Advanced Testing

### Load Testing
Sử dụng Apache Bench hoặc JMeter để test performance:

```bash
# Test login endpoint với 100 requests
ab -n 100 -c 10 -p login.json -T application/json http://localhost:8080/auth/login
```

### Integration Testing
Test các workflow phức tạp:

1. **Complete User Journey**
   - Register → Login → Create Profile → Take Exam → View Results

2. **Admin Workflow**
   - Login as Admin → Approve Questions → Publish Exam → View Analytics

3. **Recruiter Workflow**
   - Login as Recruiter → Create Recruitment → Create Exam → Review Applications

## 📈 Monitoring

Sử dụng các tools sau để monitor hệ thống:

1. **Docker Stats**: `docker stats`
2. **Service Health**: Check `/actuator/health` endpoints
3. **Database Monitoring**: PostgreSQL logs và metrics
4. **Application Logs**: Check service logs for errors

## 🎯 Best Practices

1. **Always test health checks first** - Đảm bảo tất cả services đang chạy
2. **Test authentication flow** - Verify JWT tokens hoạt động đúng
3. **Test with different user roles** - USER, RECRUITER, ADMIN
4. **Test error scenarios** - Invalid data, unauthorized access
5. **Clean up test data** - Xóa data test sau khi hoàn thành
6. **Monitor performance** - Check response times và resource usage

---

**Lưu ý**: Đảm bảo tất cả services đã được khởi động và database đã được khởi tạo trước khi chạy tests.
