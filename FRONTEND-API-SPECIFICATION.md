# 📘 Frontend API Specification - Interview Microservice System

> **Version:** 1.0.0  
> **Last Updated:** October 22, 2025  
> **Base URL (Gateway):** `http://localhost:8080`  
> **Authentication:** JWT Bearer Token (except Login, Register, Verify)

---

## 📑 Table of Contents

1. [Quick Start for Agents](#quick-start-for-agents)
2. [Authentication & Authorization](#1-authentication--authorization)
3. [User Management](#2-user-management)
4. [Question Management](#3-question-management)
5. [Exam Management](#4-exam-management)
6. [News Management](#5-news-management)
7. [Career Management](#6-career-management)
8. [Common Models & Error Handling](#7-common-models--error-handling)
9. [TypeScript Types](#typescript-types)
10. [Code Generation Templates](#code-generation-templates)

---

## Quick Start for Agents

### Agent-Friendly Summary

**Total Endpoints:** 100+  
**Services:** 6 (Auth, User, Question, Exam, News, Career)  
**Base URL:** `http://localhost:8080`  
**Content-Type:** `application/json`  
**Auth Method:** Bearer Token in `Authorization` header  

### Quick API Client Template

```typescript
class APIClient {
  private baseURL = 'http://localhost:8080';
  private token: string | null = null;

  setToken(token: string) {
    this.token = token;
  }

  private async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<T> {
    const headers: HeadersInit = {
      'Content-Type': 'application/json',
      ...options.headers,
    };

    if (this.token) {
      headers['Authorization'] = `Bearer ${this.token}`;
    }

    const response = await fetch(`${this.baseURL}${endpoint}`, {
      ...options,
      headers,
    });

    if (!response.ok) {
      const error = await response.json();
      throw error;
    }

    return response.json();
  }

  // Auth
  async login(email: string, password: string) {
    return this.request<TokenResponse>('/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    });
  }

  // Users
  async getUser(id: number) {
    return this.request<UserResponse>(`/users/${id}`);
  }

  // Questions
  async getQuestions(page = 0, size = 20) {
    return this.request<PaginatedResponse<QuestionResponse>>(
      `/questions?page=${page}&size=${size}`
    );
  }

  // Exams
  async createExam(data: ExamRequest) {
    return this.request<ExamResponse>('/exams', {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }

  // News
  async getNews(page = 0, size = 20) {
    return this.request<PaginatedResponse<NewsResponse>>(
      `/news?page=${page}&size=${size}`
    );
  }
}
```

### Service Port Reference (Direct Access)

```
Gateway:   http://localhost:8080  (Routes to all services)
Auth:      http://localhost:8081  (Direct access)
User:      http://localhost:8082
Career:    http://localhost:8084
Question:  http://localhost:8085
Exam:      http://localhost:8086
News:      http://localhost:8087
NLP:       http://localhost:5000  (FastAPI)
Eureka:    http://localhost:8761  (Service Discovery)
```

---

## 📑 Detailed Documentation

1. [Authentication & Authorization](#1-authentication--authorization)
2. [User Management](#2-user-management)
3. [Question Management](#3-question-management)
4. [Exam Management](#4-exam-management)
5. [News Management](#5-news-management)
6. [Career Management](#6-career-management)
7. [Common Models & Error Handling](#7-common-models--error-handling)

---

## 1. Authentication & Authorization

### 1.1. Register New User

**Endpoint:** `POST /auth/register`  
**Authentication:** None  
**Description:** Đăng ký tài khoản mới. Email verification token sẽ được gửi qua email.

**Request Body:**
```json
{
  "email": "user@example.com",          // Required, email format
  "password": "password123",             // Required, min 6 characters
  "roleName": "USER",                    // Required: "USER" | "RECRUITER" | "ADMIN"
  "fullName": "Nguyễn Văn A",          // Optional
  "dateOfBirth": "1995-05-20",          // Optional, format: YYYY-MM-DD
  "address": "123 Main St, Hanoi",      // Optional
  "isStudying": true                     // Optional, boolean
}
```

**Response:** `200 OK`
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiJ9...",
  "tokenType": "Bearer",
  "refreshToken": "eyJhbGciOiJIUzI1NiJ9...",
  "expiresIn": 3600,
  "verifyToken": "uuid-verification-token-here"
}
```

**Validation Rules:**
- `email`: Must be unique và valid email format
- `password`: Minimum 6 characters, maximum 50 characters
- `roleName`: Must be one of: USER, RECRUITER, ADMIN
- `fullName`: Optional, max 100 characters

**Error Responses:**
- `400 Bad Request`: Invalid input data
- `409 Conflict`: Email already exists

---

### 1.2. Login

**Endpoint:** `POST /auth/login`  
**Authentication:** None  
**Description:** Đăng nhập và nhận JWT tokens.

**Request Body:**
```json
{
  "email": "user@example.com",          // Required
  "password": "password123"              // Required
}
```

**Response:** `200 OK`
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiJ9...",
  "tokenType": "Bearer",
  "refreshToken": "eyJhbGciOiJIUzI1NiJ9...",
  "expiresIn": 3600
}
```

**Error Responses:**
- `401 Unauthorized`: Invalid credentials
- `403 Forbidden`: Account not verified or inactive

---

### 1.3. Refresh Token

**Endpoint:** `POST /auth/refresh`  
**Authentication:** None (uses refresh token)  
**Description:** Lấy access token mới bằng refresh token.

**Request Body:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiJ9..."
}
```

**Response:** `200 OK`
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiJ9...",
  "tokenType": "Bearer",
  "refreshToken": "eyJhbGciOiJIUzI1NiJ9...",
  "expiresIn": 3600
}
```

---

### 1.4. Verify Email

**Endpoint:** `GET /auth/verify?token={verifyToken}`  
**Authentication:** None  
**Description:** Xác thực email qua token nhận từ email.

**Query Parameters:**
- `token` (string, required): Verification token from email

**Response:** `200 OK`
```json
{
  "message": "Email verified successfully"
}
```

**Error Responses:**
- `400 Bad Request`: Invalid or expired token

---

### 1.5. Get Current User Info

**Endpoint:** `GET /auth/user-info`  
**Authentication:** Required (Bearer Token)  
**Description:** Lấy thông tin user hiện tại từ JWT token.

**Response:** `200 OK`
```json
{
  "id": 1,
  "email": "user@example.com",
  "fullName": "Nguyễn Văn A",
  "roleName": "USER",
  "status": "ACTIVE",
  "eloScore": 1200,
  "eloRank": "BRONZE",
  "createdAt": "2024-01-15T10:30:00"
}
```

---

## 2. User Management

### 2.1. Get User by ID

**Endpoint:** `GET /users/{id}`  
**Authentication:** Required  
**Description:** Lấy thông tin chi tiết một user.

**Path Parameters:**
- `id` (long, required): User ID

**Response:** `200 OK`
```json
{
  "id": 1,
  "roleId": 1,
  "roleName": "USER",
  "email": "user@example.com",
  "fullName": "Nguyễn Văn A",
  "dateOfBirth": "1995-05-20",
  "address": "123 Main St, Hanoi",
  "status": "ACTIVE",
  "isStudying": true,
  "eloScore": 1200,
  "eloRank": "BRONZE",
  "createdAt": "2024-01-15T10:30:00"
}
```

**Error Responses:**
- `404 Not Found`: User not found

---

### 2.2. Update User Profile

**Endpoint:** `PUT /users/{id}`  
**Authentication:** Required (USER or ADMIN)  
**Description:** Cập nhật thông tin profile (user chỉ update được của mình).

**Path Parameters:**
- `id` (long, required): User ID

**Request Body:**
```json
{
  "email": "newemail@example.com",      // Required
  "password": "newpassword123",          // Required
  "fullName": "Nguyễn Văn B",           // Optional
  "dateOfBirth": "1996-06-15",          // Optional
  "address": "456 New St, Hanoi",       // Optional
  "isStudying": false                    // Optional
}
```

**Response:** `200 OK` - UserResponse object

**Error Responses:**
- `403 Forbidden`: User can only update their own profile
- `404 Not Found`: User not found

---

### 2.3. Update User Role (Admin Only)

**Endpoint:** `PUT /users/{id}/role`  
**Authentication:** Required (ADMIN only)  
**Description:** Thay đổi role của user.

**Path Parameters:**
- `id` (long, required): User ID

**Request Body:**
```json
{
  "roleId": 2                            // Required: 1=USER, 2=RECRUITER, 3=ADMIN
}
```

**Response:** `200 OK` - UserResponse object

---

### 2.4. Update User Status (Admin Only)

**Endpoint:** `PUT /users/{id}/status`  
**Authentication:** Required (ADMIN only)  
**Description:** Thay đổi trạng thái user (active, inactive, banned).

**Path Parameters:**
- `id` (long, required): User ID

**Request Body:**
```json
{
  "status": "BANNED"                     // Required: "PENDING" | "ACTIVE" | "INACTIVE" | "BANNED"
}
```

**Response:** `200 OK` - UserResponse object

---

### 2.5. Apply ELO Score

**Endpoint:** `POST /users/elo`  
**Authentication:** Required  
**Description:** Cập nhật điểm ELO sau khi hoàn thành exam.

**Request Body:**
```json
{
  "userId": 1,                           // Required
  "score": 50,                           // Required, positive or negative integer
  "reason": "Completed Java Exam"        // Optional
}
```

**Response:** `200 OK`
```json
{
  "id": 1,
  "eloScore": 1250,
  "eloRank": "SILVER",
  ...
}
```

**ELO Rank Tiers:**
- **NEWBIE**: 0-799
- **BRONZE**: 800-1199
- **SILVER**: 1200-1599
- **GOLD**: 1600-1999
- **PLATINUM**: 2000-2399
- **DIAMOND**: 2400+

---

### 2.6. Get All Users (Admin Only)

**Endpoint:** `GET /users?page=0&size=20`  
**Authentication:** Required (ADMIN only)  
**Description:** Lấy danh sách tất cả users với pagination.

**Query Parameters:**
- `page` (int, optional, default: 0): Page number
- `size` (int, optional, default: 20): Page size

**Response:** `200 OK`
```json
{
  "content": [
    {
      "id": 1,
      "email": "user@example.com",
      "fullName": "Nguyễn Văn A",
      "roleName": "USER",
      "status": "ACTIVE",
      "eloScore": 1200,
      ...
    }
  ],
  "totalElements": 100,
  "totalPages": 5,
  "size": 20,
  "number": 0,
  "first": true,
  "last": false
}
```

---

### 2.7. Get Users by Role (Admin Only)

**Endpoint:** `GET /users/role/{roleId}?page=0&size=20`  
**Authentication:** Required (ADMIN only)

**Path Parameters:**
- `roleId` (long, required): 1=USER, 2=RECRUITER, 3=ADMIN

**Response:** Same as 2.6 (Paginated UserResponse)

---

### 2.8. Get Users by Status (Admin Only)

**Endpoint:** `GET /users/status/{status}?page=0&size=20`  
**Authentication:** Required (ADMIN only)

**Path Parameters:**
- `status` (string, required): PENDING | ACTIVE | INACTIVE | BANNED

**Response:** Same as 2.6 (Paginated UserResponse)

---

### 2.9. Get All Roles

**Endpoint:** `GET /users/roles`  
**Authentication:** Required  
**Description:** Lấy danh sách tất cả roles có trong hệ thống.

**Response:** `200 OK`
```json
[
  {
    "id": 1,
    "roleName": "USER",
    "description": "Regular user"
  },
  {
    "id": 2,
    "roleName": "RECRUITER",
    "description": "Company recruiter"
  },
  {
    "id": 3,
    "roleName": "ADMIN",
    "description": "System administrator"
  }
]
```

---

### 2.10. Delete User (Admin Only)

**Endpoint:** `DELETE /users/{id}`  
**Authentication:** Required (ADMIN only)

**Path Parameters:**
- `id` (long, required): User ID

**Response:** `204 No Content`

---

## 3. Question Management

### 3.1. Fields Management

#### 3.1.1. Create Field (Admin Only)

**Endpoint:** `POST /questions/fields`  
**Authentication:** Required (ADMIN)  
**Description:** Tạo lĩnh vực mới (Java, Python, JavaScript, etc.).

**Request Body:**
```json
{
  "name": "Java Programming",            // Required, max 100 chars
  "description": "Java và Spring Boot"   // Optional, max 500 chars
}
```

**Response:** `200 OK`
```json
{
  "id": 1,
  "name": "Java Programming",
  "description": "Java và Spring Boot"
}
```

---

#### 3.1.2. Get All Fields

**Endpoint:** `GET /questions/fields?page=0&size=20`  
**Authentication:** Required

**Response:** `200 OK` - Paginated FieldResponse

---

#### 3.1.3. Get Field by ID

**Endpoint:** `GET /questions/fields/{id}`  
**Authentication:** Required

**Response:** `200 OK` - FieldResponse object

---

#### 3.1.4. Update Field (Admin Only)

**Endpoint:** `PUT /questions/fields/{id}`  
**Authentication:** Required (ADMIN)

**Request Body:** Same as 3.1.1  
**Response:** `200 OK` - FieldResponse object

---

#### 3.1.5. Delete Field (Admin Only)

**Endpoint:** `DELETE /questions/fields/{id}`  
**Authentication:** Required (ADMIN)

**Response:** `204 No Content`

---

### 3.2. Topics Management

#### 3.2.1. Create Topic (Admin Only)

**Endpoint:** `POST /questions/topics`  
**Authentication:** Required (ADMIN)

**Request Body:**
```json
{
  "fieldId": 1,                          // Required
  "name": "Spring Boot",                 // Required, max 100 chars
  "description": "Spring Boot Framework" // Optional, max 500 chars
}
```

**Response:** `200 OK`
```json
{
  "id": 1,
  "fieldId": 1,
  "fieldName": "Java Programming",
  "name": "Spring Boot",
  "description": "Spring Boot Framework"
}
```

---

#### 3.2.2. Get All Topics

**Endpoint:** `GET /questions/topics?page=0&size=20`  
**Authentication:** Required

**Response:** `200 OK` - Paginated TopicResponse

---

#### 3.2.3. Get Topic by ID

**Endpoint:** `GET /questions/topics/{id}`  
**Authentication:** Required

**Response:** `200 OK` - TopicResponse object

---

#### 3.2.4. Update Topic (Admin Only)

**Endpoint:** `PUT /questions/topics/{id}`  
**Authentication:** Required (ADMIN)

**Request Body:**
```json
{
  "fieldId": 1,                          // Required
  "name": "Spring Boot Advanced",        // Required
  "description": "Advanced topics"       // Optional
}
```

**Response:** `200 OK` - TopicResponse object

---

#### 3.2.5. Delete Topic (Admin Only)

**Endpoint:** `DELETE /questions/topics/{id}`  
**Authentication:** Required (ADMIN)

**Response:** `204 No Content`

---

### 3.3. Levels Management

#### 3.3.1. Create Level (Admin Only)

**Endpoint:** `POST /questions/levels`  
**Authentication:** Required (ADMIN)

**Request Body:**
```json
{
  "name": "Medium",                      // Required, max 50 chars
  "description": "Medium difficulty"     // Optional, max 500 chars
}
```

**Response:** `200 OK`
```json
{
  "id": 1,
  "name": "Medium",
  "description": "Medium difficulty"
}
```

---

#### 3.3.2. Get All Levels

**Endpoint:** `GET /questions/levels?page=0&size=20`  
**Authentication:** Required

**Response:** `200 OK` - Paginated LevelResponse

---

#### 3.3.3. Get Level by ID

**Endpoint:** `GET /questions/levels/{id}`  
**Authentication:** Required

**Response:** `200 OK` - LevelResponse object

---

#### 3.3.4. Update Level (Admin Only)

**Endpoint:** `PUT /questions/levels/{id}`  
**Authentication:** Required (ADMIN)

**Request Body:** Same as 3.3.1  
**Response:** `200 OK` - LevelResponse object

---

#### 3.3.5. Delete Level (Admin Only)

**Endpoint:** `DELETE /questions/levels/{id}`  
**Authentication:** Required (ADMIN)

**Response:** `204 No Content`

---

### 3.4. Question Types Management

#### 3.4.1. Create Question Type (Admin Only)

**Endpoint:** `POST /questions/question-types`  
**Authentication:** Required (ADMIN)

**Request Body:**
```json
{
  "name": "Multiple Choice",             // Required, max 100 chars
  "description": "Choose one correct answer" // Optional, max 500 chars
}
```

**Response:** `200 OK`
```json
{
  "id": 1,
  "name": "Multiple Choice",
  "description": "Choose one correct answer"
}
```

---

#### 3.4.2. Get All Question Types

**Endpoint:** `GET /questions/question-types?page=0&size=20`  
**Authentication:** Required

**Response:** `200 OK` - Paginated QuestionTypeResponse

---

#### 3.4.3. Get Question Type by ID

**Endpoint:** `GET /questions/question-types/{id}`  
**Authentication:** Required

**Response:** `200 OK` - QuestionTypeResponse object

---

#### 3.4.4. Update Question Type (Admin Only)

**Endpoint:** `PUT /questions/question-types/{id}`  
**Authentication:** Required (ADMIN)

**Request Body:** Same as 3.4.1  
**Response:** `200 OK` - QuestionTypeResponse object

---

#### 3.4.5. Delete Question Type (Admin Only)

**Endpoint:** `DELETE /questions/question-types/{id}`  
**Authentication:** Required (ADMIN)

**Response:** `204 No Content`

---

### 3.5. Questions Management

#### 3.5.1. Create Question (User/Admin)

**Endpoint:** `POST /questions`  
**Authentication:** Required (USER or ADMIN)  
**Description:** Tạo câu hỏi mới. Status mặc định là PENDING, cần admin approve.

**Request Body:**
```json
{
  "userId": 1,                           // Required
  "topicId": 1,                          // Required
  "fieldId": 1,                          // Required
  "levelId": 2,                          // Required
  "questionTypeId": 1,                   // Required
  "content": "What is dependency injection?", // Required, max 5000 chars
  "answer": "Dependency injection is...",     // Required, max 5000 chars
  "language": "EN"                       // Required: "EN" | "VI"
}
```

**Response:** `200 OK`
```json
{
  "id": 1,
  "userId": 1,
  "topicId": 1,
  "fieldId": 1,
  "levelId": 2,
  "questionTypeId": 1,
  "questionContent": "What is dependency injection?",
  "questionAnswer": "Dependency injection is...",
  "similarityScore": null,
  "status": "PENDING",
  "language": "EN",
  "createdAt": "2024-01-15T10:30:00",
  "approvedAt": null,
  "approvedBy": null,
  "usefulVote": 0,
  "unusefulVote": 0,
  "fieldName": "Java Programming",
  "topicName": "Spring Boot",
  "levelName": "Medium",
  "questionTypeName": "Multiple Choice"
}
```

**Validation:**
- All IDs must exist in database
- content và answer không được trống
- language must be EN or VI

---

#### 3.5.2. Get All Questions

**Endpoint:** `GET /questions?page=0&size=20`  
**Authentication:** Required

**Response:** `200 OK` - Paginated QuestionResponse

---

#### 3.5.3. Get Question by ID

**Endpoint:** `GET /questions/{id}`  
**Authentication:** Required

**Response:** `200 OK` - QuestionResponse object (with relationship names)

---

#### 3.5.4. Update Question (Admin Only)

**Endpoint:** `PUT /questions/{id}`  
**Authentication:** Required (ADMIN)

**Request Body:** Same as 3.5.1  
**Response:** `200 OK` - QuestionResponse object

---

#### 3.5.5. Delete Question (Admin Only)

**Endpoint:** `DELETE /questions/{id}`  
**Authentication:** Required (ADMIN)

**Response:** `204 No Content`

---

#### 3.5.6. Approve Question (Admin Only)

**Endpoint:** `POST /questions/{id}/approve?adminId={adminId}`  
**Authentication:** Required (ADMIN)  
**Description:** Phê duyệt câu hỏi, chuyển status thành APPROVED.

**Path Parameters:**
- `id` (long, required): Question ID

**Query Parameters:**
- `adminId` (long, required): Admin user ID

**Response:** `200 OK` - QuestionResponse object with status=APPROVED

---

#### 3.5.7. Reject Question (Admin Only)

**Endpoint:** `POST /questions/{id}/reject?adminId={adminId}`  
**Authentication:** Required (ADMIN)

**Response:** `200 OK` - QuestionResponse object with status=REJECTED

---

#### 3.5.8. Get Questions by Topic

**Endpoint:** `GET /questions/topics/{topicId}/questions?page=0&size=20`  
**Authentication:** Required

**Path Parameters:**
- `topicId` (long, required): Topic ID

**Response:** `200 OK` - Paginated QuestionResponse

---

### 3.6. Answers Management

#### 3.6.1. Create Answer

**Endpoint:** `POST /questions/answers`  
**Authentication:** Required

**Request Body:**
```json
{
  "userId": 1,                           // Required
  "questionId": 1,                       // Required
  "questionTypeId": 1,                   // Required
  "content": "Option A: Constructor injection", // Required, max 5000 chars
  "isCorrect": true,                     // Optional, boolean
  "isSampleAnswer": false,               // Optional, boolean
  "orderNumber": 1                       // Optional, integer
}
```

**Response:** `200 OK`
```json
{
  "id": 1,
  "userId": 1,
  "questionId": 1,
  "questionTypeId": 1,
  "content": "Option A: Constructor injection",
  "isCorrect": true,
  "isSampleAnswer": false,
  "orderNumber": 1,
  "usefulVote": 0,
  "unusefulVote": 0,
  "createdAt": "2024-01-15T10:30:00"
}
```

---

#### 3.6.2. Get All Answers

**Endpoint:** `GET /questions/answers?page=0&size=20`  
**Authentication:** Required

**Response:** `200 OK` - Paginated AnswerResponse

---

#### 3.6.3. Get Answer by ID

**Endpoint:** `GET /questions/answers/{id}`  
**Authentication:** Required

**Response:** `200 OK` - AnswerResponse object

---

#### 3.6.4. Update Answer

**Endpoint:** `PUT /questions/answers/{id}`  
**Authentication:** Required

**Request Body:** Same as 3.6.1  
**Response:** `200 OK` - AnswerResponse object

---

#### 3.6.5. Delete Answer

**Endpoint:** `DELETE /questions/answers/{id}`  
**Authentication:** Required

**Response:** `204 No Content`

---

#### 3.6.6. Mark as Sample Answer

**Endpoint:** `POST /questions/answers/{id}/sample?isSample=true`  
**Authentication:** Required (ADMIN)

**Query Parameters:**
- `isSample` (boolean, required): true to mark as sample, false to unmark

**Response:** `200 OK` - AnswerResponse object

---

#### 3.6.7. Get Answers by Question

**Endpoint:** `GET /questions/{questionId}/answers?page=0&size=20`  
**Authentication:** Required

**Path Parameters:**
- `questionId` (long, required): Question ID

**Response:** `200 OK` - Paginated AnswerResponse

---

## 4. Exam Management

### 4.1. Create Exam

**Endpoint:** `POST /exams`  
**Authentication:** Required (ADMIN or RECRUITER)  
**Description:** Tạo bài thi mới. Status mặc định là DRAFT.

**Request Body:**
```json
{
  "userId": 1,                           // Required
  "examType": "VIRTUAL",                 // Required: "VIRTUAL" | "RECRUITER"
  "title": "Spring Boot Advanced Test",  // Required, max 200 chars
  "position": "Backend Developer",       // Optional
  "topics": [1, 2, 3],                   // Required, array of topic IDs (min 1)
  "questionTypes": [1, 2],               // Required, array of question type IDs (min 1)
  "questionCount": 20,                   // Required, min 1, max 100
  "duration": 60,                        // Required, minutes, min 1
  "language": "EN"                       // Required: "EN" | "VI"
}
```

**Response:** `200 OK`
```json
{
  "id": 1,
  "userId": 1,
  "examType": "VIRTUAL",
  "title": "Spring Boot Advanced Test",
  "position": "Backend Developer",
  "topics": [1, 2, 3],
  "questionTypes": [1, 2],
  "questionCount": 20,
  "duration": 60,
  "startTime": null,
  "endTime": null,
  "status": "DRAFT",
  "language": "EN",
  "createdAt": "2024-01-15T10:30:00",
  "createdBy": 1
}
```

**Exam Status Flow:**
- **DRAFT**: Initial state (editable)
- **PUBLISHED**: Available for registration
- **ONGOING**: Currently active
- **COMPLETED**: Finished
- **CANCELLED**: Cancelled by admin

---

### 4.2. Get Exam by ID

**Endpoint:** `GET /exams/{id}`  
**Authentication:** Required

**Path Parameters:**
- `id` (long, required): Exam ID

**Response:** `200 OK` - ExamResponse object

---

### 4.3. Update Exam (Admin/Recruiter)

**Endpoint:** `PUT /exams/{id}`  
**Authentication:** Required (ADMIN or RECRUITER)  
**Description:** Chỉ có thể update exam ở trạng thái DRAFT.

**Request Body:** Same as 4.1  
**Response:** `200 OK` - ExamResponse object

---

### 4.4. Delete Exam (Admin/Recruiter)

**Endpoint:** `DELETE /exams/{id}`  
**Authentication:** Required (ADMIN or RECRUITER)

**Response:** `204 No Content`

---

### 4.5. Publish Exam

**Endpoint:** `POST /exams/{examId}/publish?userId={userId}`  
**Authentication:** Required (ADMIN or RECRUITER)  
**Description:** Xuất bản exam, cho phép users đăng ký.

**Path Parameters:**
- `examId` (long, required): Exam ID

**Query Parameters:**
- `userId` (long, required): Publisher user ID

**Response:** `200 OK` - ExamResponse với status=PUBLISHED

---

### 4.6. Start Exam

**Endpoint:** `POST /exams/{examId}/start`  
**Authentication:** Required (ADMIN or RECRUITER)  
**Description:** Bắt đầu exam, chuyển status thành ONGOING.

**Response:** `200 OK` - ExamResponse với status=ONGOING

---

### 4.7. Complete Exam

**Endpoint:** `POST /exams/{examId}/complete`  
**Authentication:** Required (ADMIN or RECRUITER)

**Response:** `200 OK` - ExamResponse với status=COMPLETED

---

### 4.8. Get All Exams

**Endpoint:** `GET /exams?page=0&size=20`  
**Authentication:** Required

**Response:** `200 OK` - Paginated ExamResponse

---

### 4.9. Get Exams by User

**Endpoint:** `GET /exams/user/{userId}?page=0&size=20`  
**Authentication:** Required

**Path Parameters:**
- `userId` (long, required): User ID

**Response:** `200 OK` - Paginated ExamResponse

---

### 4.10. Get Exams by Type

**Endpoint:** `GET /exams/type?type=VIRTUAL&page=0&size=20`  
**Authentication:** Required

**Query Parameters:**
- `type` (string, required): VIRTUAL | RECRUITER
- `page`, `size`: Pagination

**Response:** `200 OK` - Paginated ExamResponse

---

### 4.11. Get Exam Types

**Endpoint:** `GET /exams/types`  
**Authentication:** Required

**Response:** `200 OK`
```json
["VIRTUAL", "RECRUITER"]
```

---

### 4.12. Add Question to Exam

**Endpoint:** `POST /exams/questions`  
**Authentication:** Required (ADMIN or RECRUITER)

**Request Body:**
```json
{
  "examId": 1,                           // Required
  "questionId": 5,                       // Required
  "orderNumber": 1                       // Optional
}
```

**Response:** `200 OK`
```json
{
  "id": 1,
  "examId": 1,
  "questionId": 5,
  "orderNumber": 1
}
```

---

### 4.13. Remove Questions from Exam

**Endpoint:** `DELETE /exams/{examId}/questions`  
**Authentication:** Required (ADMIN or RECRUITER)

**Path Parameters:**
- `examId` (long, required): Exam ID

**Description:** Xóa tất cả questions khỏi exam.  
**Response:** `204 No Content`

---

### 4.14. Submit Exam Result

**Endpoint:** `POST /exams/results`  
**Authentication:** Required

**Request Body:**
```json
{
  "examId": 1,                           // Required
  "userId": 1,                           // Required
  "score": 85.5,                         // Required, min 0.0, max 100.0
  "passStatus": true,                    // Optional
  "feedback": "Good performance"         // Optional
}
```

**Response:** `200 OK`
```json
{
  "id": 1,
  "examId": 1,
  "userId": 1,
  "score": 85.5,
  "passStatus": true,
  "feedback": "Good performance",
  "completedAt": "2024-01-15T11:30:00"
}
```

---

### 4.15. Get Result by ID

**Endpoint:** `GET /exams/results/{id}`  
**Authentication:** Required (USER or ADMIN)

**Response:** `200 OK` - ResultResponse object

---

### 4.16. Get Results by Exam

**Endpoint:** `GET /exams/{examId}/results?page=0&size=20`  
**Authentication:** Required (ADMIN or RECRUITER)

**Path Parameters:**
- `examId` (long, required): Exam ID

**Response:** `200 OK` - Paginated ResultResponse

---

### 4.17. Get Results by User

**Endpoint:** `GET /exams/results/user/{userId}?page=0&size=20`  
**Authentication:** Required (USER or ADMIN)

**Path Parameters:**
- `userId` (long, required): User ID

**Response:** `200 OK` - Paginated ResultResponse

---

### 4.18. Submit User Answer

**Endpoint:** `POST /exams/answers`  
**Authentication:** Required

**Request Body:**
```json
{
  "examId": 1,                           // Required
  "userId": 1,                           // Required
  "questionId": 5,                       // Required
  "answer": "Option A",                  // Required, max 5000 chars
  "isCorrect": true                      // Optional
}
```

**Response:** `200 OK`
```json
{
  "id": 1,
  "examId": 1,
  "userId": 1,
  "questionId": 5,
  "answer": "Option A",
  "isCorrect": true,
  "createdAt": "2024-01-15T10:45:00"
}
```

---

### 4.19. Get User Answer by ID

**Endpoint:** `GET /exams/answers/{id}`  
**Authentication:** Required (USER or ADMIN)

**Response:** `200 OK` - UserAnswerResponse object

---

### 4.20. Get Answers by Exam and User

**Endpoint:** `GET /exams/{examId}/answers/{userId}?page=0&size=20`  
**Authentication:** Required

**Path Parameters:**
- `examId` (long, required): Exam ID
- `userId` (long, required): User ID

**Response:** `200 OK` - Paginated UserAnswerResponse

---

### 4.21. Register for Exam

**Endpoint:** `POST /exams/registrations`  
**Authentication:** Required (USER)

**Request Body:**
```json
{
  "examId": 1,                           // Required
  "userId": 1,                           // Required
  "registrationStatus": "REGISTERED"     // Optional: "REGISTERED" | "CANCELLED"
}
```

**Response:** `200 OK`
```json
{
  "id": 1,
  "examId": 1,
  "userId": 1,
  "registrationStatus": "REGISTERED",
  "registeredAt": "2024-01-15T10:00:00"
}
```

---

### 4.22. Get Registration by ID

**Endpoint:** `GET /exams/registrations/{id}`  
**Authentication:** Required (USER or ADMIN)

**Response:** `200 OK` - ExamRegistrationResponse object

---

### 4.23. Cancel Registration

**Endpoint:** `POST /exams/registrations/{registrationId}/cancel`  
**Authentication:** Required (USER)

**Path Parameters:**
- `registrationId` (long, required): Registration ID

**Response:** `200 OK` - ExamRegistrationResponse với status=CANCELLED

---

### 4.24. Get Registrations by Exam

**Endpoint:** `GET /exams/{examId}/registrations?page=0&size=20`  
**Authentication:** Required (ADMIN or RECRUITER)

**Path Parameters:**
- `examId` (long, required): Exam ID

**Response:** `200 OK` - Paginated ExamRegistrationResponse

---

### 4.25. Get Registrations by User

**Endpoint:** `GET /exams/registrations/user/{userId}?page=0&size=20`  
**Authentication:** Required

**Path Parameters:**
- `userId` (long, required): User ID

**Response:** `200 OK` - Paginated ExamRegistrationResponse

---

## 5. News Management

### 5.1. Create News

**Endpoint:** `POST /news`  
**Authentication:** Required (USER/ADMIN/RECRUITER)  
**Description:** Tạo bài viết tin tức hoặc tuyển dụng. Status mặc định là PENDING.

**Request Body:**
```json
{
  "userId": 1,                           // Required
  "title": "React 18 New Features",      // Required, max 200 chars
  "content": "React 18 introduces...",   // Required, max 10000 chars
  "fieldId": 1,                          // Optional
  "examId": null,                        // Optional
  "newsType": "NEWS",                    // Required: "NEWS" | "RECRUITMENT"
  
  // Recruitment-specific fields (optional, for newsType=RECRUITMENT)
  "companyName": "ABC Tech Corp",        // Optional
  "location": "Hanoi, Vietnam",          // Optional
  "salary": "$2000-$3000",               // Optional
  "experience": "2+ years",              // Optional
  "position": "Senior Backend Developer",// Optional
  "workingHours": "Mon-Fri, 9am-6pm",   // Optional
  "deadline": "2024-02-28",              // Optional
  "applicationMethod": "email@company.com" // Optional
}
```

**Response:** `200 OK`
```json
{
  "id": 1,
  "userId": 1,
  "title": "React 18 New Features",
  "content": "React 18 introduces...",
  "fieldId": 1,
  "examId": null,
  "newsType": "NEWS",
  "status": "PENDING",
  "createdAt": "2024-01-15T10:30:00",
  "publishedAt": null,
  "expiredAt": null,
  "approvedBy": null,
  "usefulVote": 0,
  "interestVote": 0,
  "companyName": null,
  "location": null,
  "salary": null,
  "experience": null,
  "position": null,
  "workingHours": null,
  "deadline": null,
  "applicationMethod": null
}
```

**News Status Flow:**
- **PENDING**: Initial state, waiting for approval
- **APPROVED**: Approved by admin, ready to publish
- **REJECTED**: Rejected by admin
- **PUBLISHED**: Live and visible to users
- **EXPIRED**: News past expiration time (48h for NEWS, no expiration for RECRUITMENT)

---

### 5.2. Get News by ID

**Endpoint:** `GET /news/{id}`  
**Authentication:** None (public)

**Path Parameters:**
- `id` (long, required): News ID

**Response:** `200 OK` - NewsResponse object

---

### 5.3. Update News

**Endpoint:** `PUT /news/{id}`  
**Authentication:** Required (USER/ADMIN/RECRUITER)  
**Description:** Chỉ update được khi status=PENDING.

**Request Body:** Same as 5.1  
**Response:** `200 OK` - NewsResponse object

---

### 5.4. Delete News

**Endpoint:** `DELETE /news/{id}`  
**Authentication:** Required (ADMIN or RECRUITER)

**Response:** `204 No Content`

---

### 5.5. Approve News (Admin Only)

**Endpoint:** `POST /news/{newsId}/approve?adminId={adminId}`  
**Authentication:** Required (ADMIN)  
**Description:** Phê duyệt bài viết. Tự động set publishedAt và expiredAt (48h cho NEWS).

**Path Parameters:**
- `newsId` (long, required): News ID

**Query Parameters:**
- `adminId` (long, required): Admin user ID

**Response:** `200 OK` - NewsResponse với status=APPROVED

---

### 5.6. Reject News (Admin Only)

**Endpoint:** `POST /news/{newsId}/reject?adminId={adminId}`  
**Authentication:** Required (ADMIN)

**Response:** `200 OK` - NewsResponse với status=REJECTED

---

### 5.7. Publish News (Admin Only)

**Endpoint:** `POST /news/{newsId}/publish`  
**Authentication:** Required (ADMIN)  
**Description:** Xuất bản bài viết đã approved.

**Response:** `200 OK` - NewsResponse với status=PUBLISHED

---

### 5.8. Vote News

**Endpoint:** `POST /news/{newsId}/vote?voteType=USEFUL`  
**Authentication:** Required (USER or ADMIN)  
**Description:** Vote bài viết (useful hoặc interest).

**Path Parameters:**
- `newsId` (long, required): News ID

**Query Parameters:**
- `voteType` (string, required): "USEFUL" | "INTEREST"

**Response:** `200 OK` - NewsResponse với vote count updated

---

### 5.9. Get All News

**Endpoint:** `GET /news?page=0&size=20`  
**Authentication:** None (public)

**Response:** `200 OK` - Paginated NewsResponse

---

### 5.10. Get News by Type

**Endpoint:** `GET /news/type?type=NEWS&page=0&size=20`  
**Authentication:** None (public)

**Query Parameters:**
- `type` (string, required): NEWS | RECRUITMENT
- `page`, `size`: Pagination

**Response:** `200 OK` - Paginated NewsResponse

---

### 5.11. Get News by User

**Endpoint:** `GET /news/user/{userId}?page=0&size=20`  
**Authentication:** Required (USER/ADMIN/RECRUITER)

**Path Parameters:**
- `userId` (long, required): User ID

**Response:** `200 OK` - Paginated NewsResponse

---

### 5.12. Get News by Status (Admin Only)

**Endpoint:** `GET /news/status/{status}?page=0&size=20`  
**Authentication:** Required (ADMIN)

**Path Parameters:**
- `status` (string, required): PENDING | APPROVED | REJECTED | PUBLISHED | EXPIRED

**Response:** `200 OK` - Paginated NewsResponse

---

### 5.13. Get News by Field

**Endpoint:** `GET /news/field/{fieldId}?page=0&size=20`  
**Authentication:** None (public)

**Path Parameters:**
- `fieldId` (long, required): Field ID

**Response:** `200 OK` - Paginated NewsResponse

---

### 5.14. Get Published News by Type

**Endpoint:** `GET /news/published/{newsType}?page=0&size=20`  
**Authentication:** None (public)  
**Description:** Chỉ lấy news đã published.

**Path Parameters:**
- `newsType` (string, required): NEWS | RECRUITMENT

**Response:** `200 OK` - Paginated NewsResponse

---

### 5.15. Get Pending Moderation (Admin Only)

**Endpoint:** `GET /news/moderation/pending?page=0&size=20`  
**Authentication:** Required (ADMIN)  
**Description:** Lấy tất cả news đang chờ phê duyệt.

**Response:** `200 OK` - Paginated NewsResponse

---

### 5.16. Get News Types

**Endpoint:** `GET /news/types`  
**Authentication:** None (public)

**Response:** `200 OK`
```json
["NEWS", "RECRUITMENT"]
```

---

## 6. Career Management

### 6.1. Create Career Preference

**Endpoint:** `POST /career`  
**Authentication:** Required

**Request Body:**
```json
{
  "userId": 1,                           // Required
  "fieldId": 1,                          // Required
  "examId": 5                            // Required
}
```

**Response:** `200 OK`
```json
{
  "id": 1,
  "userId": 1,
  "fieldId": 1,
  "examId": 5,
  "createdAt": "2024-01-15T10:30:00"
}
```

---

### 6.2. Get Career Preference by ID

**Endpoint:** `GET /career/{careerId}`  
**Authentication:** Required

**Path Parameters:**
- `careerId` (long, required): Career preference ID

**Response:** `200 OK` - CareerPreferenceResponse object

---

### 6.3. Update Career Preference

**Endpoint:** `PUT /career/update/{careerId}`  
**Authentication:** Required

**Path Parameters:**
- `careerId` (long, required): Career preference ID

**Request Body:**
```json
{
  "userId": 1,                           // Required
  "fieldId": 2,                          // Required
  "examId": 7                            // Required
}
```

**Response:** `200 OK` - CareerPreferenceResponse object

---

### 6.4. Get Preferences by User

**Endpoint:** `GET /career/preferences/{userId}?page=0&size=20`  
**Authentication:** Required

**Path Parameters:**
- `userId` (long, required): User ID

**Response:** `200 OK` - Paginated CareerPreferenceResponse

---

### 6.5. Delete Career Preference

**Endpoint:** `DELETE /career/{careerId}`  
**Authentication:** Required

**Response:** `204 No Content`

---

## 7. Common Models & Error Handling

### 7.1. Pagination Response

**Standard pagination format for all list endpoints:**
```json
{
  "content": [
    // Array of objects
  ],
  "totalElements": 100,      // Total number of items
  "totalPages": 10,          // Total number of pages
  "size": 10,                // Page size
  "number": 0,               // Current page number (0-indexed)
  "first": true,             // Is first page
  "last": false,             // Is last page
  "numberOfElements": 10     // Number of items in current page
}
```

---

### 7.2. Error Response (RFC 7807)

**All error responses follow RFC 7807 Problem Details format:**
```json
{
  "type": "about:blank",
  "title": "Bad Request",
  "status": 400,
  "detail": "Email already exists",
  "instance": "/auth/register",
  "errorCode": "EMAIL_ALREADY_EXISTS",
  "traceId": "abc123",
  "timestamp": "2024-01-15T10:30:00Z",
  "details": {
    "field": "email",
    "rejectedValue": "user@example.com"
  }
}
```

---

### 7.3. HTTP Status Codes

- **200 OK**: Successful request
- **201 Created**: Resource created successfully
- **204 No Content**: Successful deletion
- **400 Bad Request**: Invalid input data
- **401 Unauthorized**: Missing or invalid authentication
- **403 Forbidden**: Insufficient permissions
- **404 Not Found**: Resource not found
- **409 Conflict**: Resource conflict (e.g., duplicate email)
- **500 Internal Server Error**: Server error

---

### 7.4. Authentication Header

**All protected endpoints require JWT token in header:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

---

### 7.5. Common Enums

#### User Status:
- `PENDING` - Waiting for email verification
- `ACTIVE` - Active user
- `INACTIVE` - Temporarily disabled
- `BANNED` - Permanently banned

#### ELO Ranks:
- `NEWBIE` (0-799)
- `BRONZE` (800-1199)
- `SILVER` (1200-1599)
- `GOLD` (1600-1999)
- `PLATINUM` (2000-2399)
- `DIAMOND` (2400+)

#### Role Names:
- `USER` (ID=1)
- `RECRUITER` (ID=2)
- `ADMIN` (ID=3)

#### Exam Types:
- `VIRTUAL` - Virtual interview
- `RECRUITER` - Recruiter-created exam

#### Exam Status:
- `DRAFT` - Editable
- `PUBLISHED` - Open for registration
- `ONGOING` - Currently active
- `COMPLETED` - Finished
- `CANCELLED` - Cancelled

#### News Types:
- `NEWS` - General news (expires after 48h)
- `RECRUITMENT` - Job posting (no expiration)

#### News Status:
- `PENDING` - Waiting for approval
- `APPROVED` - Approved by admin
- `REJECTED` - Rejected by admin
- `PUBLISHED` - Live
- `EXPIRED` - Past expiration

#### Question Status:
- `PENDING` - Waiting for approval
- `APPROVED` - Approved by admin
- `REJECTED` - Rejected by admin

#### Languages:
- `EN` - English
- `VI` - Vietnamese

---

### 7.6. Validation Rules Summary

**Email:**
- Required, valid email format
- Unique across system

**Password:**
- Minimum 6 characters
- Maximum 50 characters

**Titles/Names:**
- Question/Exam title: max 200 characters
- News title: max 200 characters
- Field/Topic/Level name: max 100 characters

**Content:**
- Question content: max 5000 characters
- Answer content: max 5000 characters
- News content: max 10000 characters

**Numbers:**
- Question count: 1-100
- Duration: min 1 minute
- Score: 0.0-100.0
- ELO score: integer

**IDs:**
- All ID fields must reference existing entities

---

## 8. Example Frontend Integration

### 8.1. Login Flow

```javascript
// 1. Login
const loginResponse = await fetch('http://localhost:8080/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    email: 'user@example.com',
    password: 'password123'
  })
});
const { accessToken, refreshToken } = await loginResponse.json();

// Store tokens
localStorage.setItem('accessToken', accessToken);
localStorage.setItem('refreshToken', refreshToken);

// 2. Authenticated request
const userResponse = await fetch('http://localhost:8080/auth/user-info', {
  headers: {
    'Authorization': `Bearer ${accessToken}`
  }
});
const userInfo = await userResponse.json();
```

---

### 8.2. Pagination Example

```javascript
// Get paginated users
const page = 0;
const size = 20;
const response = await fetch(
  `http://localhost:8080/users?page=${page}&size=${size}`,
  {
    headers: {
      'Authorization': `Bearer ${accessToken}`
    }
  }
);
const data = await response.json();

console.log(`Total items: ${data.totalElements}`);
console.log(`Total pages: ${data.totalPages}`);
console.log(`Current page: ${data.number}`);
console.log(`Items:`, data.content);
```

---

### 8.3. Error Handling

```javascript
try {
  const response = await fetch('http://localhost:8080/auth/register', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(registrationData)
  });
  
  if (!response.ok) {
    const error = await response.json();
    // error follows RFC 7807 format
    console.error(`Error ${error.status}: ${error.title}`);
    console.error(`Detail: ${error.detail}`);
    console.error(`Error code: ${error.errorCode}`);
    if (error.details) {
      console.error('Validation errors:', error.details);
    }
  } else {
    const data = await response.json();
    // Handle success
  }
} catch (err) {
  console.error('Network error:', err);
}
```

---

## 9. Testing Credentials

**Test accounts available for development:**

```
Admin:
Email: admin@example.com
Password: password123

Recruiter:
Email: recruiter@example.com
Password: password123

User:
Email: user@example.com
Password: password123
```

⚠️ **WARNING:** These are test credentials for development only!

---

## 10. API Collections

**Postman Collection:** `postman-collections/ABC-Interview-ALL-Endpoints.postman_collection.json`

---

## 📞 Support

**For questions or issues:**
- Check Swagger UI: http://localhost:8080/swagger-ui.html (Gateway may not have swagger)
- Individual service swagger: http://localhost:{service-port}/swagger-ui.html
- Eureka Dashboard: http://localhost:8761

---

## TypeScript Types

### Core Types

```typescript
// ============================================================================
// AUTHENTICATION TYPES
// ============================================================================

export interface LoginRequest {
  email: string;
  password: string;
}

export interface RegisterRequest {
  email: string;
  password: string;
  roleName: 'USER' | 'RECRUITER' | 'ADMIN';
  fullName?: string;
  dateOfBirth?: string; // YYYY-MM-DD
  address?: string;
  isStudying?: boolean;
}

export interface TokenResponse {
  accessToken: string;
  tokenType: string;
  refreshToken: string;
  expiresIn: number;
  verifyToken?: string;
}

export interface RefreshRequest {
  refreshToken: string;
}

export interface UserInfo {
  id: number;
  email: string;
  fullName: string;
  roleName: string;
  status: UserStatus;
  eloScore: number;
  eloRank: EloRank;
  createdAt: string;
}

// ============================================================================
// USER TYPES
// ============================================================================

export type UserStatus = 'PENDING' | 'ACTIVE' | 'INACTIVE' | 'BANNED';
export type EloRank = 'NEWBIE' | 'BRONZE' | 'SILVER' | 'GOLD' | 'PLATINUM' | 'DIAMOND';
export type RoleName = 'USER' | 'RECRUITER' | 'ADMIN';

export interface UserResponse {
  id: number;
  roleId: number;
  roleName: RoleName;
  email: string;
  fullName: string;
  dateOfBirth?: string;
  address?: string;
  status: UserStatus;
  isStudying?: boolean;
  eloScore: number;
  eloRank: EloRank;
  createdAt: string;
  verifyToken?: string;
}

export interface UserRequest {
  email: string;
  password: string;
  fullName?: string;
  dateOfBirth?: string;
  address?: string;
  isStudying?: boolean;
}

export interface RoleUpdateRequest {
  roleId: number; // 1=USER, 2=RECRUITER, 3=ADMIN
}

export interface StatusUpdateRequest {
  status: UserStatus;
}

export interface EloApplyRequest {
  userId: number;
  score: number; // Can be positive or negative
  reason?: string;
}

export interface RoleResponse {
  id: number;
  roleName: RoleName;
  description: string;
}

// ============================================================================
// QUESTION TYPES
// ============================================================================

export interface FieldRequest {
  name: string; // max 100 chars
  description?: string; // max 500 chars
}

export interface FieldResponse {
  id: number;
  name: string;
  description?: string;
}

export interface TopicRequest {
  fieldId: number;
  name: string; // max 100 chars
  description?: string; // max 500 chars
}

export interface TopicResponse {
  id: number;
  fieldId: number;
  fieldName?: string;
  name: string;
  description?: string;
}

export interface LevelRequest {
  name: string; // max 50 chars
  description?: string; // max 500 chars
}

export interface LevelResponse {
  id: number;
  name: string;
  description?: string;
}

export interface QuestionTypeRequest {
  name: string; // max 100 chars
  description?: string; // max 500 chars
}

export interface QuestionTypeResponse {
  id: number;
  name: string;
  description?: string;
}

export type QuestionStatus = 'PENDING' | 'APPROVED' | 'REJECTED';
export type Language = 'EN' | 'VI';

export interface QuestionRequest {
  userId: number;
  topicId: number;
  fieldId: number;
  levelId: number;
  questionTypeId: number;
  content: string; // max 5000 chars
  answer: string; // max 5000 chars
  language: Language;
}

export interface QuestionResponse {
  id: number;
  userId: number;
  topicId: number;
  fieldId: number;
  levelId: number;
  questionTypeId: number;
  questionContent: string;
  questionAnswer: string;
  similarityScore?: number;
  status: QuestionStatus;
  language: Language;
  createdAt: string;
  approvedAt?: string;
  approvedBy?: number;
  usefulVote: number;
  unusefulVote: number;
  fieldName?: string;
  topicName?: string;
  levelName?: string;
  questionTypeName?: string;
}

export interface AnswerRequest {
  userId: number;
  questionId: number;
  questionTypeId: number;
  content: string; // max 5000 chars
  isCorrect?: boolean;
  isSampleAnswer?: boolean;
  orderNumber?: number;
}

export interface AnswerResponse {
  id: number;
  userId: number;
  questionId: number;
  questionTypeId: number;
  content: string;
  isCorrect?: boolean;
  isSampleAnswer?: boolean;
  orderNumber?: number;
  usefulVote: number;
  unusefulVote: number;
  createdAt: string;
}

// ============================================================================
// EXAM TYPES
// ============================================================================

export type ExamType = 'VIRTUAL' | 'RECRUITER';
export type ExamStatus = 'DRAFT' | 'PUBLISHED' | 'ONGOING' | 'COMPLETED' | 'CANCELLED';

export interface ExamRequest {
  userId: number;
  examType: ExamType;
  title: string; // max 200 chars
  position?: string;
  topics: number[]; // min 1 item
  questionTypes: number[]; // min 1 item
  questionCount: number; // 1-100
  duration: number; // minutes, min 1
  language: Language;
}

export interface ExamResponse {
  id: number;
  userId: number;
  examType: ExamType;
  title: string;
  position?: string;
  topics: number[];
  questionTypes: number[];
  questionCount: number;
  duration: number;
  startTime?: string;
  endTime?: string;
  status: ExamStatus;
  language: Language;
  createdAt: string;
  createdBy: number;
}

export interface ExamQuestionRequest {
  examId: number;
  questionId: number;
  orderNumber?: number;
}

export interface ExamQuestionResponse {
  id: number;
  examId: number;
  questionId: number;
  orderNumber?: number;
}

export interface ResultRequest {
  examId: number;
  userId: number;
  score: number; // 0.0-100.0
  passStatus?: boolean;
  feedback?: string;
}

export interface ResultResponse {
  id: number;
  examId: number;
  userId: number;
  score: number;
  passStatus?: boolean;
  feedback?: string;
  completedAt: string;
}

export interface UserAnswerRequest {
  examId: number;
  userId: number;
  questionId: number;
  answer: string; // max 5000 chars
  isCorrect?: boolean;
}

export interface UserAnswerResponse {
  id: number;
  examId: number;
  userId: number;
  questionId: number;
  answer: string;
  isCorrect?: boolean;
  createdAt: string;
}

export type RegistrationStatus = 'REGISTERED' | 'CANCELLED';

export interface ExamRegistrationRequest {
  examId: number;
  userId: number;
  registrationStatus?: RegistrationStatus;
}

export interface ExamRegistrationResponse {
  id: number;
  examId: number;
  userId: number;
  registrationStatus: RegistrationStatus;
  registeredAt: string;
}

// ============================================================================
// NEWS TYPES
// ============================================================================

export type NewsType = 'NEWS' | 'RECRUITMENT';
export type NewsStatus = 'PENDING' | 'APPROVED' | 'REJECTED' | 'PUBLISHED' | 'EXPIRED';
export type VoteType = 'USEFUL' | 'INTEREST';

export interface NewsRequest {
  userId: number;
  title: string; // max 200 chars
  content: string; // max 10000 chars
  fieldId?: number;
  examId?: number;
  newsType: NewsType;
  // Recruitment-specific fields (optional)
  companyName?: string;
  location?: string;
  salary?: string;
  experience?: string;
  position?: string;
  workingHours?: string;
  deadline?: string;
  applicationMethod?: string;
}

export interface NewsResponse {
  id: number;
  userId: number;
  title: string;
  content: string;
  fieldId?: number;
  examId?: number;
  newsType: NewsType;
  status: NewsStatus;
  createdAt: string;
  publishedAt?: string;
  expiredAt?: string;
  approvedBy?: number;
  usefulVote: number;
  interestVote: number;
  companyName?: string;
  location?: string;
  salary?: string;
  experience?: string;
  position?: string;
  workingHours?: string;
  deadline?: string;
  applicationMethod?: string;
}

// ============================================================================
// CAREER TYPES
// ============================================================================

export interface CareerPreferenceRequest {
  userId: number;
  fieldId: number;
  examId: number;
}

export interface CareerPreferenceResponse {
  id: number;
  userId: number;
  fieldId: number;
  examId: number;
  createdAt: string;
}

// ============================================================================
// PAGINATION & ERROR TYPES
// ============================================================================

export interface PaginatedResponse<T> {
  content: T[];
  totalElements: number;
  totalPages: number;
  size: number;
  number: number; // Current page (0-indexed)
  first: boolean;
  last: boolean;
  numberOfElements: number;
}

export interface ErrorResponse {
  type: string;
  title: string;
  status: number;
  detail: string;
  instance: string;
  errorCode: string;
  traceId: string;
  timestamp: string;
  details?: Record<string, string>;
}

// ============================================================================
// API CLIENT CONFIG
// ============================================================================

export interface APIConfig {
  baseURL: string;
  timeout?: number;
  headers?: Record<string, string>;
}

export interface RequestConfig {
  params?: Record<string, string | number>;
  headers?: Record<string, string>;
}
```

---

## Code Generation Templates

### React Hooks Example

```typescript
// useAuth.ts
import { useState, useEffect } from 'react';
import type { TokenResponse, UserInfo, LoginRequest } from './types';

export const useAuth = () => {
  const [token, setToken] = useState<string | null>(
    localStorage.getItem('accessToken')
  );
  const [user, setUser] = useState<UserInfo | null>(null);

  const login = async (credentials: LoginRequest) => {
    const response = await fetch('http://localhost:8080/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(credentials),
    });
    
    if (!response.ok) throw await response.json();
    
    const data: TokenResponse = await response.json();
    setToken(data.accessToken);
    localStorage.setItem('accessToken', data.accessToken);
    localStorage.setItem('refreshToken', data.refreshToken);
    
    // Fetch user info
    const userResponse = await fetch('http://localhost:8080/auth/user-info', {
      headers: { 'Authorization': `Bearer ${data.accessToken}` },
    });
    const userInfo: UserInfo = await userResponse.json();
    setUser(userInfo);
  };

  const logout = () => {
    setToken(null);
    setUser(null);
    localStorage.removeItem('accessToken');
    localStorage.removeItem('refreshToken');
  };

  return { token, user, login, logout };
};

// useQuestions.ts
import { useState, useEffect } from 'react';
import type { PaginatedResponse, QuestionResponse } from './types';

export const useQuestions = (page = 0, size = 20) => {
  const [data, setData] = useState<PaginatedResponse<QuestionResponse> | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const fetchQuestions = async () => {
      try {
        const token = localStorage.getItem('accessToken');
        const response = await fetch(
          `http://localhost:8080/questions?page=${page}&size=${size}`,
          {
            headers: {
              'Authorization': `Bearer ${token}`,
            },
          }
        );
        
        if (!response.ok) throw new Error('Failed to fetch');
        
        const data = await response.json();
        setData(data);
      } catch (err) {
        setError(err as Error);
      } finally {
        setLoading(false);
      }
    };

    fetchQuestions();
  }, [page, size]);

  return { data, loading, error };
};
```

---

### Vue 3 Composables Example

```typescript
// composables/useApi.ts
import { ref, type Ref } from 'vue';
import type { PaginatedResponse, ErrorResponse } from '@/types';

export const useApi = () => {
  const loading = ref(false);
  const error: Ref<ErrorResponse | null> = ref(null);

  const request = async <T>(
    url: string,
    options: RequestInit = {}
  ): Promise<T> => {
    loading.value = true;
    error.value = null;

    try {
      const token = localStorage.getItem('accessToken');
      const headers: HeadersInit = {
        'Content-Type': 'application/json',
        ...options.headers,
      };

      if (token) {
        headers['Authorization'] = `Bearer ${token}`;
      }

      const response = await fetch(`http://localhost:8080${url}`, {
        ...options,
        headers,
      });

      if (!response.ok) {
        const errorData = await response.json();
        error.value = errorData;
        throw errorData;
      }

      return await response.json();
    } finally {
      loading.value = false;
    }
  };

  return { request, loading, error };
};

// composables/useAuth.ts
import { ref, computed } from 'vue';
import { useApi } from './useApi';
import type { LoginRequest, TokenResponse, UserInfo } from '@/types';

const token = ref<string | null>(localStorage.getItem('accessToken'));
const user = ref<UserInfo | null>(null);

export const useAuth = () => {
  const { request } = useApi();
  const isAuthenticated = computed(() => !!token.value);

  const login = async (credentials: LoginRequest) => {
    const data = await request<TokenResponse>('/auth/login', {
      method: 'POST',
      body: JSON.stringify(credentials),
    });

    token.value = data.accessToken;
    localStorage.setItem('accessToken', data.accessToken);
    localStorage.setItem('refreshToken', data.refreshToken);

    // Fetch user info
    const userInfo = await request<UserInfo>('/auth/user-info');
    user.value = userInfo;
  };

  const logout = () => {
    token.value = null;
    user.value = null;
    localStorage.removeItem('accessToken');
    localStorage.removeItem('refreshToken');
  };

  return {
    token,
    user,
    isAuthenticated,
    login,
    logout,
  };
};
```

---

### Angular Service Example

```typescript
// services/auth.service.ts
import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { BehaviorSubject, Observable } from 'rxjs';
import { tap } from 'rxjs/operators';
import type { LoginRequest, TokenResponse, UserInfo } from '../types';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private baseUrl = 'http://localhost:8080';
  private tokenSubject = new BehaviorSubject<string | null>(
    localStorage.getItem('accessToken')
  );
  public token$ = this.tokenSubject.asObservable();

  constructor(private http: HttpClient) {}

  login(credentials: LoginRequest): Observable<TokenResponse> {
    return this.http
      .post<TokenResponse>(`${this.baseUrl}/auth/login`, credentials)
      .pipe(
        tap((response) => {
          localStorage.setItem('accessToken', response.accessToken);
          localStorage.setItem('refreshToken', response.refreshToken);
          this.tokenSubject.next(response.accessToken);
        })
      );
  }

  getUserInfo(): Observable<UserInfo> {
    return this.http.get<UserInfo>(`${this.baseUrl}/auth/user-info`);
  }

  logout(): void {
    localStorage.removeItem('accessToken');
    localStorage.removeItem('refreshToken');
    this.tokenSubject.next(null);
  }

  getAuthHeaders(): HttpHeaders {
    const token = this.tokenSubject.value;
    return new HttpHeaders({
      'Content-Type': 'application/json',
      ...(token && { Authorization: `Bearer ${token}` }),
    });
  }
}

// services/api.service.ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { AuthService } from './auth.service';
import type { PaginatedResponse } from '../types';

@Injectable({ providedIn: 'root' })
export class ApiService {
  private baseUrl = 'http://localhost:8080';

  constructor(
    private http: HttpClient,
    private auth: AuthService
  ) {}

  get<T>(url: string, params?: Record<string, any>): Observable<T> {
    return this.http.get<T>(`${this.baseUrl}${url}`, {
      headers: this.auth.getAuthHeaders(),
      params,
    });
  }

  post<T>(url: string, body: any): Observable<T> {
    return this.http.post<T>(`${this.baseUrl}${url}`, body, {
      headers: this.auth.getAuthHeaders(),
    });
  }

  put<T>(url: string, body: any): Observable<T> {
    return this.http.put<T>(`${this.baseUrl}${url}`, body, {
      headers: this.auth.getAuthHeaders(),
    });
  }

  delete<T>(url: string): Observable<T> {
    return this.http.delete<T>(`${this.baseUrl}${url}`, {
      headers: this.auth.getAuthHeaders(),
    });
  }

  getPaginated<T>(
    url: string,
    page = 0,
    size = 20
  ): Observable<PaginatedResponse<T>> {
    return this.get<PaginatedResponse<T>>(url, { page, size });
  }
}
```

---

### Axios Client Example

```typescript
// api/client.ts
import axios, { AxiosInstance, AxiosError } from 'axios';
import type { ErrorResponse } from './types';

class APIClient {
  private client: AxiosInstance;

  constructor(baseURL = 'http://localhost:8080') {
    this.client = axios.create({
      baseURL,
      timeout: 30000,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    // Request interceptor
    this.client.interceptors.request.use(
      (config) => {
        const token = localStorage.getItem('accessToken');
        if (token) {
          config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
      },
      (error) => Promise.reject(error)
    );

    // Response interceptor
    this.client.interceptors.response.use(
      (response) => response,
      async (error: AxiosError<ErrorResponse>) => {
        if (error.response?.status === 401) {
          // Try refresh token
          try {
            const refreshToken = localStorage.getItem('refreshToken');
            const { data } = await axios.post(
              `${baseURL}/auth/refresh`,
              { refreshToken }
            );
            localStorage.setItem('accessToken', data.accessToken);
            // Retry original request
            if (error.config) {
              error.config.headers.Authorization = `Bearer ${data.accessToken}`;
              return this.client.request(error.config);
            }
          } catch (refreshError) {
            // Refresh failed, logout
            localStorage.removeItem('accessToken');
            localStorage.removeItem('refreshToken');
            window.location.href = '/login';
          }
        }
        return Promise.reject(error.response?.data || error);
      }
    );
  }

  // Auth
  async login(email: string, password: string) {
    const { data } = await this.client.post('/auth/login', { email, password });
    localStorage.setItem('accessToken', data.accessToken);
    localStorage.setItem('refreshToken', data.refreshToken);
    return data;
  }

  async register(userData: any) {
    const { data } = await this.client.post('/auth/register', userData);
    return data;
  }

  async getUserInfo() {
    const { data } = await this.client.get('/auth/user-info');
    return data;
  }

  // Users
  async getUser(id: number) {
    const { data } = await this.client.get(`/users/${id}`);
    return data;
  }

  async getUsers(page = 0, size = 20) {
    const { data } = await this.client.get('/users', { params: { page, size } });
    return data;
  }

  async updateUser(id: number, userData: any) {
    const { data } = await this.client.put(`/users/${id}`, userData);
    return data;
  }

  // Questions
  async getQuestions(page = 0, size = 20) {
    const { data } = await this.client.get('/questions', { params: { page, size } });
    return data;
  }

  async createQuestion(questionData: any) {
    const { data } = await this.client.post('/questions', questionData);
    return data;
  }

  // Exams
  async getExams(page = 0, size = 20) {
    const { data } = await this.client.get('/exams', { params: { page, size } });
    return data;
  }

  async createExam(examData: any) {
    const { data } = await this.client.post('/exams', examData);
    return data;
  }

  // News
  async getNews(page = 0, size = 20) {
    const { data } = await this.client.get('/news', { params: { page, size } });
    return data;
  }

  async createNews(newsData: any) {
    const { data } = await this.client.post('/news', newsData);
    return data;
  }
}

export const apiClient = new APIClient();
```

---

**Document End**
