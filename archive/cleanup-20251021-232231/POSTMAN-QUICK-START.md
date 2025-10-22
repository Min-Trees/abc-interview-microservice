# Quick Start Guide - API Testing với Postman

## 🚀 Bắt đầu nhanh trong 5 phút

### Bước 1: Import Postman Collection và Environment

1. Mở Postman
2. Click **Import** ở góc trái trên
3. Kéo thả 2 files sau vào:
   - `postman-collections/Complete-API-Collection-V2.postman_collection.json`
   - `postman-collections/ABC-Interview-Environment.postman_environment.json`

### Bước 2: Chọn Environment

1. Ở góc phải trên, dropdown **No Environment**
2. Chọn **ABC Interview Platform - Development**
3. Verify biến `base_url` = `http://localhost:8080`

### Bước 3: Đăng nhập để lấy Token

1. Mở folder **Auth Service**
2. Click request **Login**
3. Verify body JSON:
   ```json
   {
     "email": "admin@example.com",
     "password": "admin123"
   }
   ```
4. Click **Send**
5. Kiểm tra:
   - Response 200 OK
   - Environment variables tự động được set:
     - `access_token` = JWT token
     - `user_id` = 1
     - `refresh_token` = Refresh token

### Bước 4: Test các Endpoints

Bây giờ tất cả requests đã tự động có Authorization header!

**Test ngay:**

1. **Question Service → Fields → Get All Fields**
   - Click Send → Xem danh sách fields (Java, Python, etc.)

2. **Question Service → Questions → Get All Questions**
   - Click Send → Xem danh sách câu hỏi với đầy đủ thông tin

3. **User Service → Get Current User**
   - Click Send → Xem thông tin user hiện tại

4. **Question Service → Fields → Create Field** (ADMIN only)
   - Sửa body theo ý bạn
   - Click Send → Tạo field mới

---

## 📋 Cấu trúc Collection

```
Complete API Collection V2
├── Auth Service (4 requests)
│   ├── Register
│   ├── Login ← Bắt đầu từ đây
│   ├── Refresh Token
│   └── Validate Token
│
├── User Service (6 requests)
│   ├── Get All Users
│   ├── Get User by ID
│   ├── Update User
│   ├── Delete User
│   └── Search by Email
│
├── Question Service (26 requests) ← Service chính
│   ├── Fields (5: CRUD + List)
│   ├── Topics (5: CRUD + List)
│   ├── Levels (5: CRUD + List)
│   ├── Question Types (5: CRUD + List)
│   ├── Questions (5: CRUD + List)
│   └── Answers (4: CRUD)
│
├── Exam Service (8 requests)
│   ├── Create Exam
│   ├── Get All Exams
│   ├── Start Exam
│   ├── Submit Exam
│   └── Get Results
│
├── Career Service (5 requests)
│   ├── Create Career Path
│   ├── Get All Careers
│   ├── Update Career
│   └── Delete Career
│
├── News Service (6 requests)
│   ├── Create News
│   ├── Get All News
│   ├── Get by Category
│   └── Update/Delete News
│
└── NLP Service (3 requests)
    ├── Check Similarity
    ├── Grade Essay
    └── Extract Keywords
```

---

## 🔐 Authentication Flow

### Luồng đăng nhập chuẩn:

```
1. Register (optional)
   ↓
2. Login → Lưu access_token
   ↓
3. Gọi các endpoint khác (tự động dùng token)
   ↓
4. Token hết hạn? → Refresh Token
   ↓
5. Tiếp tục sử dụng
```

### Scripts tự động:

**Login Request → Tests Tab:**
```javascript
if (pm.response.code === 200) {
    var jsonData = pm.response.json();
    pm.environment.set("access_token", jsonData.accessToken);
    pm.environment.set("refresh_token", jsonData.refreshToken);
    pm.environment.set("user_id", jsonData.userId);
}
```

**Mọi request khác → Authorization Tab:**
- Type: `Bearer Token`
- Token: `{{access_token}}`

---

## 🧪 Test Scenarios

### Scenario 1: Tạo câu hỏi hoàn chỉnh (ADMIN)

1. **Login** với admin account
2. **Create Field**: POST `/questions/fields`
   ```json
   {
     "name": "Java Programming",
     "description": "Java language and frameworks"
   }
   ```
   → Lưu `fieldId` từ response

3. **Create Topic**: POST `/questions/topics`
   ```json
   {
     "name": "Spring Boot",
     "fieldId": 1,
     "description": "Spring Boot framework"
   }
   ```
   → Lưu `topicId`

4. **Create Level**: POST `/questions/levels`
   ```json
   {
     "name": "Medium",
     "description": "Medium difficulty"
   }
   ```
   → Lưu `levelId`

5. **Create Question Type**: POST `/questions/question-types`
   ```json
   {
     "name": "Multiple Choice",
     "description": "Choose one correct answer"
   }
   ```
   → Lưu `questionTypeId`

6. **Create Question**: POST `/questions`
   ```json
   {
     "content": "What is dependency injection?",
     "fieldId": 1,
     "topicId": 1,
     "levelId": 2,
     "questionTypeId": 1,
     "explanation": "DI is a design pattern..."
   }
   ```
   → Lưu `questionId`

7. **Create Answer**: POST `/questions/{questionId}/answers`
   ```json
   {
     "content": "A design pattern",
     "isCorrect": true,
     "explanation": "Correct answer"
   }
   ```

### Scenario 2: Tạo và làm bài thi (USER)

1. **Login** với user account
2. **Get All Exams**: GET `/exams`
3. **Start Exam**: POST `/exams/{id}/start`
4. **Submit Exam**: POST `/exams/{id}/submit`
   ```json
   {
     "sessionId": 123,
     "answers": [
       {"questionId": 1, "answerId": 1},
       {"questionId": 2, "answerId": 5}
     ]
   }
   ```
5. **Get Results**: GET `/exams/{id}/results`

### Scenario 3: Kiểm tra tính năng NLP

1. **Check Similarity**: POST `/nlp/similarity/check`
   ```json
   {
     "text1": "What is Spring Boot?",
     "text2": "Explain Spring Boot framework"
   }
   ```
   → Response: similarity_score, is_similar

2. **Grade Essay**: POST `/nlp/grading/essay`
   ```json
   {
     "question": "Explain dependency injection",
     "answer": "Dependency injection is...",
     "max_score": 10
   }
   ```
   → Response: score, feedback

---

## 🔧 Troubleshooting

### Lỗi 401 Unauthorized
**Nguyên nhân:** Token hết hạn hoặc chưa login
**Giải pháp:**
1. Chạy lại **Login** request
2. Verify `access_token` đã được set trong environment

### Lỗi 403 Forbidden
**Nguyên nhân:** User không có quyền (thiếu role ADMIN)
**Giải pháp:**
1. Kiểm tra endpoint có yêu cầu role ADMIN không?
2. Login với account admin (`admin@example.com` / `admin123`)

### Lỗi 404 Not Found
**Nguyên nhân:** Service chưa chạy hoặc endpoint path sai
**Giải pháp:**
```powershell
# Kiểm tra services đang chạy
docker ps

# Xem logs
docker logs interview-question-service
docker logs interview-auth-service

# Restart service nếu cần
docker-compose restart question-service
```

### Lỗi 500 Internal Server Error
**Nguyên nhân:** Lỗi server-side (code bug, database issue)
**Giải pháp:**
```powershell
# Xem logs chi tiết
docker logs interview-question-service --tail 100

# Kiểm tra database
docker exec -it interview-postgres psql -U postgres -d questiondb
```

### Endpoint trả về dữ liệu rỗng
**Nguyên nhân:** Database chưa có dữ liệu
**Giải pháp:**
```powershell
# Import sample data
.\run-init-with-data.ps1

# Hoặc import từ database-import folder
cd database-import
.\quick-import-data.ps1
```

---

## 📊 Response Codes

| Code | Ý nghĩa | Hành động |
|------|---------|-----------|
| 200 | OK | Thành công |
| 201 | Created | Tạo mới thành công |
| 204 | No Content | Xóa thành công |
| 400 | Bad Request | Sửa request body/params |
| 401 | Unauthorized | Login lại |
| 403 | Forbidden | Cần role ADMIN |
| 404 | Not Found | Kiểm tra ID/path |
| 500 | Server Error | Xem logs |

---

## 🎯 Các endpoint quan trọng

### Public Endpoints (không cần token):
- ✅ `POST /auth/register`
- ✅ `POST /auth/login`
- ✅ `GET /questions/fields`
- ✅ `GET /questions/topics`
- ✅ `GET /questions/levels`
- ✅ `GET /questions/question-types`
- ✅ `GET /questions`
- ✅ `GET /questions/{id}`

### Protected Endpoints (cần token):
- 🔒 `GET /users` (ADMIN)
- 🔒 `POST /questions/fields` (ADMIN)
- 🔒 `POST /questions` (ADMIN)
- 🔒 `POST /exams` (ADMIN)
- 🔒 `POST /exams/{id}/start` (USER)
- 🔒 `POST /exams/{id}/submit` (USER)

---

## 📖 Tài liệu chi tiết

Xem file `COMPLETE-API-DOCUMENTATION.md` để biết:
- Chi tiết tất cả 70+ endpoints
- Request/Response examples đầy đủ
- Swagger UI URLs cho từng service
- Best practices và conventions

---

## 🌐 Service URLs

### Via API Gateway (khuyến nghị):
```
http://localhost:8080/auth/*
http://localhost:8080/users/*
http://localhost:8080/questions/*
http://localhost:8080/exams/*
http://localhost:8080/careers/*
http://localhost:8080/news/*
http://localhost:8080/nlp/*
```

### Direct to Service (debug):
```
Auth:     http://localhost:8081
User:     http://localhost:8082
Question: http://localhost:8085
Exam:     http://localhost:8086
Career:   http://localhost:8087
News:     http://localhost:8088
NLP:      http://localhost:5000
```

### Swagger UI:
```
Auth:     http://localhost:8081/swagger-ui.html
User:     http://localhost:8082/swagger-ui.html
Question: http://localhost:8085/swagger-ui.html
Exam:     http://localhost:8086/swagger-ui.html
Career:   http://localhost:8087/swagger-ui.html
News:     http://localhost:8088/swagger-ui.html
NLP:      http://localhost:5000/docs (FastAPI)
```

---

## ✅ Checklist để bắt đầu

- [ ] Import Postman collection
- [ ] Import Environment file
- [ ] Chọn environment "ABC Interview Platform - Development"
- [ ] Chạy `docker-compose up -d` để start services
- [ ] Chờ services healthy (~30s)
- [ ] Login với admin@example.com / admin123
- [ ] Verify `access_token` được set
- [ ] Test GET `/questions/fields`
- [ ] Test POST `/questions/fields` (create)
- [ ] Xem Swagger UI tại http://localhost:8085/swagger-ui.html

**Hoàn thành!** 🎉

---

**Ghi chú:**
- Token tự động expire sau 1 giờ → Dùng Refresh Token
- Tất cả datetime theo ISO 8601 format
- Pagination mặc định: page=0, size=20
- Gateway timeout: 60 seconds
