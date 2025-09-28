# 📋 HƯỚNG DẪN TEST POSTMAN - INTERVIEW MICROSERVICE ABC

## 🚀 CÁCH SỬ DỤNG

### 1. **Chuẩn bị Database**
```powershell
# Chạy script setup database
.\setup-database.ps1
```

### 2. **Import vào Postman**
1. Mở Postman
2. Click "Import" 
3. Chọn file `INTERVIEW_APIS.postman_collection.json`
4. Chọn file `POSTMAN_TEST_DATA.json` (để tham khảo dữ liệu mẫu)

### 3. **Cấu hình Environment**
- Base URL: `http://localhost:8080`
- Access Token sẽ được tự động lưu sau khi login

---

## 🔑 TÀI KHOẢN TEST

| Role | Email | Password | Mô tả |
|------|-------|----------|-------|
| **USER** | testuser1@example.com | password123 | Người dùng thường |
| **ADMIN** | admin@example.com | admin123 | Quản trị viên |
| **RECRUITER** | recruiter@example.com | recruiter123 | Nhà tuyển dụng |

---

## 📊 DANH SÁCH API THEO SERVICE

### 🔐 **Auth Service (4 APIs)**
- ✅ POST /auth/register - Đăng ký user
- ✅ POST /auth/login - Đăng nhập
- ✅ GET /auth/verify - Xác minh token
- ✅ GET /auth/users/{id} - Lấy thông tin user

### 👤 **User Service (6 APIs)**
- ✅ POST /users/register - Đăng ký user
- ✅ POST /users/login - Đăng nhập
- ✅ GET /users/{id} - Lấy thông tin user
- ✅ PUT /users/{id}/role - Cập nhật role
- ✅ PUT /users/{id}/status - Cập nhật status
- ✅ POST /users/elo - Áp dụng ELO score

### 🎯 **Career Service (5 APIs)**
- ✅ POST /career - Tạo career preference
- ✅ GET /career/{id} - Lấy career preference
- ✅ PUT /career/update/{id} - Cập nhật career preference
- ✅ GET /career/preferences/{userId} - Lấy danh sách preferences
- ✅ DELETE /career/{id} - Xóa career preference

### ❓ **Question Service (8 APIs)**
- ✅ POST /fields - Tạo field
- ✅ POST /topics - Tạo topic
- ✅ POST /levels - Tạo level
- ✅ POST /question-types - Tạo question type
- ✅ POST /questions - Tạo question
- ✅ GET /questions/{id} - Lấy question
- ✅ POST /questions/{id}/approve - Duyệt question
- ✅ POST /answers - Tạo answer

### 📝 **Exam Service (6 APIs)**
- ✅ POST /exams - Tạo exam
- ✅ GET /exams/{id} - Lấy exam
- ✅ POST /exams/{id}/publish - Xuất bản exam
- ✅ POST /exams/registrations - Đăng ký exam
- ✅ POST /exams/answers - Nộp bài
- ✅ POST /exams/results - Nộp kết quả

### 📰 **News Service (4 APIs)**
- ✅ POST /news - Tạo news
- ✅ GET /news/{id} - Lấy news
- ✅ POST /news/{id}/approve - Duyệt news
- ✅ POST /recruitments - Tạo recruitment

### 🤖 **NLP Service (3 APIs)**
- ✅ GET /health - Health check
- ✅ POST /questions/similarity/check - Kiểm tra similarity
- ✅ POST /grading/essay - Chấm điểm essay

---

## 🧪 CÁC SCENARIO TEST

### **Scenario 1: Complete User Flow**
1. Register user → Login → Get user info
2. Create career preference → Update → Delete
3. Create question → Approve → Create answer

### **Scenario 2: Exam Workflow**
1. Create exam → Publish → Register
2. Submit answers → Submit results
3. View results

### **Scenario 3: News Management**
1. Create news → Approve → Publish
2. Create recruitment → View recruitments

### **Scenario 4: NLP Testing**
1. Health check → Similarity check → Essay grading

---

## 📝 DỮ LIỆU MẪU

### **User Registration Data**
```json
{
  "email": "testuser1@example.com",
  "password": "password123",
  "fullName": "Test User 1",
  "roleId": 1,
  "dateOfBirth": "1995-01-15",
  "address": "123 Main Street, Ho Chi Minh City",
  "isStudying": false
}
```

### **Career Preference Data**
```json
{
  "userId": 1,
  "preferredFields": ["Software Engineering", "Data Science"],
  "experienceLevel": "INTERMEDIATE",
  "salaryExpectation": 50000,
  "locationPreference": "Ho Chi Minh City",
  "workType": "FULL_TIME",
  "skills": ["Java", "Spring Boot", "React"],
  "interests": ["Web Development", "AI/ML"]
}
```

### **Question Data**
```json
{
  "title": "What is the time complexity of binary search?",
  "content": "What is the time complexity of binary search algorithm?",
  "difficulty": "MEDIUM",
  "topicId": 1,
  "levelId": 1,
  "questionTypeId": 1,
  "createdBy": 1,
  "isMultipleChoice": true,
  "isOpenEnded": false,
  "options": [
    {"content": "O(n)", "isCorrect": false},
    {"content": "O(log n)", "isCorrect": true},
    {"content": "O(n²)", "isCorrect": false},
    {"content": "O(1)", "isCorrect": false}
  ]
}
```

---

## ⚠️ LƯU Ý QUAN TRỌNG

### **Trạng thái Services**
- ✅ **Career Service**: 100% hoạt động
- ⚠️ **Auth/User Services**: Có thể có lỗi 500
- ❌ **Question/News/NLP Services**: Có thể có lỗi 404 (routing)

### **Thứ tự Test**
1. Test Career Service trước (hoạt động tốt nhất)
2. Test Auth Service (có thể có lỗi)
3. Test các services khác theo thứ tự

### **Troubleshooting**
- Nếu gặp lỗi 404: Kiểm tra Gateway routing
- Nếu gặp lỗi 500: Kiểm tra service logs
- Nếu gặp lỗi 401: Kiểm tra authentication

---

## 🎯 KẾT QUẢ MONG ĐỢI

- **Career Service**: 100% success rate
- **Auth Service**: 50-75% success rate
- **Other Services**: 0-50% success rate (tùy thuộc vào routing)

**Tổng cộng: 30-40 APIs hoạt động tốt**
