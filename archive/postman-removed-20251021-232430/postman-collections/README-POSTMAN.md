# Postman Collections - ABC Interview Platform

## 📦 Collection Files

Import TẤT CẢ các file sau vào Postman:

1. **ABC-Interview-Environment.postman_environment.json** - Environment variables (BẮT BUỘC)
2. **Complete-API-Collection-Full.postman_collection.json** - Tất cả 103+ endpoints

## 📊 Tổng quan Endpoints

| Service | Số Endpoints | File Collection |
|---------|--------------|-----------------|
| **Auth Service** | 5 | Trong Complete collection |
| **User Service** | 16 | Trong Complete collection |
| **Question Service** | 26 | Trong Complete collection |
| **Exam Service** | 21 | Trong Complete collection |
| **Career Service** | 5 | Trong Complete collection |
| **News Service** | 17 | Trong Complete collection |
| **Recruitment Service** | 2 | Trong Complete collection |
| **NLP Service** | 11 | Trong Complete collection |
| **TỔNG CỘNG** | **103** | |

## 🔍 Chi tiết từng Service

### 1. Auth Service (5 endpoints)
- POST `/auth/register` - Đăng ký tài khoản mới
- POST `/auth/login` - Đăng nhập và lấy JWT token
- POST `/auth/refresh` - Làm mới access token
- GET `/auth/verify?token=` - Xác thực token
- GET `/auth/user-info` - Lấy thông tin user từ token

### 2. User Service (16 endpoints)

**Internal Endpoints (Auth Service gọi):**
- POST `/users/internal/create` - Tạo user (internal)
- GET `/users/check-email/{email}` - Kiểm tra email tồn tại
- GET `/users/by-email/{email}` - Lấy user theo email
- POST `/users/validate-password` - Validate password
- POST `/users/verify-token` - Verify JWT token

**Public/User Endpoints:**
- GET `/users/{id}` - Lấy user theo ID
- PUT `/users/{id}` - Cập nhật user
- DELETE `/users/{id}` - Xóa user (ADMIN)
- GET `/users` - Lấy tất cả users (ADMIN, paginated)
- GET `/users/role/{roleId}` - Lấy users theo role (ADMIN)
- GET `/users/status/{status}` - Lấy users theo status (ADMIN)

**Admin Endpoints:**
- PUT `/users/{id}/role` - Cập nhật role (ADMIN)
- PUT `/users/{id}/status` - Cập nhật status (ADMIN)

**Elo System:**
- POST `/users/elo` - Apply Elo rating

### 3. Question Service (26 endpoints)

**Fields (5 endpoints):**
- GET `/questions/fields` - Lấy tất cả fields
- GET `/questions/fields/{id}` - Lấy field theo ID
- POST `/questions/fields` - Tạo field (ADMIN)
- PUT `/questions/fields/{id}` - Cập nhật field (ADMIN)
- DELETE `/questions/fields/{id}` - Xóa field (ADMIN)

**Topics (5 endpoints):**
- GET `/questions/topics` - Lấy tất cả topics (có fieldName)
- GET `/questions/topics/{id}` - Lấy topic theo ID
- POST `/questions/topics` - Tạo topic (ADMIN)
- PUT `/questions/topics/{id}` - Cập nhật topic (ADMIN)
- DELETE `/questions/topics/{id}` - Xóa topic (ADMIN)

**Levels (5 endpoints):**
- GET `/questions/levels` - Lấy tất cả levels
- GET `/questions/levels/{id}` - Lấy level theo ID
- POST `/questions/levels` - Tạo level (ADMIN)
- PUT `/questions/levels/{id}` - Cập nhật level (ADMIN)
- DELETE `/questions/levels/{id}` - Xóa level (ADMIN)

**Question Types (5 endpoints):**
- GET `/questions/question-types` - Lấy tất cả question types
- GET `/questions/question-types/{id}` - Lấy question type theo ID
- POST `/questions/question-types` - Tạo question type (ADMIN)
- PUT `/questions/question-types/{id}` - Cập nhật question type (ADMIN)
- DELETE `/questions/question-types/{id}` - Xóa question type (ADMIN)

**Questions (5 endpoints):**
- GET `/questions` - Lấy tất cả questions (paginated, với relationships)
- GET `/questions/{id}` - Lấy question theo ID
- POST `/questions` - Tạo question (ADMIN)
- PUT `/questions/{id}` - Cập nhật question (ADMIN)
- DELETE `/questions/{id}` - Xóa question (ADMIN)

**Answers (4 endpoints):**
- GET `/questions/{questionId}/answers` - Lấy answers của question
- POST `/questions/{questionId}/answers` - Tạo answer (ADMIN)
- PUT `/questions/{questionId}/answers/{answerId}` - Cập nhật answer (ADMIN)
- DELETE `/questions/{questionId}/answers/{answerId}` - Xóa answer (ADMIN)

### 4. Exam Service (21 endpoints)

**Exam CRUD:**
- POST `/exams` - Tạo exam
- GET `/exams` - Lấy tất cả exams (paginated)
- GET `/exams/{id}` - Lấy exam theo ID
- PUT `/exams/{id}` - Cập nhật exam (ADMIN/RECRUITER)
- DELETE `/exams/{id}` - Xóa exam (ADMIN/RECRUITER)

**Exam Lifecycle:**
- POST `/exams/{examId}/publish` - Publish exam (ADMIN/RECRUITER)
- POST `/exams/{examId}/start` - Bắt đầu exam (USER)
- POST `/exams/{examId}/complete` - Hoàn thành exam (USER)

**Exam Queries:**
- GET `/exams/user/{userId}` - Lấy exams của user
- GET `/exams/type/{examType}` - Lấy exams theo type

**Exam Questions:**
- POST `/exams/questions` - Thêm câu hỏi vào exam (ADMIN/RECRUITER)
- DELETE `/exams/{examId}/questions` - Xóa câu hỏi khỏi exam (ADMIN/RECRUITER)

**Results & Answers:**
- POST `/exams/results` - Submit kết quả (USER)
- GET `/exams/{examId}/results` - Lấy results của exam (ADMIN/RECRUITER)
- GET `/exams/results/user/{userId}` - Lấy results của user
- GET `/exams/results/{id}` - Lấy result theo ID
- POST `/exams/answers` - Submit answer (USER)
- GET `/exams/{examId}/answers/{userId}` - Lấy answers của user trong exam
- GET `/exams/answers/{id}` - Lấy answer theo ID

**Registrations:**
- POST `/exams/registrations` - Đăng ký thi (USER)
- POST `/exams/registrations/{registrationId}/cancel` - Hủy đăng ký (USER)
- GET `/exams/{examId}/registrations` - Lấy registrations của exam (ADMIN/RECRUITER)
- GET `/exams/registrations/user/{userId}` - Lấy registrations của user

### 5. Career Service (5 endpoints)
- POST `/career` - Tạo career preference (USER/ADMIN)
- GET `/career/{careerId}` - Lấy career theo ID (USER/ADMIN)
- PUT `/career/update/{careerId}` - Cập nhật career (USER/ADMIN)
- GET `/career/preferences/{userId}` - Lấy careers của user (USER/ADMIN, paginated)
- DELETE `/career/{careerId}` - Xóa career (USER/ADMIN)

### 6. News Service (17 endpoints)

**News CRUD:**
- POST `/news` - Tạo news (USER/ADMIN/RECRUITER)
- GET `/news` - Lấy tất cả news (paginated)
- GET `/news/{id}` - Lấy news theo ID
- PUT `/news/{id}` - Cập nhật news (USER/ADMIN/RECRUITER)
- DELETE `/news/{id}` - Xóa news (ADMIN/RECRUITER)

**News Moderation:**
- POST `/news/{newsId}/approve` - Approve news (ADMIN)
- POST `/news/{newsId}/reject` - Reject news (ADMIN)
- POST `/news/{newsId}/publish` - Publish news (ADMIN)
- GET `/news/moderation/pending` - Lấy news chờ duyệt (ADMIN)

**News Queries:**
- GET `/news/type/{newsType}` - Lấy news theo type
- GET `/news/user/{userId}` - Lấy news của user
- GET `/news/status/{status}` - Lấy news theo status (ADMIN)
- GET `/news/field/{fieldId}` - Lấy news theo field
- GET `/news/published/{newsType}` - Lấy published news theo type

**News Interaction:**
- POST `/news/{newsId}/vote` - Vote news (USER/ADMIN)

### 7. Recruitment Service (2 endpoints)
- POST `/recruitments` - Tạo recruitment (RECRUITER/ADMIN)
- GET `/recruitments` - Lấy tất cả recruitments (paginated)

### 8. NLP Service - Python FastAPI (11 endpoints)

**Health Check:**
- GET `/health` - Health check

**Text Similarity:**
- POST `/similarity/check` - Kiểm tra độ tương đồng 2 texts

**Essay Grading:**
- POST `/grading/essay` - Chấm điểm bài essay

**Question Analysis:**
- POST `/questions/similarity/check` - Kiểm tra câu hỏi trùng lặp
- GET `/questions/{question_id}/analytics` - Lấy analytics của câu hỏi

**Exam Grading:**
- POST `/exams/{exam_id}/questions/{question_id}/grade` - Chấm điểm 1 câu trong exam
- POST `/exams/{exam_id}/grade-all` - Chấm tất cả câu tự luận trong exam

**AI Studio Integration:**
- POST `/ai-studio/validate-answer` - Validate câu trả lời với AI Studio
- POST `/ai-studio/check-plagiarism` - Kiểm tra đạo văn

## 🚀 Quick Start

### 1. Import vào Postman
```
1. Mở Postman
2. Click Import
3. Import file: ABC-Interview-Environment.postman_environment.json
4. Import file: Complete-API-Collection-Full.postman_collection.json
5. Chọn environment "ABC Interview Platform - Development"
```

### 2. Đăng nhập
```
1. Mở folder "Auth Service"
2. Run request "Login"
3. Token sẽ tự động lưu vào environment
```

### 3. Test endpoints
```
Tất cả authenticated requests đã tự động dùng {{access_token}}
```

## 🔐 Authentication

### Token Auto-Save
Tất cả requests **Login**, **Register**, **Refresh** đều có script tự động lưu token:

```javascript
if (pm.response.code === 200) {
    var jsonData = pm.response.json();
    if (jsonData.accessToken) {
        pm.environment.set("access_token", jsonData.accessToken);
    }
    if (jsonData.refreshToken) {
        pm.environment.set("refresh_token", jsonData.refreshToken);
    }
    if (jsonData.userId) {
        pm.environment.set("user_id", jsonData.userId);
    }
}
```

### Authorization Header
Tất cả protected endpoints sử dụng:
```
Authorization: Bearer {{access_token}}
```

## 📋 Environment Variables

| Variable | Description | Auto-set |
|----------|-------------|----------|
| `base_url` | API Gateway URL (http://localhost:8080) | No |
| `access_token` | JWT access token | Yes (from Login) |
| `refresh_token` | JWT refresh token | Yes (from Login) |
| `user_id` | Current user ID | Yes (from Login) |
| `auth_service_url` | http://localhost:8081 | No |
| `user_service_url` | http://localhost:8082 | No |
| `question_service_url` | http://localhost:8085 | No |
| `exam_service_url` | http://localhost:8086 | No |
| `career_service_url` | http://localhost:8087 | No |
| `news_service_url` | http://localhost:8088 | No |
| `nlp_service_url` | http://localhost:5000 | No |

## 🎯 Test Scenarios

### Scenario 1: Tạo câu hỏi hoàn chỉnh
1. Login (ADMIN)
2. Create Field → Lưu fieldId
3. Create Topic (dùng fieldId) → Lưu topicId
4. Create Level → Lưu levelId
5. Create Question Type → Lưu questionTypeId
6. Create Question (dùng tất cả IDs) → Lưu questionId
7. Create Answer (dùng questionId)

### Scenario 2: Tạo và làm bài thi
1. Login (USER)
2. Get All Exams
3. Register for Exam
4. Start Exam
5. Submit Answers
6. Submit Result
7. Get Results

### Scenario 3: Quản lý News & Recruitment
1. Login (RECRUITER)
2. Create News
3. Create Recruitment
4. Admin Approve News
5. Admin Publish News
6. Get Published News

### Scenario 4: NLP Processing
1. Login
2. Check Text Similarity
3. Grade Essay
4. Check Question Similarity
5. Grade Exam Answer
6. Batch Grade Exam

## 🔧 Troubleshooting

### 401 Unauthorized
- Chạy lại Login request
- Kiểm tra `access_token` trong environment

### 403 Forbidden
- Kiểm tra role (ADMIN, USER, RECRUITER)
- Đăng nhập với account có quyền

### 404 Not Found
- Kiểm tra service đang chạy: `docker ps`
- Kiểm tra endpoint path

### 500 Internal Server Error
- Xem logs: `docker logs interview-<service-name>`

## 📖 Tài liệu thêm

- **COMPLETE-API-DOCUMENTATION.md** - Chi tiết tất cả endpoints
- **POSTMAN-QUICK-START.md** - Hướng dẫn nhanh
- Swagger UI: http://localhost:8085/swagger-ui.html
- NLP Docs: http://localhost:5000/docs

---

**Tổng cộng: 103 endpoints** được document đầy đủ trong collection này.
