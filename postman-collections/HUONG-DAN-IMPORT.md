# 📖 HƯỚNG DẪN IMPORT VÀ SỬ DỤNG POSTMAN COLLECTION

## 🎯 Hướng Dẫn Import vào Postman

### Bước 1: Mở Postman
1. Mở ứng dụng Postman trên máy tính
2. Nếu chưa có, tải Postman tại: https://www.postman.com/downloads/

### Bước 2: Import Collection
1. Nhấn nút **"Import"** ở góc trên bên trái
2. Chọn tab **"Upload Files"**
3. Kéo thả file `Interview-Microservice-ABC.postman_collection.json` hoặc nhấn **"Choose Files"** để chọn file
4. Nhấn **"Import"** để xác nhận
5. Collection sẽ xuất hiện ở sidebar bên trái với tên **"Interview Microservice ABC"**

![Import Process](https://i.imgur.com/example.png)

### Bước 3: Tạo Environment (Môi trường)
1. Nhấn vào icon bánh răng ⚙️ hoặc tab **"Environments"** ở sidebar
2. Nhấn **"+"** hoặc **"Create Environment"**
3. Đặt tên: `Interview Microservice ABC - Local`
4. Thêm các biến sau:

| Variable | Initial Value | Current Value |
|----------|--------------|---------------|
| `baseUrl` | `http://localhost:8080` | `http://localhost:8080` |
| `userId` | `3` | `3` |
| `adminId` | `1` | `1` |
| `questionId` | `1` | `1` |
| `answerId` | `1` | `1` |
| `examId` | `1` | `1` |
| `newsId` | `1` | `1` |
| `topicId` | `1` | `1` |
| `fieldId` | `1` | `1` |
| `userToken` | `` | `` |
| `adminToken` | `` | `` |
| `recruiterToken` | `` | `` |

5. Nhấn **"Save"** để lưu environment
6. Chọn environment vừa tạo từ dropdown ở góc phải trên

---

## 🗄️ Hướng Dẫn Import Database Sample Data

### Bước 1: Chuẩn Bị
1. Đảm bảo PostgreSQL đang chạy
2. Đảm bảo đã chạy file `init.sql` để tạo databases
3. Tắt tất cả microservices (nếu đang chạy)

### Bước 2: Import Data bằng PowerShell Script

**Cách 1: Sử dụng Script Tự Động (Khuyến nghị)**

1. Mở PowerShell trong thư mục `database-import`
2. Chỉnh sửa file `quick-import-data.ps1` - đổi password PostgreSQL:
   ```powershell
   $PG_PASSWORD = "password"  # Đổi thành password của bạn
   ```
3. Chạy script:
   ```powershell
   .\quick-import-data.ps1
   ```

**Cách 2: Import Thủ Công**

Chạy từng lệnh sau trong PowerShell/CMD:

```bash
# 1. Import Auth Database
psql -h localhost -U postgres -d authdb -f database-import/authdb-sample-data.sql

# 2. Import User Database
psql -h localhost -U postgres -d userdb -f database-import/userdb-sample-data.sql

# 3. Import Question Database
psql -h localhost -U postgres -d questiondb -f database-import/questiondb-sample-data.sql

# 4. Import Career Database
psql -h localhost -U postgres -d careerdb -f database-import/careerdb-sample-data.sql

# 5. Import Exam Database
psql -h localhost -U postgres -d examdb -f database-import/examdb-sample-data.sql

# 6. Import News Database
psql -h localhost -U postgres -d newsdb -f database-import/newsdb-sample-data.sql
```

**Lưu ý**: Nếu PowerShell yêu cầu nhập password, nhập password PostgreSQL của bạn.

### Bước 3: Kiểm Tra Data Đã Import

```sql
-- Kết nối PostgreSQL
psql -h localhost -U postgres

-- Kiểm tra từng database
\c userdb
SELECT COUNT(*) FROM users;  -- Nên có 6 users

\c questiondb
SELECT COUNT(*) FROM questions;  -- Nên có 10 questions
SELECT COUNT(*) FROM topics;     -- Nên có 25 topics

\c examdb
SELECT COUNT(*) FROM exams;      -- Nên có 6 exams

\c newsdb
SELECT COUNT(*) FROM news;       -- Nên có 13 news items
```

---

## 🚀 Hướng Dẫn Test API với Postman

### Bước 1: Khởi Động Hệ Thống
1. Khởi động tất cả microservices
2. Đảm bảo API Gateway chạy ở port 8080
3. Kiểm tra các services đã đăng ký với Eureka

### Bước 2: Lấy JWT Token để Test

#### A. Lấy Admin Token
1. Mở folder **"Auth Service"** hoặc **"User Service"**
2. Chọn request **"Login"** hoặc **"Login User"**
3. Trong tab **Body**, sử dụng dữ liệu admin:
   ```json
   {
     "email": "admin@example.com",
     "password": "password123"
   }
   ```
4. Nhấn **"Send"**
5. Copy token từ response (thường ở field `token` hoặc `accessToken`)
6. Mở **Environments** → Chọn environment của bạn
7. Paste token vào biến `adminToken`
8. **Save** environment

#### B. Lấy User Token
Làm tương tự với user thông thường:
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```
Copy token vào biến `userToken`

#### C. Lấy Recruiter Token
```json
{
  "email": "recruiter@example.com",
  "password": "password123"
}
```
Copy token vào biến `recruiterToken`

### Bước 3: Test Các API

#### Test 1: User Service
1. Mở folder **"User Service"** → **"Get User by ID"**
2. URL sẽ tự động dùng biến: `{{baseUrl}}/users/{{userId}}`
3. Nhấn **"Send"**
4. Sẽ nhận được thông tin user với ID = 3

#### Test 2: Question Service - Tạo Field (Admin)
1. Mở **"Question Service"** → **"Taxonomy Management"** → **"Create Field"**
2. Trong tab **Headers**, thêm:
   - Key: `Authorization`
   - Value: `Bearer {{adminToken}}`
3. Trong tab **Body**, sử dụng:
   ```json
   {
     "fieldName": "Mobile Development",
     "description": "Phát triển ứng dụng di động"
   }
   ```
4. Nhấn **"Send"**
5. Nếu thành công, sẽ nhận được response với field mới được tạo

#### Test 3: Exam Service - Tạo Exam
1. Mở **"Exam Service"** → **"Exam Management"** → **"Create Exam"**
2. Header: `Authorization: Bearer {{userToken}}`
3. Body:
   ```json
   {
     "userId": 1,
     "examType": "TECHNICAL",
     "title": "Test Exam for ReactJS",
     "position": "Frontend Developer",
     "topics": "[1,2,3]",
     "questionTypes": "[1,2]",
     "questionCount": 20,
     "duration": 60,
     "language": "en"
   }
   ```
4. Nhấn **"Send"**

---

## 📝 DỮ LIỆU MẪU ĐỂ TEST

### 1. Register User (Đăng ký User Mới)
**Endpoint**: `POST /users/register`

```json
{
  "email": "newuser@example.com",
  "password": "password123",
  "fullName": "Nguyễn Văn A",
  "dateOfBirth": "1995-05-20",
  "address": "123 Đường ABC, Quận 1, TP.HCM",
  "isStudying": true
}
```

### 2. Create Question (Tạo Câu Hỏi)
**Endpoint**: `POST /questions`
**Required**: User Token

```json
{
  "userId": 3,
  "topicId": 1,
  "fieldId": 1,
  "levelId": 2,
  "questionTypeId": 1,
  "questionContent": "React Hooks là gì? Liệt kê một số hooks phổ biến.",
  "questionAnswer": "React Hooks là các function cho phép sử dụng state và lifecycle trong function components. Các hooks phổ biến: useState, useEffect, useContext, useReducer, useCallback, useMemo.",
  "language": "vi"
}
```

### 3. Create Answer (Tạo Câu Trả Lời)
**Endpoint**: `POST /answers`
**Required**: User Token

```json
{
  "userId": 3,
  "questionId": 1,
  "questionTypeId": 1,
  "answerContent": "React Hooks là các function đặc biệt cho phép sử dụng state và các tính năng của React trong function components. Các hooks phổ biến bao gồm useState, useEffect, useContext, useReducer.",
  "isCorrect": true,
  "orderNumber": 1
}
```

### 4. Create Exam (Tạo Bài Thi)
**Endpoint**: `POST /exams`
**Required**: User/Admin/Recruiter Token

```json
{
  "userId": 1,
  "examType": "TECHNICAL",
  "title": "Kiểm Tra ReactJS Cơ Bản",
  "position": "Junior Frontend Developer",
  "topics": "[1]",
  "questionTypes": "[1,2]",
  "questionCount": 15,
  "duration": 45,
  "language": "vi"
}
```

### 5. Submit User Answer (Nộp Câu Trả Lời)
**Endpoint**: `POST /exams/answers`
**Required**: User Token

```json
{
  "examId": 1,
  "questionId": 1,
  "userId": 3,
  "answerContent": "ReactJS là thư viện JavaScript để xây dựng giao diện người dùng với các tính năng như Virtual DOM và component-based architecture.",
  "isCorrect": true
}
```

### 6. Submit Exam Result (Nộp Kết Quả Thi)
**Endpoint**: `POST /exams/results`
**Required**: User Token

```json
{
  "examId": 1,
  "userId": 3,
  "score": 85.5,
  "passStatus": true,
  "feedback": "Làm bài tốt, hiểu rõ các khái niệm cơ bản về ReactJS"
}
```

### 7. Create Career Preference (Tạo Sở Thích Nghề Nghiệp)
**Endpoint**: `POST /career`
**Required**: User Token

```json
{
  "userId": 3,
  "fieldId": 1,
  "topicId": 1
}
```

### 8. Create News (Tạo Tin Tức)
**Endpoint**: `POST /news`
**Required**: User Token

```json
{
  "userId": 3,
  "title": "Khóa Học ReactJS Miễn Phí",
  "content": "Giới thiệu khóa học ReactJS từ cơ bản đến nâng cao hoàn toàn miễn phí cho sinh viên và người đi làm muốn chuyển đổi nghề nghiệp.",
  "fieldId": 1,
  "newsType": "NEWS"
}
```

### 9. Create Recruitment (Tạo Tin Tuyển Dụng)
**Endpoint**: `POST /recruitments`
**Required**: Recruiter Token

```json
{
  "userId": 2,
  "title": "Tuyển Dụng Senior ReactJS Developer",
  "content": "Công ty chúng tôi đang tìm kiếm Senior ReactJS Developer với kinh nghiệm 3 năm trở lên. Mức lương hấp dẫn, môi trường làm việc chuyên nghiệp.",
  "fieldId": 1,
  "newsType": "RECRUITMENT",
  "companyName": "Công Ty TNHH ABC Tech",
  "location": "Quận 1, TP. Hồ Chí Minh",
  "salary": "2000-3000 USD",
  "experience": "3-5 năm",
  "position": "Senior ReactJS Developer",
  "workingHours": "9h-18h, T2-T6",
  "deadline": "2024-12-31",
  "applicationMethod": "Gửi CV về email: hr@abctech.com hoặc apply qua website"
}
```

### 10. Register for Exam (Đăng Ký Thi)
**Endpoint**: `POST /exams/registrations`
**Required**: User Token

```json
{
  "examId": 1,
  "userId": 3
}
```

---

## 🔑 DANH SÁCH TÀI KHOẢN TEST

### Admin Account
```
Email: admin@example.com
Password: password123
Role: ADMIN
Status: ACTIVE
```
**Quyền hạn**: Toàn bộ hệ thống, approve/reject questions, news, exams

### Recruiter Account
```
Email: recruiter@example.com
Password: password123
Role: RECRUITER
Status: ACTIVE
```
**Quyền hạn**: Tạo exam, recruitment posts, publish exams

### User Accounts

**User 1 (Regular User)**
```
Email: user@example.com
Password: password123
Role: USER
Status: ACTIVE
ELO Score: 1200
ELO Rank: BRONZE
```

**User 2 (Test User - Pending)**
```
Email: test@example.com
Password: password123
Role: USER
Status: PENDING
ELO Score: 800
```

**User 3 (Student)**
```
Email: student@example.com
Password: password123
Role: USER
Status: ACTIVE
ELO Score: 950
```

**User 4 (Developer)**
```
Email: developer@example.com
Password: password123
Role: USER
Status: ACTIVE
ELO Score: 1500
ELO Rank: SILVER
```

---

## 🎨 TIPS VÀ TRICKS

### 1. Sử dụng Variables Hiệu Quả
- Luôn dùng `{{variableName}}` trong URL và Body
- Tạo nhiều environments cho dev/staging/production
- Dùng Pre-request Scripts để tự động set variables

### 2. Test Nhanh với Collection Runner
1. Nhấn chuột phải vào folder
2. Chọn **"Run folder"**
3. Chọn environment và nhấn **"Run"**
4. Postman sẽ chạy toàn bộ requests trong folder

### 3. Save Response vào Variables
Trong tab **Tests** của request:
```javascript
// Save token from response
pm.environment.set("userToken", pm.response.json().token);

// Save ID from response
pm.environment.set("userId", pm.response.json().id);
```

### 4. Kiểm Tra Response với Tests
```javascript
// Check status code
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

// Check response body
pm.test("Response has token", function () {
    pm.expect(pm.response.json()).to.have.property('token');
});
```

---

## ❗ XỬ LÝ LỖI THƯỜNG GẶP

### Lỗi 401 Unauthorized
**Nguyên nhân**: Token hết hạn hoặc không hợp lệ
**Giải pháp**: 
1. Login lại để lấy token mới
2. Update token vào environment variables

### Lỗi 403 Forbidden
**Nguyên nhân**: Không đủ quyền (VD: user thường không thể approve question)
**Giải pháp**: Sử dụng token của admin hoặc recruiter

### Lỗi 404 Not Found
**Nguyên nhân**: ID không tồn tại trong database
**Giải pháp**: Kiểm tra ID trong database hoặc dùng ID từ sample data

### Lỗi 500 Internal Server Error
**Nguyên nhân**: Lỗi server hoặc data không hợp lệ
**Giải pháp**: 
1. Kiểm tra logs của microservice
2. Verify request body format
3. Kiểm tra database constraints

---

## 📊 WORKFLOW TEST HOÀN CHỈNH

### Scenario 1: User Registration → Take Exam → Get Results

```
1. POST /users/register → Đăng ký user mới
2. POST /users/login → Login để lấy token
3. GET /exams/type/TECHNICAL → Xem danh sách exam
4. POST /exams/registrations → Đăng ký tham gia exam
5. POST /exams/{examId}/start → Bắt đầu làm bài
6. POST /exams/answers → Nộp từng câu trả lời
7. POST /exams/{examId}/complete → Hoàn thành exam
8. POST /exams/results → Nộp kết quả
9. GET /exams/results/user/{userId} → Xem kết quả
```

### Scenario 2: Admin Create Question → User Answer → Get Voted

```
1. POST /auth/login (admin) → Login admin
2. POST /fields → Tạo field mới
3. POST /topics → Tạo topic mới
4. POST /questions → Tạo question
5. POST /questions/{id}/approve → Approve question
6. POST /answers → User tạo answer
7. POST /answers/{id}/sample → Admin đánh dấu sample answer
```

---

## 🎯 KẾT LUẬN

Bây giờ bạn đã có đầy đủ:
- ✅ Postman Collection với tất cả API
- ✅ Sample data trong database
- ✅ Hướng dẫn chi tiết cách test
- ✅ Dữ liệu mẫu để copy-paste
- ✅ Tài khoản test với các role khác nhau

Chúc bạn test thành công! 🚀
