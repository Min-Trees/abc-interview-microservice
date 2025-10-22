# 📥 HƯỚNG DẪN IMPORT POSTMAN COLLECTION TỪ SWAGGER

## ✅ CÁCH TỐT NHẤT: Import trực tiếp từ Swagger/OpenAPI

Thay vì dùng file JSON tĩnh, hãy import trực tiếp từ Swagger để có APIs chính xác 100%!

---

## 🚀 BƯỚC 1: Khởi động tất cả services

```powershell
# Đảm bảo đã import data
.\run-init-with-data.ps1

# Khởi động tất cả services
docker-compose up -d

# Đợi 30 giây cho services khởi động hoàn tất
```

---

## 📥 BƯỚC 2: Import từ Swagger vào Postman

### Service 1: Auth Service

1. Mở Postman
2. Click **Import**
3. Chọn tab **Link**
4. Nhập URL:
```
http://localhost:8081/v3/api-docs
```
5. Click **Continue** → **Import**
6. Collection "Auth Service" được tạo!

### Service 2: User Service

Lặp lại với URL:
```
http://localhost:8082/v3/api-docs
```

### Service 3: Career Service

```
http://localhost:8084/v3/api-docs
```

### Service 4: Question Service

```
http://localhost:8085/v3/api-docs
```

### Service 5: Exam Service

```
http://localhost:8086/v3/api-docs
```

### Service 6: News Service

```
http://localhost:8087/v3/api-docs
```

---

## 🔑 BƯỚC 3: Setup Authorization

### 3.1 Login để lấy token

1. Mở collection **Auth Service**
2. Tìm request `POST /auth/login`
3. Body:
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```
4. **Send**
5. Copy `accessToken` từ response

### 3.2 Set token cho collection

**Cách 1: Set cho từng collection**
1. Click vào collection name (vd: User Service)
2. Tab **Authorization**
3. Type: **Bearer Token**
4. Token: Paste token vừa copy
5. **Save**

**Cách 2: Dùng Environment Variables** (Khuyến nghị)

1. Click ⚙️ (góc phải trên) → **Environments**
2. Click **+** → Tạo environment mới: **Interview APIs**
3. Thêm variables:

| Variable | Initial Value | Current Value |
|----------|---------------|---------------|
| baseUrl | http://localhost:8080 | http://localhost:8080 |
| accessToken | | (paste token here) |
| userId | 3 | 3 |
| adminToken | | (paste admin token here) |

4. **Save**
5. Chọn **Interview APIs** environment từ dropdown

6. Mỗi collection, set Authorization:
   - Type: **Bearer Token**
   - Token: `{{accessToken}}`

---

## 📊 BƯỚC 4: Test APIs

### Test 1: Get All Users (cần ADMIN token)

**Lấy ADMIN token:**
```json
POST /auth/login
{
  "email": "admin@example.com",
  "password": "password123"
}
```

**Test request:**
```
GET /users?page=0&size=10
Authorization: Bearer {{adminToken}}
```

### Test 2: Get Questions by Topic

```
GET /topics/1/questions?page=0&size=10
```

### Test 3: Get Exams by Type

```
GET /exams/type/TECHNICAL?page=0&size=10
```

### Test 4: Get News by Type

```
GET /news/type/NEWS?page=0&size=10
```

---

## 🎯 DANH SÁCH ENDPOINTS QUAN TRỌNG

### Auth Service (Port 8081)
- `POST /auth/register` - Đăng ký
- `POST /auth/login` - Đăng nhập (quan trọng!)
- `POST /auth/refresh` - Refresh token
- `GET /auth/verify` - Verify token
- `GET /auth/users/{id}` - Get user by ID

### User Service (Port 8082)
- `GET /users` - **Get all users** (ADMIN, paginated)
- `GET /users/{id}` - Get user by ID
- `GET /users/role/{roleId}` - Get users by role (ADMIN)
- `GET /users/status/{status}` - Get users by status (ADMIN)
- `PUT /users/{id}/role` - Update role (ADMIN)
- `PUT /users/{id}/status` - Update status (ADMIN)
- `POST /users/elo` - Apply ELO change

### Career Service (Port 8084)
- `POST /career` - Create preference
- `GET /career/{id}` - Get by ID
- `GET /career/preferences/{userId}` - **Get by user** (paginated)
- `PUT /career/update/{id}` - Update
- `DELETE /career/{id}` - Delete

### Question Service (Port 8085)
- `POST /fields` - Create field (ADMIN)
- `POST /topics` - Create topic (ADMIN)
- `POST /levels` - Create level (ADMIN)
- `POST /question-types` - Create question type (ADMIN)
- `POST /questions` - Create question
- `GET /questions/{id}` - Get question by ID
- `GET /topics/{topicId}/questions` - **List questions by topic** (paginated)
- `GET /questions/{questionId}/answers` - **List answers** (paginated)
- `POST /questions/{id}/approve` - Approve (ADMIN)
- `POST /questions/{id}/reject` - Reject (ADMIN)

### Exam Service (Port 8086)
- `POST /exams` - Create exam
- `GET /exams/{id}` - Get exam by ID
- `GET /exams/user/{userId}` - **Get exams by user** (paginated)
- `GET /exams/type/{examType}` - **Get exams by type** (paginated)
- `POST /exams/{examId}/publish` - Publish exam (ADMIN/RECRUITER)
- `POST /exams/{examId}/start` - Start exam
- `POST /exams/{examId}/complete` - Complete exam
- `POST /exams/registrations` - Register for exam
- `GET /exams/{examId}/registrations` - **Get registrations** (paginated, ADMIN)
- `GET /exams/registrations/user/{userId}` - **Get user registrations** (paginated)
- `GET /exams/{examId}/results` - **Get results** (paginated, ADMIN)
- `GET /exams/results/user/{userId}` - **Get user results** (paginated)

### News Service (Port 8087)
- `POST /news` - Create news
- `GET /news/{id}` - Get news by ID
- `GET /news/type/{newsType}` - **Get news by type** (paginated)
- `GET /news/user/{userId}` - **Get news by user** (paginated)
- `GET /news/status/{status}` - **Get news by status** (paginated, ADMIN)
- `GET /news/field/{fieldId}` - **Get news by field** (paginated)
- `GET /news/published/{newsType}` - **Get published news** (paginated)
- `GET /news/moderation/pending` - **Get pending moderation** (paginated, ADMIN)
- `POST /news/{newsId}/approve` - Approve (ADMIN)
- `POST /news/{newsId}/publish` - Publish (ADMIN)
- `POST /news/{newsId}/vote` - Vote

### Recruitment Controller (Port 8087)
- `POST /recruitments` - Create recruitment (RECRUITER/ADMIN)
- `GET /recruitments` - **List all recruitments** (paginated)
- `GET /recruitments/company/{companyName}` - Get by company (paginated)

---

## ⚠️ LƯU Ý VỀ PAGINATION

Tất cả GET ALL endpoints đều có pagination. Params:

```
?page=0&size=10&sort=id,asc
```

- `page`: Trang số (bắt đầu từ 0)
- `size`: Số items mỗi trang
- `sort`: Sắp xếp (field,direction)

**Response format:**
```json
{
  "content": [...],
  "pageable": {...},
  "totalPages": 5,
  "totalElements": 50,
  "size": 10,
  "number": 0
}
```

---

## 🔐 AUTHORIZATION REQUIREMENTS

### Public (không cần token):
- `POST /auth/login`
- `POST /auth/register`
- `GET /news/type/{newsType}`
- `GET /news/published/{newsType}`
- `GET /recruitments`
- `GET /topics/{topicId}/questions`

### USER role:
- Tất cả POST /questions, /answers
- POST /career
- POST /exams/registrations
- GET own data

### ADMIN role:
- Tất cả GET /users endpoints
- POST /fields, /topics, /levels, /question-types
- POST /questions/{id}/approve, /reject
- POST /news/{id}/approve, /publish
- DELETE operations

### RECRUITER role:
- POST /exams
- POST /recruitments
- GET /exams/{examId}/registrations

---

## 🧪 TEST SCENARIOS

### Scenario 1: User Registration & Login Flow

1. `POST /auth/register` - Tạo user mới
2. `POST /auth/login` - Login
3. `GET /users/{id}` - Get profile
4. `POST /career` - Tạo career preference
5. `GET /career/preferences/{userId}` - Xem preferences

### Scenario 2: Question Management Flow

1. Login as ADMIN
2. `POST /fields` - Tạo field
3. `POST /topics` - Tạo topic
4. Login as USER
5. `POST /questions` - Tạo question
6. Login as ADMIN
7. `POST /questions/{id}/approve` - Approve question
8. `GET /topics/{topicId}/questions` - Xem questions

### Scenario 3: Exam Taking Flow

1. Login as USER
2. `GET /exams/type/TECHNICAL` - Xem exams
3. `POST /exams/registrations` - Đăng ký
4. `POST /exams/{examId}/start` - Bắt đầu
5. `POST /exams/answers` - Submit answers
6. `POST /exams/results` - Submit result
7. `GET /exams/results/user/{userId}` - Xem kết quả

---

## 📝 SAMPLE DATA IDs

Sử dụng IDs từ database đã import:

- **Role IDs:** 1 (USER), 2 (RECRUITER), 3 (ADMIN)
- **User IDs:** 1-8 (xem bằng `GET /users`)
- **Field IDs:** 1-6
- **Topic IDs:** 1-25+
- **Question IDs:** 1-15+
- **Exam IDs:** 1-8+
- **News IDs:** 1-18+

---

## ✅ CHECKLIST

Import thành công khi:

- [ ] 6 collections được tạo trong Postman
- [ ] Environment "Interview APIs" đã setup
- [ ] Login thành công, nhận được token
- [ ] GET /users trả về danh sách users
- [ ] GET /topics/{topicId}/questions trả về questions
- [ ] GET /exams/type/TECHNICAL trả về exams
- [ ] GET /news/published/NEWS trả về news

---

**Created:** 2025-10-09  
**Status:** ✅ READY TO USE  
**Prefer này hơn file JSON tĩnh!**




