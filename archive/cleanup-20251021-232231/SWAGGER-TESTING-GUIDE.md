# 🧪 SWAGGER UI - TESTING GUIDE

## ✅ Cấu Hình Đã Cập Nhật

### Tính Năng Mới:
- ✅ **Try It Out** enabled - Test trực tiếp trên UI
- ✅ **Persist Authorization** - Token được lưu tự động
- ✅ **Display Request Duration** - Hiển thị thời gian request
- ✅ **Filter Endpoints** - Tìm kiếm endpoints dễ dàng
- ✅ **Server Selection** - Chọn giữa local hoặc gateway
- ✅ **Detailed Instructions** - Hướng dẫn chi tiết trong mỗi service

---

## 🚀 HƯỚNG DẪN TEST NHANH

### Bước 1: Khởi động Services
```powershell
# Khởi động tất cả services
docker-compose up -d

# Hoặc khởi động từng service
cd auth-service
mvnw spring-boot:run

cd user-service
mvnw spring-boot:run

# ... các services khác
```

---

### Bước 2: Truy Cập Swagger UI

#### Qua Gateway (Khuyến nghị):
```
🌐 http://localhost:8080/services/auth/swagger-ui.html
🌐 http://localhost:8080/services/user/swagger-ui.html
🌐 http://localhost:8080/services/question/swagger-ui.html
🌐 http://localhost:8080/services/exam/swagger-ui.html
🌐 http://localhost:8080/services/career/swagger-ui.html
🌐 http://localhost:8080/services/news/swagger-ui.html
```

#### Trực Tiếp (Development):
```
🔐 Auth Service:     http://localhost:8081/swagger-ui.html
👤 User Service:     http://localhost:8082/swagger-ui.html
❓ Question Service: http://localhost:8085/swagger-ui.html
📝 Exam Service:     http://localhost:8086/swagger-ui.html
💼 Career Service:   http://localhost:8084/swagger-ui.html
📰 News Service:     http://localhost:8087/swagger-ui.html
```

---

### Bước 3: Lấy JWT Token

#### 3.1 Mở Auth Service Swagger UI
```
http://localhost:8081/swagger-ui.html
```

#### 3.2 Register (Tùy chọn - nếu chưa có tài khoản)
1. Mở endpoint **POST /auth/register**
2. Click **Try it out**
3. Nhập dữ liệu:
```json
{
  "email": "test@example.com",
  "password": "password123",
  "roleName": "USER",
  "fullName": "Test User",
  "dateOfBirth": "2000-01-01",
  "address": "123 Test St",
  "isStudying": true
}
```
4. Click **Execute**

#### 3.3 Login để lấy Token
1. Mở endpoint **POST /auth/login**
2. Click **Try it out**
3. Nhập credentials:
```json
{
  "email": "admin@example.com",
  "password": "password123"
}
```
4. Click **Execute**
5. **Copy** `accessToken` từ response (đoạn text dài sau "accessToken")

---

### Bước 4: Authorize Trong Swagger

#### 4.1 Tìm Nút Authorize
- Ở góc trên bên phải Swagger UI
- Biểu tượng ổ khóa 🔒 với text **"Authorize"**

#### 4.2 Nhập Token
1. Click nút **Authorize**
2. Trong popup, tìm field **Value**
3. Nhập: `Bearer your-token-here` (thay `your-token-here` bằng token vừa copy)
   
   **Ví dụ:**
   ```
   Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
   ```

4. Click **Authorize**
5. Click **Close**

#### 4.3 Xác Nhận Token Đã Lưu
- Icon ổ khóa sẽ đổi thành màu đen (đã lock)
- Tất cả các endpoints bây giờ sẽ tự động gửi token này

---

### Bước 5: Test Endpoints

#### 5.1 Chọn Endpoint
- Tìm endpoint muốn test (ví dụ: **GET /questions**)
- Click để expand

#### 5.2 Try It Out
1. Click nút **Try it out** (góc phải)
2. Các fields sẽ trở thành editable

#### 5.3 Nhập Dữ Liệu (Nếu cần)

**Ví dụ POST /questions:**
```json
{
  "userId": 1,
  "topicId": 1,
  "fieldId": 1,
  "levelId": 2,
  "questionTypeId": 1,
  "content": "What is Spring Boot?",
  "answer": "Spring Boot is a framework...",
  "language": "Java"
}
```

#### 5.4 Execute
1. Click nút **Execute** (màu xanh)
2. Đợi response
3. Xem kết quả:
   - **Response code**: 200, 201, 400, 401, 403, etc.
   - **Response body**: Dữ liệu trả về
   - **Response headers**: Headers của response
   - **Request duration**: Thời gian xử lý (ms)

---

## 📋 TEST SCENARIOS

### Scenario 1: CRUD Question
```
1. POST /questions/fields
   - Create: { "name": "Java", "description": "Java Programming" }
   - Get fieldId from response

2. POST /questions/topics
   - Create: { "fieldId": 1, "name": "Spring Boot", "description": "..." }
   - Get topicId

3. GET /questions/fields
   - Verify field was created

4. PUT /questions/fields/1
   - Update field

5. DELETE /questions/fields/1
   - Delete field
```

### Scenario 2: Create & Take Exam
```
1. POST /exams
   - Create exam with topics and question types

2. POST /exams/1/publish
   - Publish exam

3. POST /exams/1/register
   - Register user for exam

4. POST /exams/1/start
   - Start exam

5. POST /exams/1/user-answers
   - Submit answers

6. POST /exams/1/complete
   - Complete exam

7. GET /exams/1/results/user/1
   - Get results
```

### Scenario 3: News Workflow
```
1. POST /news
   - Create news: { "title": "...", "newsType": "TECHNOLOGY", ... }

2. POST /news/1/approve
   - Admin approves news

3. POST /news/1/publish
   - Admin publishes news

4. GET /news/published
   - Verify published news appears

5. POST /news/1/vote
   - Vote for news
```

---

## 🎯 TIPS & TRICKS

### Tip 1: Copy Request as cURL
1. After executing request
2. Scroll to **Curl** section
3. Copy command to use in terminal

### Tip 2: Use Filters
1. Type trong search box ở đầu Swagger UI
2. Filter endpoints by name
3. Ví dụ: gõ "question" để thấy tất cả question endpoints

### Tip 3: Server Selection
1. Click dropdown "Servers" ở đầu page
2. Chọn:
   - **Local Development** (port 808X) - Test trực tiếp service
   - **API Gateway** (port 8080) - Test qua gateway (giống production)

### Tip 4: Persistent Token
- Token được lưu trong session storage
- Refresh page → token vẫn còn
- Đóng tab/browser → mất token (phải authorize lại)

### Tip 5: Check Required Fields
- Fields có dấu ***** là required
- Hover để xem validation rules
- Check DTO source code nếu không chắc

---

## ⚠️ COMMON ERRORS & SOLUTIONS

### Error 401 Unauthorized
**Nguyên nhân:**
- Chưa authorize token
- Token expired (sau 1 giờ)
- Token format sai

**Giải pháp:**
1. Check icon ổ khóa có màu đen không
2. Re-login để lấy token mới
3. Đảm bảo format: `Bearer token-here` (có space)

---

### Error 403 Forbidden
**Nguyên nhân:**
- User không có permission
- Role không đủ (ví dụ: USER cố gọi admin endpoint)

**Giải pháp:**
1. Check endpoint description (requires ADMIN/USER/RECRUITER)
2. Login với account có đúng role
3. Verify token claims (decode JWT tại jwt.io)

---

### Error 400 Bad Request
**Nguyên nhân:**
- Request body không đúng format
- Thiếu required fields
- Validation failed

**Giải pháp:**
1. Check response body cho validation messages
2. So sánh với DTO trong Postman collections
3. Verify field types (String, Long, Boolean, etc.)

---

### Error 404 Not Found
**Nguyên nhân:**
- Endpoint không tồn tại
- Service chưa start
- Wrong server selection

**Giải pháp:**
1. Check service is running: `docker ps` hoặc process manager
2. Verify port number trong URL
3. Switch server (local ↔ gateway)

---

### Error 500 Internal Server Error
**Nguyên nhân:**
- Service crash
- Database connection failed
- Unhandled exception

**Giải pháp:**
1. Check service logs: `docker logs <service-name>`
2. Verify database is running: `docker ps | grep postgres`
3. Check application.yml configurations

---

## 🔍 VERIFY CONFIGURATIONS

### Check Swagger Config
```yaml
# application.yml
springdoc:
  api-docs:
    path: /v3/api-docs
    enabled: true
  swagger-ui:
    path: /swagger-ui.html
    enabled: true
    tryItOutEnabled: true      # ✅ Cho phép test
    filter: true               # ✅ Cho phép filter
    persistAuthorization: true # ✅ Lưu token
    displayRequestDuration: true
```

### Check OpenApiConfig
```java
@Configuration
public class OpenApiConfig {
    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
            .servers(List.of(
                new Server().url("http://localhost:808X"),
                new Server().url("http://localhost:8080")
            ))
            .components(new Components()
                .addSecuritySchemes("bearer-jwt", new SecurityScheme()
                    .type(SecurityScheme.Type.HTTP)
                    .scheme("bearer")
                    .bearerFormat("JWT")))
            .addSecurityItem(new SecurityRequirement().addList("bearer-jwt"));
    }
}
```

---

## 📊 SWAGGER UI FEATURES

| Feature | Description | How to Use |
|---------|-------------|------------|
| 🔒 Authorize | Add JWT token for all requests | Click lock icon → paste `Bearer token` |
| 🔍 Filter | Search endpoints | Type in search box at top |
| 📂 Expand/Collapse | Show/hide endpoint details | Click on endpoint name |
| 🧪 Try It Out | Enable editing | Click "Try it out" button |
| ▶️ Execute | Send request | Click "Execute" button |
| 📋 Copy | Copy response/request | Use copy buttons |
| 🔄 Server Select | Choose local/gateway | Use "Servers" dropdown |
| ⏱️ Duration | Request timing | Shown after response |
| 📖 Models | View schemas | Scroll to "Schemas" section |

---

## 🎓 BEST PRACTICES

### 1. Development Workflow
```
1. Start with Auth Service (get token)
2. Test public endpoints first (no auth)
3. Test authenticated endpoints
4. Test different roles (ADMIN, USER, RECRUITER)
5. Test error cases (invalid data, unauthorized, etc.)
```

### 2. Data Preparation
```
1. Create master data first:
   - Fields → Topics → Levels → Question Types
2. Create questions with answers
3. Create exams with questions
4. Register users
5. Test workflows
```

### 3. Testing Order
```
Auth Service → User Service → Question Service → 
Exam Service → Career Service → News Service
```

### 4. Token Management
```
- Keep browser tab open = keep token
- Use incognito window for different users
- Test token expiration (wait 1 hour)
- Test refresh token flow
```

---

## 📚 RESOURCES

- **Swagger Official Docs**: https://swagger.io/docs/
- **OpenAPI Spec**: https://spec.openapis.org/oas/v3.0.0
- **SpringDoc**: https://springdoc.org/
- **JWT Debugger**: https://jwt.io/

---

## ✅ CHECKLIST

Trước khi test:
- [ ] Tất cả services đang chạy
- [ ] Database connected
- [ ] Auth service accessible
- [ ] Token đã được lấy và authorize
- [ ] Swagger UI load thành công
- [ ] Server selection đúng (local/gateway)

Sau khi test:
- [ ] Verify response codes
- [ ] Check response data
- [ ] Verify database records
- [ ] Test cleanup (delete test data)
- [ ] Document any bugs found

---

**Updated:** December 2025  
**Status:** ✅ Production Ready  
**Version:** 1.0.0
