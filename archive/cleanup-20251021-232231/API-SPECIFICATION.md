# 📚 ĐẶC TẢ CHI TIẾT API - INTERVIEW MICROSERVICE ABC

## Mục Lục
- [1. Auth Service API](#1-auth-service-api)
- [2. User Service API](#2-user-service-api)
- [3. Question Service API](#3-question-service-api)
- [4. Exam Service API](#4-exam-service-api)
- [5. Career Service API](#5-career-service-api)
- [6. News Service API](#6-news-service-api)
- [7. NLP Service API](#7-nlp-service-api)
- [8. Data Models](#8-data-models)
- [9. Error Codes](#9-error-codes)

---

# 1. Auth Service API

Base URL: `http://localhost:8080/auth`

## 1.1. Register User

**Endpoint:** `POST /auth/register`

**Mô tả:** Đăng ký tài khoản người dùng mới

**Authentication:** Không yêu cầu

**Request Body:**
```json
{
  "email": "string (required, email format)",
  "password": "string (required, min 8 characters)",
  "fullName": "string (required)",
  "roleName": "string (required, values: USER|RECRUITER|ADMIN)"
}
```

**Response Success (201 Created):**
```json
{
  "id": 1,
  "email": "user@example.com",
  "fullName": "John Doe",
  "role": "USER",
  "status": "PENDING",
  "createdAt": "2024-01-15T10:30:00"
}
```

**Response Error (400 Bad Request):**
```json
{
  "timestamp": "2024-01-15T10:30:00",
  "status": 400,
  "error": "Bad Request",
  "message": "Email already exists",
  "path": "/auth/register"
}
```

**Validation Rules:**
- Email phải unique và đúng format
- Password tối thiểu 8 ký tự
- FullName không được rỗng
- RoleName phải là một trong: USER, RECRUITER, ADMIN

---

## 1.2. Login

**Endpoint:** `POST /auth/login`

**Mô tả:** Đăng nhập và nhận JWT token

**Authentication:** Không yêu cầu

**Request Body:**
```json
{
  "email": "string (required)",
  "password": "string (required)"
}
```

**Response Success (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "tokenType": "Bearer",
  "expiresIn": 3600,
  "user": {
    "id": 1,
    "email": "user@example.com",
    "fullName": "John Doe",
    "role": "USER"
  }
}
```

**Response Error (401 Unauthorized):**
```json
{
  "timestamp": "2024-01-15T10:30:00",
  "status": 401,
  "error": "Unauthorized",
  "message": "Invalid email or password",
  "path": "/auth/login"
}
```

---

## 1.3. Refresh Token

**Endpoint:** `POST /auth/refresh`

**Mô tả:** Làm mới access token bằng refresh token

**Authentication:** Không yêu cầu

**Request Body:**
```json
{
  "refreshToken": "string (required)"
}
```

**Response Success (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "tokenType": "Bearer",
  "expiresIn": 3600
}
```

---

## 1.4. Verify Token

**Endpoint:** `GET /auth/verify`

**Mô tả:** Xác thực JWT token

**Authentication:** Không yêu cầu

**Query Parameters:**
- `token` (string, required): JWT token cần verify

**Response Success (200 OK):**
```json
{
  "valid": true,
  "userId": 1,
  "email": "user@example.com",
  "role": "USER",
  "expiresAt": "2024-01-15T11:30:00"
}
```

---

## 1.5. Get User by ID

**Endpoint:** `GET /auth/users/{id}`

**Mô tả:** Lấy thông tin user theo ID

**Authentication:** Không yêu cầu

**Path Parameters:**
- `id` (long, required): User ID

**Response Success (200 OK):**
```json
{
  "id": 1,
  "email": "user@example.com",
  "fullName": "John Doe",
  "role": "USER",
  "status": "ACTIVE",
  "createdAt": "2024-01-15T10:30:00"
}
```

---

# 2. User Service API

Base URL: `http://localhost:8080/users`

## 2.1. Register User

**Endpoint:** `POST /users/register`

**Mô tả:** Đăng ký user với thông tin chi tiết

**Authentication:** Không yêu cầu

**Request Body:**
```json
{
  "email": "string (required, email format)",
  "password": "string (required, min 8 characters)",
  "fullName": "string (required, max 100 characters)",
  "dateOfBirth": "date (optional, format: YYYY-MM-DD)",
  "address": "string (optional, max 255 characters)",
  "isStudying": "boolean (optional)"
}
```

**Response Success (201 Created):**
```json
{
  "id": 1,
  "email": "user@example.com",
  "fullName": "Nguyễn Văn A",
  "dateOfBirth": "1995-05-20",
  "address": "123 Đường ABC, Quận 1, TP.HCM",
  "status": "PENDING",
  "isStudying": true,
  "eloScore": 0,
  "eloRank": "NEWBIE",
  "role": {
    "id": 1,
    "roleName": "USER"
  },
  "createdAt": "2024-01-15T10:30:00"
}
```

---

## 2.2. Get User by ID

**Endpoint:** `GET /users/{id}`

**Mô tả:** Lấy thông tin chi tiết user

**Authentication:** Không yêu cầu

**Path Parameters:**
- `id` (long, required): User ID

**Response Success (200 OK):**
```json
{
  "id": 1,
  "email": "user@example.com",
  "fullName": "Nguyễn Văn A",
  "dateOfBirth": "1995-05-20",
  "address": "123 Đường ABC, Quận 1, TP.HCM",
  "status": "ACTIVE",
  "isStudying": true,
  "eloScore": 1200,
  "eloRank": "BRONZE",
  "role": {
    "id": 1,
    "roleName": "USER"
  },
  "createdAt": "2024-01-15T10:30:00"
}
```

---

## 2.3. Login

**Endpoint:** `POST /users/login`

**Mô tả:** Đăng nhập user

**Authentication:** Không yêu cầu

**Request Body:**
```json
{
  "email": "string (required)",
  "password": "string (required)"
}
```

**Response Success (200 OK):**
```json
{
  "id": 1,
  "email": "user@example.com",
  "fullName": "Nguyễn Văn A",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "role": "USER",
  "eloScore": 1200,
  "eloRank": "BRONZE"
}
```

---

## 2.4. Verify User Email

**Endpoint:** `GET /users/verify`

**Mô tả:** Xác thực email user

**Authentication:** Không yêu cầu

**Query Parameters:**
- `token` (string, required): Verification token

**Response Success (200 OK):**
```json
{
  "id": 1,
  "email": "user@example.com",
  "status": "ACTIVE",
  "message": "Email verified successfully"
}
```

---

## 2.5. Update User Role

**Endpoint:** `PUT /users/{id}/role`

**Mô tả:** Cập nhật role của user (Admin only)

**Authentication:** Required (Admin)

**Headers:**
```
Authorization: Bearer {adminToken}
```

**Path Parameters:**
- `id` (long, required): User ID

**Request Body:**
```json
{
  "roleName": "string (required, values: USER|RECRUITER|ADMIN)"
}
```

**Response Success (200 OK):**
```json
{
  "id": 1,
  "email": "user@example.com",
  "fullName": "Nguyễn Văn A",
  "role": {
    "id": 2,
    "roleName": "RECRUITER"
  },
  "updatedAt": "2024-01-15T11:00:00"
}
```

---

## 2.6. Update User Status

**Endpoint:** `PUT /users/{id}/status`

**Mô tả:** Cập nhật trạng thái user (Admin only)

**Authentication:** Required (Admin)

**Headers:**
```
Authorization: Bearer {adminToken}
```

**Path Parameters:**
- `id` (long, required): User ID

**Request Body:**
```json
{
  "status": "string (required, values: PENDING|ACTIVE|INACTIVE|BANNED)"
}
```

**Response Success (200 OK):**
```json
{
  "id": 1,
  "email": "user@example.com",
  "status": "ACTIVE",
  "updatedAt": "2024-01-15T11:00:00"
}
```

---

## 2.7. Apply ELO Score

**Endpoint:** `POST /users/elo`

**Mô tả:** Cộng/trừ điểm ELO cho user

**Authentication:** Required

**Request Body:**
```json
{
  "userId": "long (required)",
  "action": "string (required)",
  "points": "integer (required)",
  "description": "string (optional)"
}
```

**Response Success (200 OK):**
```json
{
  "id": 1,
  "email": "user@example.com",
  "eloScore": 1250,
  "eloRank": "BRONZE",
  "history": {
    "id": 10,
    "action": "EXAM_COMPLETED",
    "points": 50,
    "description": "Completed ReactJS exam successfully",
    "createdAt": "2024-01-15T11:00:00"
  }
}
```

**ELO Ranks:**
- NEWBIE: 0-999
- BRONZE: 1000-1499
- SILVER: 1500-1999
- GOLD: 2000-2499
- PLATINUM: 2500-2999
- DIAMOND: 3000+

---

# 3. Question Service API

Base URL: `http://localhost:8080`

## 3.1. Field Management

### 3.1.1. Create Field

**Endpoint:** `POST /fields`

**Mô tả:** Tạo field/lĩnh vực mới (Admin only)

**Authentication:** Required (Admin)

**Request Body:**
```json
{
  "fieldName": "string (required, max 100 characters)",
  "description": "string (optional)"
}
```

**Response Success (201 Created):**
```json
{
  "id": 1,
  "fieldName": "Lập trình viên",
  "description": "Ngành lập trình phần mềm",
  "createdAt": "2024-01-15T10:30:00"
}
```

---

## 3.2. Topic Management

### 3.2.1. Create Topic

**Endpoint:** `POST /topics`

**Mô tả:** Tạo topic/chủ đề mới (Admin only)

**Authentication:** Required (Admin)

**Request Body:**
```json
{
  "fieldId": "long (required)",
  "topicName": "string (required, max 100 characters)",
  "description": "string (optional)"
}
```

**Response Success (201 Created):**
```json
{
  "id": 1,
  "field": {
    "id": 1,
    "fieldName": "Lập trình viên"
  },
  "topicName": "ReactJS",
  "description": "Thư viện JavaScript cho UI",
  "createdAt": "2024-01-15T10:30:00"
}
```

---

## 3.3. Level Management

### 3.3.1. Create Level

**Endpoint:** `POST /levels`

**Mô tả:** Tạo level/cấp độ mới (Admin only)

**Authentication:** Required (Admin)

**Request Body:**
```json
{
  "levelName": "string (required, max 50 characters)",
  "description": "string (optional)"
}
```

**Response Success (201 Created):**
```json
{
  "id": 1,
  "levelName": "Junior",
  "description": "1-2 năm kinh nghiệm",
  "createdAt": "2024-01-15T10:30:00"
}
```

**Levels:**
- Fresher (0-1 year)
- Junior (1-2 years)
- Middle (2-4 years)
- Senior (4+ years)
- Lead (5+ years)
- Architect (7+ years)

---

## 3.4. Question Type Management

### 3.4.1. Create Question Type

**Endpoint:** `POST /question-types`

**Mô tả:** Tạo loại câu hỏi mới (Admin only)

**Authentication:** Required (Admin)

**Request Body:**
```json
{
  "questionTypeName": "string (required, max 100 characters)",
  "description": "string (optional)"
}
```

**Response Success (201 Created):**
```json
{
  "id": 1,
  "questionTypeName": "Multiple Choice",
  "description": "Câu hỏi trắc nghiệm",
  "createdAt": "2024-01-15T10:30:00"
}
```

**Question Types:**
- Multiple Choice (Trắc nghiệm)
- Open Ended (Tự luận)
- True/False (Đúng/Sai)
- Fill in the Blank (Điền vào chỗ trống)
- Code Review (Review code)
- System Design (Thiết kế hệ thống)
- Algorithm (Thuật toán)
- Database Design (Thiết kế CSDL)

---

## 3.5. Question Management

### 3.5.1. Create Question

**Endpoint:** `POST /questions`

**Mô tả:** Tạo câu hỏi mới

**Authentication:** Required (User/Admin)

**Request Body:**
```json
{
  "userId": "long (required)",
  "topicId": "long (required)",
  "fieldId": "long (required)",
  "levelId": "long (required)",
  "questionTypeId": "long (required)",
  "questionContent": "string (required)",
  "questionAnswer": "string (optional)",
  "language": "string (optional, default: vi, values: vi|en)"
}
```

**Response Success (201 Created):**
```json
{
  "id": 1,
  "user": {
    "id": 3,
    "fullName": "Nguyễn Văn A"
  },
  "topic": {
    "id": 1,
    "topicName": "ReactJS"
  },
  "field": {
    "id": 1,
    "fieldName": "Lập trình viên"
  },
  "level": {
    "id": 2,
    "levelName": "Junior"
  },
  "questionType": {
    "id": 1,
    "questionTypeName": "Multiple Choice"
  },
  "questionContent": "What is ReactJS and what are its main features?",
  "questionAnswer": "ReactJS is a JavaScript library for building user interfaces...",
  "similarityScore": 0.0,
  "status": "PENDING",
  "language": "en",
  "usefulVote": 0,
  "unusefulVote": 0,
  "createdAt": "2024-01-15T10:30:00"
}
```

**Question Status:**
- PENDING: Chờ duyệt
- APPROVED: Đã duyệt
- REJECTED: Bị từ chối

---

### 3.5.2. Get Question by ID

**Endpoint:** `GET /questions/{id}`

**Mô tả:** Lấy chi tiết câu hỏi

**Authentication:** Không yêu cầu

**Path Parameters:**
- `id` (long, required): Question ID

**Response Success (200 OK):**
```json
{
  "id": 1,
  "user": {
    "id": 3,
    "fullName": "Nguyễn Văn A"
  },
  "topic": {
    "id": 1,
    "topicName": "ReactJS",
    "field": {
      "id": 1,
      "fieldName": "Lập trình viên"
    }
  },
  "level": {
    "id": 2,
    "levelName": "Junior"
  },
  "questionType": {
    "id": 1,
    "questionTypeName": "Multiple Choice"
  },
  "questionContent": "What is ReactJS and what are its main features?",
  "questionAnswer": "ReactJS is a JavaScript library for building user interfaces...",
  "similarityScore": 0.0,
  "status": "APPROVED",
  "language": "en",
  "usefulVote": 15,
  "unusefulVote": 2,
  "createdAt": "2024-01-15T10:30:00",
  "approvedAt": "2024-01-15T11:00:00",
  "approvedBy": {
    "id": 1,
    "fullName": "Admin User"
  }
}
```

---

### 3.5.3. Update Question

**Endpoint:** `PUT /questions/{id}`

**Mô tả:** Cập nhật câu hỏi

**Authentication:** Required (User/Admin)

**Path Parameters:**
- `id` (long, required): Question ID

**Request Body:**
```json
{
  "userId": "long (required)",
  "topicId": "long (required)",
  "fieldId": "long (required)",
  "levelId": "long (required)",
  "questionTypeId": "long (required)",
  "questionContent": "string (required)",
  "questionAnswer": "string (optional)",
  "language": "string (optional)"
}
```

**Response Success (200 OK):**
```json
{
  "id": 1,
  "questionContent": "Updated question content",
  "updatedAt": "2024-01-15T12:00:00"
}
```

---

### 3.5.4. Delete Question

**Endpoint:** `DELETE /questions/{id}`

**Mô tả:** Xóa câu hỏi (Admin only)

**Authentication:** Required (Admin)

**Path Parameters:**
- `id` (long, required): Question ID

**Response Success (204 No Content)**

---

### 3.5.5. Approve Question

**Endpoint:** `POST /questions/{id}/approve`

**Mô tả:** Duyệt câu hỏi (Admin only)

**Authentication:** Required (Admin)

**Path Parameters:**
- `id` (long, required): Question ID

**Query Parameters:**
- `adminId` (long, required): Admin user ID

**Response Success (200 OK):**
```json
{
  "id": 1,
  "status": "APPROVED",
  "approvedAt": "2024-01-15T11:00:00",
  "approvedBy": {
    "id": 1,
    "fullName": "Admin User"
  }
}
```

---

### 3.5.6. Reject Question

**Endpoint:** `POST /questions/{id}/reject`

**Mô tả:** Từ chối câu hỏi (Admin only)

**Authentication:** Required (Admin)

**Path Parameters:**
- `id` (long, required): Question ID

**Query Parameters:**
- `adminId` (long, required): Admin user ID

**Response Success (200 OK):**
```json
{
  "id": 1,
  "status": "REJECTED",
  "approvedAt": "2024-01-15T11:00:00",
  "approvedBy": {
    "id": 1,
    "fullName": "Admin User"
  }
}
```

---

### 3.5.7. List Questions by Topic

**Endpoint:** `GET /topics/{topicId}/questions`

**Mô tả:** Lấy danh sách câu hỏi theo topic

**Authentication:** Không yêu cầu

**Path Parameters:**
- `topicId` (long, required): Topic ID

**Query Parameters:**
- `page` (int, optional, default: 0): Page number
- `size` (int, optional, default: 10): Page size
- `sort` (string, optional): Sort field and direction (e.g., "createdAt,desc")

**Response Success (200 OK):**
```json
{
  "content": [
    {
      "id": 1,
      "questionContent": "What is ReactJS?",
      "status": "APPROVED",
      "usefulVote": 15,
      "level": "Junior",
      "createdAt": "2024-01-15T10:30:00"
    }
  ],
  "pageable": {
    "pageNumber": 0,
    "pageSize": 10,
    "sort": {
      "sorted": true,
      "unsorted": false
    }
  },
  "totalPages": 5,
  "totalElements": 50,
  "last": false,
  "first": true,
  "numberOfElements": 10
}
```

---

## 3.6. Answer Management

### 3.6.1. Create Answer

**Endpoint:** `POST /answers`

**Mô tả:** Tạo câu trả lời cho câu hỏi

**Authentication:** Required (User/Admin)

**Request Body:**
```json
{
  "userId": "long (required)",
  "questionId": "long (required)",
  "questionTypeId": "long (required)",
  "answerContent": "string (required)",
  "isCorrect": "boolean (optional)",
  "orderNumber": "integer (optional)"
}
```

**Response Success (201 Created):**
```json
{
  "id": 1,
  "user": {
    "id": 3,
    "fullName": "Nguyễn Văn A"
  },
  "question": {
    "id": 1,
    "questionContent": "What is ReactJS?"
  },
  "questionType": {
    "id": 1,
    "questionTypeName": "Multiple Choice"
  },
  "answerContent": "ReactJS is a JavaScript library for building user interfaces",
  "isCorrect": true,
  "similarityScore": 0.0,
  "usefulVote": 0,
  "unusefulVote": 0,
  "isSampleAnswer": false,
  "orderNumber": 1,
  "createdAt": "2024-01-15T10:30:00"
}
```

---

### 3.6.2. Get Answer by ID

**Endpoint:** `GET /answers/{id}`

**Mô tả:** Lấy chi tiết câu trả lời

**Authentication:** Không yêu cầu

**Path Parameters:**
- `id` (long, required): Answer ID

**Response Success (200 OK):**
```json
{
  "id": 1,
  "user": {
    "id": 3,
    "fullName": "Nguyễn Văn A"
  },
  "question": {
    "id": 1,
    "questionContent": "What is ReactJS?"
  },
  "answerContent": "ReactJS is a JavaScript library for building user interfaces",
  "isCorrect": true,
  "usefulVote": 8,
  "unusefulVote": 1,
  "isSampleAnswer": true,
  "createdAt": "2024-01-15T10:30:00"
}
```

---

### 3.6.3. Update Answer

**Endpoint:** `PUT /answers/{id}`

**Mô tả:** Cập nhật câu trả lời

**Authentication:** Required (User/Admin)

**Path Parameters:**
- `id` (long, required): Answer ID

**Request Body:**
```json
{
  "userId": "long (required)",
  "questionId": "long (required)",
  "questionTypeId": "long (required)",
  "answerContent": "string (required)",
  "isCorrect": "boolean (optional)",
  "orderNumber": "integer (optional)"
}
```

**Response Success (200 OK):**
```json
{
  "id": 1,
  "answerContent": "Updated answer content",
  "updatedAt": "2024-01-15T12:00:00"
}
```

---

### 3.6.4. Delete Answer

**Endpoint:** `DELETE /answers/{id}`

**Mô tả:** Xóa câu trả lời (Admin only)

**Authentication:** Required (Admin)

**Path Parameters:**
- `id` (long, required): Answer ID

**Response Success (204 No Content)**

---

### 3.6.5. Mark Sample Answer

**Endpoint:** `POST /answers/{id}/sample`

**Mô tả:** Đánh dấu câu trả lời mẫu (Admin only)

**Authentication:** Required (Admin)

**Path Parameters:**
- `id` (long, required): Answer ID

**Query Parameters:**
- `isSample` (boolean, required): true để đánh dấu, false để bỏ đánh dấu

**Response Success (200 OK):**
```json
{
  "id": 1,
  "answerContent": "Sample answer content",
  "isSampleAnswer": true,
  "updatedAt": "2024-01-15T11:00:00"
}
```

---

### 3.6.6. List Answers by Question

**Endpoint:** `GET /questions/{questionId}/answers`

**Mô tả:** Lấy danh sách câu trả lời cho câu hỏi

**Authentication:** Không yêu cầu

**Path Parameters:**
- `questionId` (long, required): Question ID

**Query Parameters:**
- `page` (int, optional, default: 0): Page number
- `size` (int, optional, default: 10): Page size

**Response Success (200 OK):**
```json
{
  "content": [
    {
      "id": 1,
      "user": {
        "id": 3,
        "fullName": "Nguyễn Văn A"
      },
      "answerContent": "ReactJS is a JavaScript library...",
      "isCorrect": true,
      "usefulVote": 8,
      "isSampleAnswer": true,
      "createdAt": "2024-01-15T10:30:00"
    }
  ],
  "totalElements": 5,
  "totalPages": 1
}
```

---

# 4. Exam Service API

Base URL: `http://localhost:8080/exams`

## 4.1. Exam Management

### 4.1.1. Create Exam

**Endpoint:** `POST /exams`

**Mô tả:** Tạo bài thi mới

**Authentication:** Required (User/Admin/Recruiter)

**Request Body:**
```json
{
  "userId": "long (required)",
  "examType": "string (required, values: TECHNICAL|BEHAVIORAL|APTITUDE)",
  "title": "string (required, max 255 characters)",
  "position": "string (optional, max 100 characters)",
  "topics": "string (optional, JSON array of topic IDs)",
  "questionTypes": "string (optional, JSON array of question type IDs)",
  "questionCount": "integer (optional)",
  "duration": "integer (optional, in minutes)",
  "language": "string (optional, default: vi, values: vi|en)"
}
```

**Response Success (201 Created):**
```json
{
  "id": 1,
  "user": {
    "id": 1,
    "fullName": "Admin User"
  },
  "examType": "TECHNICAL",
  "title": "ReactJS Developer Assessment",
  "position": "Frontend Developer",
  "topics": "[1,2,3]",
  "questionTypes": "[1,2]",
  "questionCount": 20,
  "duration": 60,
  "startTime": null,
  "endTime": null,
  "status": "DRAFT",
  "language": "en",
  "createdAt": "2024-01-15T10:30:00",
  "createdBy": 1
}
```

**Exam Types:**
- TECHNICAL: Kỹ thuật
- BEHAVIORAL: Hành vi
- APTITUDE: Năng lực

**Exam Status:**
- DRAFT: Nháp
- PUBLISHED: Đã publish
- IN_PROGRESS: Đang diễn ra
- COMPLETED: Đã hoàn thành
- CANCELLED: Đã hủy

---

### 4.1.2. Get Exam by ID

**Endpoint:** `GET /exams/{id}`

**Mô tả:** Lấy chi tiết bài thi

**Authentication:** Không yêu cầu

**Path Parameters:**
- `id` (long, required): Exam ID

**Response Success (200 OK):**
```json
{
  "id": 1,
  "user": {
    "id": 1,
    "fullName": "Admin User"
  },
  "examType": "TECHNICAL",
  "title": "ReactJS Developer Assessment",
  "position": "Frontend Developer",
  "topics": "[1,2,3]",
  "questionTypes": "[1,2]",
  "questionCount": 20,
  "duration": 60,
  "startTime": "2024-01-22T09:00:00",
  "endTime": "2024-01-22T10:00:00",
  "status": "PUBLISHED",
  "language": "en",
  "createdAt": "2024-01-15T10:30:00"
}
```

---

### 4.1.3. Update Exam

**Endpoint:** `PUT /exams/{id}`

**Mô tả:** Cập nhật bài thi

**Authentication:** Required (Admin/Recruiter)

**Path Parameters:**
- `id` (long, required): Exam ID

**Request Body:** (Same as Create Exam)

**Response Success (200 OK):**
```json
{
  "id": 1,
  "title": "Updated exam title",
  "updatedAt": "2024-01-15T12:00:00"
}
```

---

### 4.1.4. Delete Exam

**Endpoint:** `DELETE /exams/{id}`

**Mô tả:** Xóa bài thi

**Authentication:** Required (Admin/Recruiter)

**Path Parameters:**
- `id` (long, required): Exam ID

**Response Success (204 No Content)**

---

### 4.1.5. Publish Exam

**Endpoint:** `POST /exams/{examId}/publish`

**Mô tả:** Publish bài thi để cho phép users tham gia

**Authentication:** Required (Admin/Recruiter)

**Path Parameters:**
- `examId` (long, required): Exam ID

**Query Parameters:**
- `userId` (long, required): User ID của người publish

**Response Success (200 OK):**
```json
{
  "id": 1,
  "status": "PUBLISHED",
  "publishedAt": "2024-01-15T11:00:00",
  "publishedBy": {
    "id": 1,
    "fullName": "Admin User"
  }
}
```

---

### 4.1.6. Start Exam

**Endpoint:** `POST /exams/{examId}/start`

**Mô tả:** Bắt đầu làm bài thi

**Authentication:** Required (User/Admin)

**Path Parameters:**
- `examId` (long, required): Exam ID

**Response Success (200 OK):**
```json
{
  "id": 1,
  "status": "IN_PROGRESS",
  "startTime": "2024-01-15T11:00:00",
  "endTime": "2024-01-15T12:00:00"
}
```

---

### 4.1.7. Complete Exam

**Endpoint:** `POST /exams/{examId}/complete`

**Mô tả:** Hoàn thành bài thi

**Authentication:** Required (User/Admin)

**Path Parameters:**
- `examId` (long, required): Exam ID

**Response Success (200 OK):**
```json
{
  "id": 1,
  "status": "COMPLETED",
  "completedAt": "2024-01-15T11:45:00"
}
```

---

### 4.1.8. List Exams by User

**Endpoint:** `GET /exams/user/{userId}`

**Mô tả:** Lấy danh sách bài thi của user

**Authentication:** Required (User/Admin)

**Path Parameters:**
- `userId` (long, required): User ID

**Query Parameters:**
- `page` (int, optional, default: 0)
- `size` (int, optional, default: 10)

**Response Success (200 OK):**
```json
{
  "content": [
    {
      "id": 1,
      "title": "ReactJS Developer Assessment",
      "examType": "TECHNICAL",
      "status": "PUBLISHED",
      "duration": 60,
      "createdAt": "2024-01-15T10:30:00"
    }
  ],
  "totalElements": 3,
  "totalPages": 1
}
```

---

### 4.1.9. List Exams by Type

**Endpoint:** `GET /exams/type/{examType}`

**Mô tả:** Lấy danh sách bài thi theo loại

**Authentication:** Không yêu cầu

**Path Parameters:**
- `examType` (string, required): TECHNICAL|BEHAVIORAL|APTITUDE

**Query Parameters:**
- `page` (int, optional, default: 0)
- `size` (int, optional, default: 10)

**Response Success (200 OK):**
```json
{
  "content": [
    {
      "id": 1,
      "title": "ReactJS Developer Assessment",
      "examType": "TECHNICAL",
      "position": "Frontend Developer",
      "questionCount": 20,
      "duration": 60,
      "status": "PUBLISHED"
    }
  ],
  "totalElements": 10,
  "totalPages": 1
}
```

---

## 4.2. Exam Questions Management

### 4.2.1. Add Question to Exam

**Endpoint:** `POST /exams/questions`

**Mô tả:** Thêm câu hỏi vào bài thi

**Authentication:** Required (Admin/Recruiter)

**Request Body:**
```json
{
  "examId": "long (required)",
  "questionId": "long (required)",
  "orderNumber": "integer (optional)"
}
```

**Response Success (201 Created):**
```json
{
  "id": 1,
  "exam": {
    "id": 1,
    "title": "ReactJS Developer Assessment"
  },
  "question": {
    "id": 1,
    "questionContent": "What is ReactJS?"
  },
  "orderNumber": 1
}
```

---

### 4.2.2. Remove Questions from Exam

**Endpoint:** `DELETE /exams/{examId}/questions`

**Mô tả:** Xóa tất cả câu hỏi khỏi bài thi

**Authentication:** Required (Admin/Recruiter)

**Path Parameters:**
- `examId` (long, required): Exam ID

**Response Success (204 No Content)**

---

## 4.3. Exam Results Management

### 4.3.1. Submit Result

**Endpoint:** `POST /exams/results`

**Mô tả:** Nộp kết quả bài thi

**Authentication:** Required (User/Admin)

**Request Body:**
```json
{
  "examId": "long (required)",
  "userId": "long (required)",
  "score": "double (required)",
  "passStatus": "boolean (required)",
  "feedback": "string (optional)"
}
```

**Response Success (201 Created):**
```json
{
  "id": 1,
  "exam": {
    "id": 1,
    "title": "ReactJS Developer Assessment"
  },
  "user": {
    "id": 3,
    "fullName": "Nguyễn Văn A"
  },
  "score": 85.5,
  "passStatus": true,
  "feedback": "Good understanding of ReactJS concepts",
  "completedAt": "2024-01-15T12:00:00"
}
```

---

### 4.3.2. Get Result by ID

**Endpoint:** `GET /exams/results/{id}`

**Mô tả:** Lấy chi tiết kết quả thi

**Authentication:** Required (User/Admin)

**Path Parameters:**
- `id` (long, required): Result ID

**Response Success (200 OK):**
```json
{
  "id": 1,
  "exam": {
    "id": 1,
    "title": "ReactJS Developer Assessment",
    "duration": 60,
    "questionCount": 20
  },
  "user": {
    "id": 3,
    "fullName": "Nguyễn Văn A",
    "email": "user@example.com"
  },
  "score": 85.5,
  "passStatus": true,
  "feedback": "Good understanding of ReactJS concepts. Strong performance on component lifecycle and state management.",
  "completedAt": "2024-01-15T12:00:00"
}
```

---

### 4.3.3. List Results by Exam

**Endpoint:** `GET /exams/{examId}/results`

**Mô tả:** Lấy danh sách kết quả của bài thi

**Authentication:** Required (Admin/Recruiter)

**Path Parameters:**
- `examId` (long, required): Exam ID

**Query Parameters:**
- `page` (int, optional, default: 0)
- `size` (int, optional, default: 10)

**Response Success (200 OK):**
```json
{
  "content": [
    {
      "id": 1,
      "user": {
        "id": 3,
        "fullName": "Nguyễn Văn A"
      },
      "score": 85.5,
      "passStatus": true,
      "completedAt": "2024-01-15T12:00:00"
    }
  ],
  "totalElements": 25,
  "totalPages": 3
}
```

---

### 4.3.4. List Results by User

**Endpoint:** `GET /exams/results/user/{userId}`

**Mô tả:** Lấy danh sách kết quả thi của user

**Authentication:** Required (User/Admin)

**Path Parameters:**
- `userId` (long, required): User ID

**Query Parameters:**
- `page` (int, optional, default: 0)
- `size` (int, optional, default: 10)

**Response Success (200 OK):**
```json
{
  "content": [
    {
      "id": 1,
      "exam": {
        "id": 1,
        "title": "ReactJS Developer Assessment"
      },
      "score": 85.5,
      "passStatus": true,
      "completedAt": "2024-01-15T12:00:00"
    }
  ],
  "totalElements": 5,
  "totalPages": 1
}
```

---

## 4.4. User Answers Management

### 4.4.1. Submit Answer

**Endpoint:** `POST /exams/answers`

**Mô tả:** Nộp câu trả lời cho câu hỏi trong bài thi

**Authentication:** Required (User/Admin)

**Request Body:**
```json
{
  "examId": "long (required)",
  "questionId": "long (required)",
  "userId": "long (required)",
  "answerContent": "string (required)",
  "isCorrect": "boolean (optional)",
  "similarityScore": "double (optional)"
}
```

**Response Success (201 Created):**
```json
{
  "id": 1,
  "exam": {
    "id": 1,
    "title": "ReactJS Developer Assessment"
  },
  "question": {
    "id": 1,
    "questionContent": "What is ReactJS?"
  },
  "user": {
    "id": 3,
    "fullName": "Nguyễn Văn A"
  },
  "answerContent": "ReactJS is a JavaScript library for building user interfaces",
  "isCorrect": true,
  "similarityScore": 0.95,
  "createdAt": "2024-01-15T11:30:00"
}
```

---

### 4.4.2. Get User Answer by ID

**Endpoint:** `GET /exams/answers/{id}`

**Mô tả:** Lấy chi tiết câu trả lời

**Authentication:** Required (User/Admin)

**Path Parameters:**
- `id` (long, required): Answer ID

**Response Success (200 OK):**
```json
{
  "id": 1,
  "exam": {
    "id": 1,
    "title": "ReactJS Developer Assessment"
  },
  "question": {
    "id": 1,
    "questionContent": "What is ReactJS?"
  },
  "user": {
    "id": 3,
    "fullName": "Nguyễn Văn A"
  },
  "answerContent": "ReactJS is a JavaScript library for building user interfaces",
  "isCorrect": true,
  "similarityScore": 0.95,
  "createdAt": "2024-01-15T11:30:00"
}
```

---

### 4.4.3. Get User Answers by Exam

**Endpoint:** `GET /exams/{examId}/answers/{userId}`

**Mô tả:** Lấy danh sách câu trả lời của user trong bài thi

**Authentication:** Required (User/Admin)

**Path Parameters:**
- `examId` (long, required): Exam ID
- `userId` (long, required): User ID

**Query Parameters:**
- `page` (int, optional, default: 0)
- `size` (int, optional, default: 10)

**Response Success (200 OK):**
```json
{
  "content": [
    {
      "id": 1,
      "question": {
        "id": 1,
        "questionContent": "What is ReactJS?"
      },
      "answerContent": "ReactJS is a JavaScript library...",
      "isCorrect": true,
      "similarityScore": 0.95,
      "createdAt": "2024-01-15T11:30:00"
    }
  ],
  "totalElements": 20,
  "totalPages": 2
}
```

---

## 4.5. Exam Registration Management

### 4.5.1. Register for Exam

**Endpoint:** `POST /exams/registrations`

**Mô tả:** Đăng ký tham gia bài thi

**Authentication:** Required (User/Admin)

**Request Body:**
```json
{
  "examId": "long (required)",
  "userId": "long (required)"
}
```

**Response Success (201 Created):**
```json
{
  "id": 1,
  "exam": {
    "id": 1,
    "title": "ReactJS Developer Assessment",
    "startTime": "2024-01-22T09:00:00"
  },
  "user": {
    "id": 3,
    "fullName": "Nguyễn Văn A"
  },
  "registrationStatus": "REGISTERED",
  "registeredAt": "2024-01-15T10:30:00"
}
```

**Registration Status:**
- REGISTERED: Đã đăng ký
- CANCELLED: Đã hủy
- ATTENDED: Đã tham gia
- ABSENT: Vắng mặt

---

### 4.5.2. Cancel Registration

**Endpoint:** `POST /exams/registrations/{registrationId}/cancel`

**Mô tả:** Hủy đăng ký tham gia bài thi

**Authentication:** Required (User/Admin)

**Path Parameters:**
- `registrationId` (long, required): Registration ID

**Response Success (200 OK):**
```json
{
  "id": 1,
  "registrationStatus": "CANCELLED",
  "cancelledAt": "2024-01-15T11:00:00"
}
```

---

### 4.5.3. Get Registration by ID

**Endpoint:** `GET /exams/registrations/{id}`

**Mô tả:** Lấy chi tiết đăng ký

**Authentication:** Required (User/Admin)

**Path Parameters:**
- `id` (long, required): Registration ID

**Response Success (200 OK):**
```json
{
  "id": 1,
  "exam": {
    "id": 1,
    "title": "ReactJS Developer Assessment",
    "startTime": "2024-01-22T09:00:00",
    "duration": 60
  },
  "user": {
    "id": 3,
    "fullName": "Nguyễn Văn A",
    "email": "user@example.com"
  },
  "registrationStatus": "REGISTERED",
  "registeredAt": "2024-01-15T10:30:00"
}
```

---

### 4.5.4. List Registrations by Exam

**Endpoint:** `GET /exams/{examId}/registrations`

**Mô tả:** Lấy danh sách đăng ký cho bài thi

**Authentication:** Required (Admin/Recruiter)

**Path Parameters:**
- `examId` (long, required): Exam ID

**Query Parameters:**
- `page` (int, optional, default: 0)
- `size` (int, optional, default: 10)

**Response Success (200 OK):**
```json
{
  "content": [
    {
      "id": 1,
      "user": {
        "id": 3,
        "fullName": "Nguyễn Văn A",
        "email": "user@example.com"
      },
      "registrationStatus": "REGISTERED",
      "registeredAt": "2024-01-15T10:30:00"
    }
  ],
  "totalElements": 50,
  "totalPages": 5
}
```

---

### 4.5.5. List Registrations by User

**Endpoint:** `GET /exams/registrations/user/{userId}`

**Mô tả:** Lấy danh sách đăng ký của user

**Authentication:** Required (User/Admin)

**Path Parameters:**
- `userId` (long, required): User ID

**Query Parameters:**
- `page` (int, optional, default: 0)
- `size` (int, optional, default: 10)

**Response Success (200 OK):**
```json
{
  "content": [
    {
      "id": 1,
      "exam": {
        "id": 1,
        "title": "ReactJS Developer Assessment",
        "startTime": "2024-01-22T09:00:00"
      },
      "registrationStatus": "REGISTERED",
      "registeredAt": "2024-01-15T10:30:00"
    }
  ],
  "totalElements": 10,
  "totalPages": 1
}
```

---

# 5. Career Service API

Base URL: `http://localhost:8080/career`

## 5.1. Create Career Preference

**Endpoint:** `POST /career`

**Mô tả:** Tạo sở thích nghề nghiệp cho user

**Authentication:** Required (User/Admin)

**Request Body:**
```json
{
  "userId": "long (required)",
  "fieldId": "long (required)",
  "topicId": "long (required)"
}
```

**Response Success (201 Created):**
```json
{
  "id": 1,
  "user": {
    "id": 3,
    "fullName": "Nguyễn Văn A"
  },
  "field": {
    "id": 1,
    "fieldName": "Lập trình viên"
  },
  "topic": {
    "id": 1,
    "topicName": "ReactJS"
  },
  "createdAt": "2024-01-15T10:30:00",
  "updatedAt": "2024-01-15T10:30:00"
}
```

---

## 5.2. Update Career Preference

**Endpoint:** `PUT /career/update/{careerId}`

**Mô tả:** Cập nhật sở thích nghề nghiệp

**Authentication:** Required (User/Admin)

**Path Parameters:**
- `careerId` (long, required): Career Preference ID

**Request Body:**
```json
{
  "userId": "long (required)",
  "fieldId": "long (required)",
  "topicId": "long (required)"
}
```

**Response Success (200 OK):**
```json
{
  "id": 1,
  "field": {
    "id": 2,
    "fieldName": "Business Analyst"
  },
  "topic": {
    "id": 6,
    "topicName": "Requirements Analysis"
  },
  "updatedAt": "2024-01-15T12:00:00"
}
```

---

## 5.3. Get Career by ID

**Endpoint:** `GET /career/{careerId}`

**Mô tả:** Lấy chi tiết sở thích nghề nghiệp

**Authentication:** Required (User/Admin)

**Path Parameters:**
- `careerId` (long, required): Career Preference ID

**Response Success (200 OK):**
```json
{
  "id": 1,
  "user": {
    "id": 3,
    "fullName": "Nguyễn Văn A",
    "email": "user@example.com"
  },
  "field": {
    "id": 1,
    "fieldName": "Lập trình viên",
    "description": "Ngành lập trình phần mềm"
  },
  "topic": {
    "id": 1,
    "topicName": "ReactJS",
    "description": "Thư viện JavaScript cho UI"
  },
  "createdAt": "2024-01-15T10:30:00",
  "updatedAt": "2024-01-15T10:30:00"
}
```

---

## 5.4. Get Career by User ID

**Endpoint:** `GET /career/preferences/{userId}`

**Mô tả:** Lấy danh sách sở thích nghề nghiệp của user

**Authentication:** Required (User/Admin)

**Path Parameters:**
- `userId` (long, required): User ID

**Query Parameters:**
- `page` (int, optional, default: 0)
- `size` (int, optional, default: 10)

**Response Success (200 OK):**
```json
{
  "content": [
    {
      "id": 1,
      "field": {
        "id": 1,
        "fieldName": "Lập trình viên"
      },
      "topic": {
        "id": 1,
        "topicName": "ReactJS"
      },
      "createdAt": "2024-01-15T10:30:00"
    },
    {
      "id": 2,
      "field": {
        "id": 1,
        "fieldName": "Lập trình viên"
      },
      "topic": {
        "id": 4,
        "topicName": "Spring Boot"
      },
      "createdAt": "2024-01-14T15:20:00"
    }
  ],
  "totalElements": 3,
  "totalPages": 1
}
```

---

## 5.5. Delete Career Preference

**Endpoint:** `DELETE /career/{careerId}`

**Mô tả:** Xóa sở thích nghề nghiệp

**Authentication:** Required (User/Admin)

**Path Parameters:**
- `careerId` (long, required): Career Preference ID

**Response Success (204 No Content)**

---

# 6. News Service API

Base URL: `http://localhost:8080`

## 6.1. News Management

### 6.1.1. Create News

**Endpoint:** `POST /news`

**Mô tả:** Tạo bài viết tin tức mới

**Authentication:** Required (User/Admin/Recruiter)

**Request Body:**
```json
{
  "userId": "long (required)",
  "title": "string (required, max 255 characters)",
  "content": "string (required)",
  "fieldId": "long (optional)",
  "examId": "long (optional)",
  "newsType": "string (required, values: NEWS|RECRUITMENT)"
}
```

**Response Success (201 Created):**
```json
{
  "id": 1,
  "user": {
    "id": 3,
    "fullName": "Nguyễn Văn A"
  },
  "title": "ReactJS 18 New Features Released",
  "content": "ReactJS 18 introduces several exciting new features...",
  "field": {
    "id": 1,
    "fieldName": "Lập trình viên"
  },
  "newsType": "NEWS",
  "status": "PENDING",
  "usefulVote": 0,
  "interestVote": 0,
  "createdAt": "2024-01-15T10:30:00"
}
```

**News Types:**
- NEWS: Tin tức kỹ thuật
- RECRUITMENT: Tin tuyển dụng

**News Status:**
- PENDING: Chờ duyệt
- APPROVED: Đã duyệt
- REJECTED: Bị từ chối
- PUBLISHED: Đã publish
- EXPIRED: Hết hạn

---

### 6.1.2. Get News by ID

**Endpoint:** `GET /news/{id}`

**Mô tả:** Lấy chi tiết tin tức

**Authentication:** Không yêu cầu

**Path Parameters:**
- `id` (long, required): News ID

**Response Success (200 OK):**
```json
{
  "id": 1,
  "user": {
    "id": 3,
    "fullName": "Nguyễn Văn A",
    "email": "user@example.com"
  },
  "title": "ReactJS 18 New Features Released",
  "content": "ReactJS 18 introduces several exciting new features including concurrent rendering, automatic batching...",
  "field": {
    "id": 1,
    "fieldName": "Lập trình viên"
  },
  "exam": null,
  "newsType": "NEWS",
  "status": "PUBLISHED",
  "usefulVote": 25,
  "interestVote": 18,
  "createdAt": "2024-01-15T10:30:00",
  "publishedAt": "2024-01-15T11:00:00",
  "approvedBy": {
    "id": 1,
    "fullName": "Admin User"
  }
}
```

---

### 6.1.3. Update News

**Endpoint:** `PUT /news/{id}`

**Mô tả:** Cập nhật tin tức

**Authentication:** Required (User/Admin/Recruiter)

**Path Parameters:**
- `id` (long, required): News ID

**Request Body:** (Same as Create News)

**Response Success (200 OK):**
```json
{
  "id": 1,
  "title": "Updated news title",
  "content": "Updated content",
  "updatedAt": "2024-01-15T12:00:00"
}
```

---

### 6.1.4. Delete News

**Endpoint:** `DELETE /news/{id}`

**Mô tả:** Xóa tin tức

**Authentication:** Required (Admin/Recruiter)

**Path Parameters:**
- `id` (long, required): News ID

**Response Success (204 No Content)**

---

### 6.1.5. Approve News

**Endpoint:** `POST /news/{newsId}/approve`

**Mô tả:** Duyệt tin tức (Admin only)

**Authentication:** Required (Admin)

**Path Parameters:**
- `newsId` (long, required): News ID

**Query Parameters:**
- `adminId` (long, required): Admin user ID

**Response Success (200 OK):**
```json
{
  "id": 1,
  "status": "APPROVED",
  "approvedAt": "2024-01-15T11:00:00",
  "approvedBy": {
    "id": 1,
    "fullName": "Admin User"
  }
}
```

---

### 6.1.6. Reject News

**Endpoint:** `POST /news/{newsId}/reject`

**Mô tả:** Từ chối tin tức (Admin only)

**Authentication:** Required (Admin)

**Path Parameters:**
- `newsId` (long, required): News ID

**Query Parameters:**
- `adminId` (long, required): Admin user ID

**Response Success (200 OK):**
```json
{
  "id": 1,
  "status": "REJECTED",
  "rejectedAt": "2024-01-15T11:00:00",
  "rejectedBy": {
    "id": 1,
    "fullName": "Admin User"
  }
}
```

---

### 6.1.7. Publish News

**Endpoint:** `POST /news/{newsId}/publish`

**Mô tả:** Publish tin tức (Admin only)

**Authentication:** Required (Admin)

**Path Parameters:**
- `newsId` (long, required): News ID

**Response Success (200 OK):**
```json
{
  "id": 1,
  "status": "PUBLISHED",
  "publishedAt": "2024-01-15T11:00:00"
}
```

---

### 6.1.8. Vote News

**Endpoint:** `POST /news/{newsId}/vote`

**Mô tả:** Vote cho tin tức (useful hoặc interest)

**Authentication:** Required (User/Admin)

**Path Parameters:**
- `newsId` (long, required): News ID

**Query Parameters:**
- `voteType` (string, required): useful | interest

**Response Success (200 OK):**
```json
{
  "id": 1,
  "usefulVote": 26,
  "interestVote": 18
}
```

---

### 6.1.9. List News by Type

**Endpoint:** `GET /news/type/{newsType}`

**Mô tả:** Lấy danh sách tin tức theo loại

**Authentication:** Không yêu cầu

**Path Parameters:**
- `newsType` (string, required): NEWS | RECRUITMENT

**Query Parameters:**
- `page` (int, optional, default: 0)
- `size` (int, optional, default: 10)

**Response Success (200 OK):**
```json
{
  "content": [
    {
      "id": 1,
      "title": "ReactJS 18 New Features Released",
      "newsType": "NEWS",
      "status": "PUBLISHED",
      "usefulVote": 25,
      "interestVote": 18,
      "createdAt": "2024-01-15T10:30:00"
    }
  ],
  "totalElements": 15,
  "totalPages": 2
}
```

---

### 6.1.10. List News by User

**Endpoint:** `GET /news/user/{userId}`

**Mô tả:** Lấy danh sách tin tức của user

**Authentication:** Required (User/Admin/Recruiter)

**Path Parameters:**
- `userId` (long, required): User ID

**Query Parameters:**
- `page` (int, optional, default: 0)
- `size` (int, optional, default: 10)

**Response Success (200 OK):**
```json
{
  "content": [
    {
      "id": 1,
      "title": "ReactJS 18 New Features Released",
      "newsType": "NEWS",
      "status": "PUBLISHED",
      "createdAt": "2024-01-15T10:30:00"
    }
  ],
  "totalElements": 5,
  "totalPages": 1
}
```

---

### 6.1.11. List News by Status

**Endpoint:** `GET /news/status/{status}`

**Mô tả:** Lấy danh sách tin tức theo trạng thái (Admin only)

**Authentication:** Required (Admin)

**Path Parameters:**
- `status` (string, required): PENDING|APPROVED|REJECTED|PUBLISHED|EXPIRED

**Query Parameters:**
- `page` (int, optional, default: 0)
- `size` (int, optional, default: 10)

**Response Success (200 OK):**
```json
{
  "content": [
    {
      "id": 1,
      "title": "ReactJS 18 New Features Released",
      "status": "PENDING",
      "createdAt": "2024-01-15T10:30:00"
    }
  ],
  "totalElements": 8,
  "totalPages": 1
}
```

---

### 6.1.12. List News by Field

**Endpoint:** `GET /news/field/{fieldId}`

**Mô tả:** Lấy danh sách tin tức theo lĩnh vực

**Authentication:** Không yêu cầu

**Path Parameters:**
- `fieldId` (long, required): Field ID

**Query Parameters:**
- `page` (int, optional, default: 0)
- `size` (int, optional, default: 10)

**Response Success (200 OK):**
```json
{
  "content": [
    {
      "id": 1,
      "title": "ReactJS 18 New Features Released",
      "field": {
        "id": 1,
        "fieldName": "Lập trình viên"
      },
      "status": "PUBLISHED",
      "createdAt": "2024-01-15T10:30:00"
    }
  ],
  "totalElements": 20,
  "totalPages": 2
}
```

---

### 6.1.13. List Published News

**Endpoint:** `GET /news/published/{newsType}`

**Mô tả:** Lấy danh sách tin tức đã publish

**Authentication:** Không yêu cầu

**Path Parameters:**
- `newsType` (string, required): NEWS | RECRUITMENT

**Query Parameters:**
- `page` (int, optional, default: 0)
- `size` (int, optional, default: 10)

**Response Success (200 OK):**
```json
{
  "content": [
    {
      "id": 1,
      "title": "ReactJS 18 New Features Released",
      "newsType": "NEWS",
      "status": "PUBLISHED",
      "publishedAt": "2024-01-15T11:00:00",
      "usefulVote": 25,
      "interestVote": 18
    }
  ],
  "totalElements": 30,
  "totalPages": 3
}
```

---

### 6.1.14. List Pending Moderation

**Endpoint:** `GET /news/moderation/pending`

**Mô tả:** Lấy danh sách tin tức chờ duyệt (Admin only)

**Authentication:** Required (Admin)

**Query Parameters:**
- `page` (int, optional, default: 0)
- `size` (int, optional, default: 10)

**Response Success (200 OK):**
```json
{
  "content": [
    {
      "id": 1,
      "title": "ReactJS 18 New Features Released",
      "user": {
        "id": 3,
        "fullName": "Nguyễn Văn A"
      },
      "status": "PENDING",
      "createdAt": "2024-01-15T10:30:00"
    }
  ],
  "totalElements": 12,
  "totalPages": 2
}
```

---

## 6.2. Recruitment Management

### 6.2.1. Create Recruitment

**Endpoint:** `POST /recruitments`

**Mô tả:** Tạo tin tuyển dụng (Recruiter/Admin only)

**Authentication:** Required (Recruiter/Admin)

**Request Body:**
```json
{
  "userId": "long (required)",
  "title": "string (required, max 255 characters)",
  "content": "string (required)",
  "fieldId": "long (optional)",
  "newsType": "string (auto-set to RECRUITMENT)",
  "companyName": "string (required, max 255 characters)",
  "location": "string (required, max 255 characters)",
  "salary": "string (optional, max 100 characters)",
  "experience": "string (optional, max 100 characters)",
  "position": "string (required, max 100 characters)",
  "workingHours": "string (optional, max 100 characters)",
  "deadline": "string (optional, max 100 characters)",
  "applicationMethod": "string (required)"
}
```

**Response Success (201 Created):**
```json
{
  "id": 1,
  "user": {
    "id": 2,
    "fullName": "Recruiter User"
  },
  "title": "Senior ReactJS Developer - ABC Tech",
  "content": "We are looking for a Senior ReactJS Developer to join our growing team...",
  "field": {
    "id": 1,
    "fieldName": "Lập trình viên"
  },
  "newsType": "RECRUITMENT",
  "status": "PENDING",
  "companyName": "ABC Tech",
  "location": "Ho Chi Minh City",
  "salary": "2000-3000 USD",
  "experience": "3-5 years",
  "position": "Senior ReactJS Developer",
  "workingHours": "9AM-6PM",
  "deadline": "2024-12-31",
  "applicationMethod": "Send CV to hr@abctech.com",
  "usefulVote": 0,
  "interestVote": 0,
  "createdAt": "2024-01-15T10:30:00"
}
```

---

### 6.2.2. List Recruitments

**Endpoint:** `GET /recruitments`

**Mô tả:** Lấy danh sách tin tuyển dụng đã publish

**Authentication:** Không yêu cầu

**Query Parameters:**
- `page` (int, optional, default: 0)
- `size` (int, optional, default: 10)

**Response Success (200 OK):**
```json
{
  "content": [
    {
      "id": 1,
      "title": "Senior ReactJS Developer - ABC Tech",
      "companyName": "ABC Tech",
      "location": "Ho Chi Minh City",
      "salary": "2000-3000 USD",
      "experience": "3-5 years",
      "position": "Senior ReactJS Developer",
      "deadline": "2024-12-31",
      "interestVote": 35,
      "publishedAt": "2024-01-15T11:00:00"
    }
  ],
  "totalElements": 25,
  "totalPages": 3
}
```

---

### 6.2.3. List Recruitments by Company

**Endpoint:** `GET /recruitments/company/{companyName}`

**Mô tả:** Lấy danh sách tin tuyển dụng theo công ty

**Authentication:** Không yêu cầu

**Path Parameters:**
- `companyName` (string, required): Company name

**Query Parameters:**
- `page` (int, optional, default: 0)
- `size` (int, optional, default: 10)

**Response Success (200 OK):**
```json
{
  "content": [
    {
      "id": 1,
      "title": "Senior ReactJS Developer - ABC Tech",
      "companyName": "ABC Tech",
      "position": "Senior ReactJS Developer",
      "salary": "2000-3000 USD",
      "publishedAt": "2024-01-15T11:00:00"
    }
  ],
  "totalElements": 5,
  "totalPages": 1
}
```

---

# 7. NLP Service API

Base URL: `http://localhost:8080`

## 7.1. Health Check

**Endpoint:** `GET /health`

**Mô tả:** Kiểm tra trạng thái NLP service

**Authentication:** Không yêu cầu

**Response Success (200 OK):**
```json
{
  "status": "UP",
  "service": "nlp-service",
  "version": "1.0.0",
  "timestamp": "2024-01-15T10:30:00"
}
```

---

## 7.2. Similarity Detection

### 7.2.1. Check Similarity

**Endpoint:** `POST /similarity/check`

**Mô tả:** Kiểm tra độ tương đồng giữa 2 văn bản

**Authentication:** Không yêu cầu

**Request Body:**
```json
{
  "text1": "string (required)",
  "text2": "string (required)"
}
```

**Response Success (200 OK):**
```json
{
  "text1": "What is machine learning?",
  "text2": "What is ML?",
  "similarityScore": 0.85,
  "isSimilar": true,
  "threshold": 0.7
}
```

---

### 7.2.2. Check Question Similarity

**Endpoint:** `POST /questions/similarity/check`

**Mô tả:** Kiểm tra câu hỏi mới có trùng lặp với các câu hỏi hiện có không

**Authentication:** Không yêu cầu

**Request Body:**
```json
{
  "questionText": "string (required)",
  "excludeId": "long (optional, question ID to exclude from check)"
}
```

**Response Success (200 OK):**
```json
{
  "questionText": "What is machine learning?",
  "hasSimilar": true,
  "similarQuestions": [
    {
      "questionId": 5,
      "questionContent": "What is ML and its applications?",
      "similarityScore": 0.92
    },
    {
      "questionId": 12,
      "questionContent": "Explain machine learning",
      "similarityScore": 0.88
    }
  ],
  "maxSimilarityScore": 0.92,
  "threshold": 0.7
}
```

---

## 7.3. Essay Grading

### 7.3.1. Grade Essay

**Endpoint:** `POST /grading/essay`

**Mô tả:** Chấm điểm bài luận tự động

**Authentication:** Không yêu cầu

**Request Body:**
```json
{
  "question": "string (required)",
  "answer": "string (required)",
  "maxScore": "double (optional, default: 100)"
}
```

**Response Success (200 OK):**
```json
{
  "question": "Explain the concept of machine learning",
  "answer": "Machine learning is a subset of artificial intelligence...",
  "score": 85.5,
  "maxScore": 100,
  "criteria": {
    "relevance": {
      "score": 90,
      "weight": 0.3,
      "feedback": "Answer is highly relevant to the question"
    },
    "completeness": {
      "score": 85,
      "weight": 0.3,
      "feedback": "Good coverage of key concepts"
    },
    "clarity": {
      "score": 80,
      "weight": 0.2,
      "feedback": "Clear and well-structured explanation"
    },
    "accuracy": {
      "score": 87,
      "weight": 0.2,
      "feedback": "Technically accurate with minor improvements needed"
    }
  },
  "overallFeedback": "Good understanding of machine learning concepts. Answer demonstrates solid knowledge with clear explanations.",
  "gradedAt": "2024-01-15T10:30:00"
}
```

**Grading Criteria:**
- **Relevance** (30%): Độ liên quan đến câu hỏi
- **Completeness** (30%): Độ đầy đủ của câu trả lời
- **Clarity** (20%): Độ rõ ràng, mạch lạc
- **Accuracy** (20%): Độ chính xác về mặt kỹ thuật

---

### 7.3.2. Grade Exam Answer

**Endpoint:** `POST /exams/{examId}/questions/{questionId}/grade`

**Mô tả:** Chấm điểm câu trả lời trong bài thi

**Authentication:** Không yêu cầu

**Path Parameters:**
- `examId` (long, required): Exam ID
- `questionId` (long, required): Question ID

**Request Body:**
```json
{
  "examId": "long (required)",
  "questionId": "long (required)",
  "answerText": "string (required)",
  "maxScore": "double (optional, default: 100)"
}
```

**Response Success (200 OK):**
```json
{
  "examId": 1,
  "questionId": 5,
  "answerText": "Student answer here...",
  "score": 75.0,
  "maxScore": 100,
  "criteria": {
    "relevance": {
      "score": 80,
      "weight": 0.3
    },
    "completeness": {
      "score": 70,
      "weight": 0.3
    },
    "clarity": {
      "score": 75,
      "weight": 0.2
    },
    "accuracy": {
      "score": 77,
      "weight": 0.2
    }
  },
  "feedback": "Good attempt with room for improvement",
  "gradedAt": "2024-01-15T10:30:00"
}
```

---

### 7.3.3. Grade All Exam Questions

**Endpoint:** `POST /exams/{examId}/grade-all`

**Mô tả:** Chấm điểm tất cả câu hỏi tự luận trong bài thi

**Authentication:** Không yêu cầu

**Path Parameters:**
- `examId` (long, required): Exam ID

**Request Body:**
```json
{
  "examId": "long (required)"
}
```

**Response Success (200 OK):**
```json
{
  "examId": 1,
  "totalQuestions": 5,
  "gradedQuestions": 5,
  "results": [
    {
      "questionId": 1,
      "score": 85.5,
      "maxScore": 100
    },
    {
      "questionId": 2,
      "score": 72.0,
      "maxScore": 100
    }
  ],
  "averageScore": 78.75,
  "totalScore": 393.75,
  "maxTotalScore": 500,
  "gradedAt": "2024-01-15T10:30:00"
}
```

---

## 7.4. Analytics

### 7.4.1. Get Question Analytics

**Endpoint:** `GET /questions/{questionId}/analytics`

**Mô tả:** Lấy phân tích thống kê cho câu hỏi

**Authentication:** Không yêu cầu

**Path Parameters:**
- `questionId` (long, required): Question ID

**Response Success (200 OK):**
```json
{
  "questionId": 1,
  "question": {
    "id": 1,
    "questionContent": "What is ReactJS?",
    "topic": "ReactJS",
    "level": "Junior"
  },
  "statistics": {
    "totalAnswers": 50,
    "averageScore": 78.5,
    "medianScore": 80.0,
    "minScore": 45.0,
    "maxScore": 98.0,
    "standardDeviation": 12.5
  },
  "difficulty": {
    "level": "MEDIUM",
    "score": 0.65,
    "passRate": 0.78
  },
  "sentimentAnalysis": {
    "positive": 0.65,
    "neutral": 0.25,
    "negative": 0.10
  },
  "commonKeywords": [
    {
      "keyword": "library",
      "frequency": 45
    },
    {
      "keyword": "components",
      "frequency": 38
    },
    {
      "keyword": "virtual DOM",
      "frequency": 32
    }
  ],
  "generatedAt": "2024-01-15T10:30:00"
}
```

**Difficulty Levels:**
- EASY: Pass rate > 80%
- MEDIUM: Pass rate 50-80%
- HARD: Pass rate < 50%

---

# 8. Data Models

## 8.1. User Model
```json
{
  "id": "long",
  "email": "string",
  "fullName": "string",
  "dateOfBirth": "date",
  "address": "string",
  "status": "PENDING|ACTIVE|INACTIVE|BANNED",
  "isStudying": "boolean",
  "eloScore": "integer",
  "eloRank": "NEWBIE|BRONZE|SILVER|GOLD|PLATINUM|DIAMOND",
  "role": {
    "id": "long",
    "roleName": "USER|RECRUITER|ADMIN"
  },
  "createdAt": "timestamp"
}
```

## 8.2. Question Model
```json
{
  "id": "long",
  "user": "User",
  "topic": "Topic",
  "field": "Field",
  "level": "Level",
  "questionType": "QuestionType",
  "questionContent": "string",
  "questionAnswer": "string",
  "similarityScore": "double",
  "status": "PENDING|APPROVED|REJECTED",
  "language": "vi|en",
  "usefulVote": "integer",
  "unusefulVote": "integer",
  "createdAt": "timestamp",
  "approvedAt": "timestamp",
  "approvedBy": "User"
}
```

## 8.3. Exam Model
```json
{
  "id": "long",
  "user": "User",
  "examType": "TECHNICAL|BEHAVIORAL|APTITUDE",
  "title": "string",
  "position": "string",
  "topics": "string (JSON array)",
  "questionTypes": "string (JSON array)",
  "questionCount": "integer",
  "duration": "integer (minutes)",
  "startTime": "timestamp",
  "endTime": "timestamp",
  "status": "DRAFT|PUBLISHED|IN_PROGRESS|COMPLETED|CANCELLED",
  "language": "vi|en",
  "createdAt": "timestamp",
  "createdBy": "long"
}
```

## 8.4. News Model
```json
{
  "id": "long",
  "user": "User",
  "title": "string",
  "content": "string",
  "field": "Field",
  "exam": "Exam",
  "newsType": "NEWS|RECRUITMENT",
  "status": "PENDING|APPROVED|REJECTED|PUBLISHED|EXPIRED",
  "usefulVote": "integer",
  "interestVote": "integer",
  "companyName": "string (for recruitment)",
  "location": "string (for recruitment)",
  "salary": "string (for recruitment)",
  "experience": "string (for recruitment)",
  "position": "string (for recruitment)",
  "workingHours": "string (for recruitment)",
  "deadline": "string (for recruitment)",
  "applicationMethod": "string (for recruitment)",
  "createdAt": "timestamp",
  "publishedAt": "timestamp",
  "expiredAt": "timestamp",
  "approvedBy": "User"
}
```

---

# 9. Error Codes

## 9.1. HTTP Status Codes

| Code | Status | Mô tả |
|------|--------|-------|
| 200 | OK | Request thành công |
| 201 | Created | Resource được tạo thành công |
| 204 | No Content | Request thành công, không có content trả về |
| 400 | Bad Request | Request không hợp lệ (validation error) |
| 401 | Unauthorized | Chưa đăng nhập hoặc token không hợp lệ |
| 403 | Forbidden | Không có quyền truy cập |
| 404 | Not Found | Resource không tồn tại |
| 409 | Conflict | Resource đã tồn tại (duplicate) |
| 500 | Internal Server Error | Lỗi server |

## 9.2. Error Response Format

```json
{
  "timestamp": "2024-01-15T10:30:00",
  "status": 400,
  "error": "Bad Request",
  "message": "Email already exists",
  "path": "/users/register",
  "errors": [
    {
      "field": "email",
      "message": "Email must be unique",
      "rejectedValue": "user@example.com"
    }
  ]
}
```

## 9.3. Common Error Messages

### Authentication Errors
- `Invalid email or password` - Sai email hoặc password
- `Token expired` - Token đã hết hạn
- `Invalid token` - Token không hợp lệ
- `Unauthorized access` - Chưa đăng nhập

### Authorization Errors
- `Access denied` - Không có quyền truy cập
- `Admin role required` - Yêu cầu quyền admin
- `Recruiter role required` - Yêu cầu quyền recruiter

### Validation Errors
- `Email already exists` - Email đã tồn tại
- `Invalid email format` - Email không đúng format
- `Password must be at least 8 characters` - Password phải ít nhất 8 ký tự
- `Field is required` - Trường bắt buộc
- `Invalid date format` - Format ngày tháng không hợp lệ

### Resource Errors
- `User not found` - Không tìm thấy user
- `Question not found` - Không tìm thấy câu hỏi
- `Exam not found` - Không tìm thấy bài thi
- `Resource already exists` - Resource đã tồn tại

---

## 📞 Support

Để được hỗ trợ thêm về API:
1. Kiểm tra logs của microservice tương ứng
2. Verify dữ liệu trong database
3. Test với Postman collection
4. Xem hướng dẫn trong `HUONG-DAN-IMPORT.md`

---

**Version:** 1.0.0  
**Last Updated:** January 15, 2024  
**Author:** Interview Microservice ABC Team
