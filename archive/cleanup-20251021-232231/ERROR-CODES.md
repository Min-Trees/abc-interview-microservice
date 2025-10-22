# 🚨 ERROR CODES DOCUMENTATION

## Giới thiệu

Hệ thống Interview Microservice ABC sử dụng chuẩn **RFC 7807 Problem Details** cho error responses. Tất cả các lỗi trả về theo format nhất quán với đầy đủ thông tin để debug và trace.

---

## 📋 Error Response Format

### Structure

```json
{
  "type": "https://errors.abc.com/ERROR_CODE",
  "title": "Short human-readable summary",
  "status": 404,
  "detail": "Detailed explanation of the error",
  "instance": "/api/v1/resource/123",
  "errorCode": "ERROR_CODE",
  "traceId": "uuid-for-tracing",
  "timestamp": "2025-10-10T10:25:33.514Z",
  "details": {
    "field1": "error message 1",
    "field2": "error message 2"
  }
}
```

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | string | ✅ | URI của error type (https://errors.abc.com/ERROR_CODE) |
| `title` | string | ✅ | Tóm tắt ngắn gọn, dễ hiểu |
| `status` | int | ✅ | HTTP status code |
| `detail` | string | ✅ | Giải thích chi tiết về lỗi |
| `instance` | string | ✅ | URI của request bị lỗi |
| `errorCode` | string | ✅ | Mã lỗi ứng dụng |
| `traceId` | string | ✅ | UUID để trace trong logs |
| `timestamp` | string | ✅ | ISO 8601 timestamp |
| `details` | object | ❌ | Chi tiết bổ sung (validation errors, etc.) |

---

## 🔐 AUTH SERVICE ERROR CODES

### ROLE_NOT_FOUND (404)

**Khi nào xảy ra:** Register với role không tồn tại

**Request:**
```json
POST /auth/register
{
  "email": "user@example.com",
  "password": "123456",
  "roleId": 999
}
```

**Response:**
```json
{
  "type": "https://errors.abc.com/ROLE_NOT_FOUND",
  "title": "Role Not Found",
  "status": 404,
  "detail": "Role '999' not found",
  "instance": "/auth/register",
  "errorCode": "ROLE_NOT_FOUND",
  "traceId": "d6b87c15-5bc5-43f0-bb57-da7b29e85e12",
  "timestamp": "2025-10-10T10:25:33.514Z"
}
```

---

### INVALID_CREDENTIALS (401)

**Khi nào xảy ra:** Login với email/password sai

**Request:**
```json
POST /auth/login
{
  "email": "user@example.com",
  "password": "wrongpassword"
}
```

**Response:**
```json
{
  "type": "https://errors.abc.com/INVALID_CREDENTIALS",
  "title": "Authentication Failed",
  "status": 401,
  "detail": "Invalid email or password",
  "instance": "/auth/login",
  "errorCode": "INVALID_CREDENTIALS",
  "traceId": "a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c5d",
  "timestamp": "2025-10-10T10:26:15.123Z"
}
```

---

### TOKEN_EXPIRED (401)

**Khi nào xảy ra:** Sử dụng expired JWT token

**Response:**
```json
{
  "type": "https://errors.abc.com/TOKEN_EXPIRED",
  "title": "Token Expired",
  "status": 401,
  "detail": "Token has expired. Please login again.",
  "instance": "/auth/verify",
  "errorCode": "TOKEN_EXPIRED",
  "traceId": "f1e2d3c4-b5a6-47b8-9c0d-1e2f3a4b5c6d",
  "timestamp": "2025-10-10T10:27:00.456Z"
}
```

---

### DUPLICATE_RESOURCE (409)

**Khi nào xảy ra:** Register với email đã tồn tại

**Request:**
```json
POST /auth/register
{
  "roleId": 1,
  "email": "user@example.com",
  "password": "password123",
  "fullName": "Test User"
}
```

**Response:**
```json
{
  "type": "https://errors.abc.com/DUPLICATE_RESOURCE",
  "title": "Duplicate Resource",
  "status": 409,
  "detail": "Email 'user@example.com' already exists",
  "instance": "/auth/register",
  "errorCode": "DUPLICATE_RESOURCE",
  "traceId": "c1d2e3f4-a5b6-47c8-9d0e-1f2a3b4c5d6e",
  "timestamp": "2025-10-10T10:28:30.789Z"
}
```

---

## 👤 USER SERVICE ERROR CODES

### USER_NOT_FOUND (404)

**Khi nào xảy ra:** Truy cập user không tồn tại

**Request:**
```http
GET /users/999
```

**Response:**
```json
{
  "type": "https://errors.abc.com/USER_NOT_FOUND",
  "title": "Resource Not Found",
  "status": 404,
  "detail": "User not found with id: '999'",
  "instance": "/users/999",
  "errorCode": "USER_NOT_FOUND",
  "traceId": "b2c3d4e5-f6a7-48b9-0c1d-2e3f4a5b6c7d",
  "timestamp": "2025-10-10T10:29:00.123Z"
}
```

---

### USER_ALREADY_EXISTS (409)

**Khi nào xảy ra:** Update user với email đã tồn tại

**Response:**
```json
{
  "type": "https://errors.abc.com/USER_ALREADY_EXISTS",
  "title": "Duplicate Resource",
  "status": 409,
  "detail": "User already exists with email: 'existing@example.com'",
  "instance": "/users/3",
  "errorCode": "USER_ALREADY_EXISTS",
  "traceId": "d3e4f5a6-b7c8-49d0-1e2f-3a4b5c6d7e8f",
  "timestamp": "2025-10-10T10:30:15.456Z"
}
```

---

### ACCESS_DENIED (403)

**Khi nào xảy ra:** User không có quyền truy cập

**Request:**
```http
PUT /users/3/role
Authorization: Bearer <user_token>
{
  "roleId": 3
}
```

**Response:**
```json
{
  "type": "https://errors.abc.com/ACCESS_DENIED",
  "title": "Access Denied",
  "status": 403,
  "detail": "You don't have permission to access this resource",
  "instance": "/users/3/role",
  "errorCode": "ACCESS_DENIED",
  "traceId": "e4f5a6b7-c8d9-40e1-2f3a-4b5c6d7e8f9a",
  "timestamp": "2025-10-10T10:31:45.789Z"
}
```

---

### INVALID_ARGUMENT (400)

**Khi nào xảy ra:** ELO action không hợp lệ

**Request:**
```json
POST /users/elo
{
  "userId": 3,
  "action": "INVALID_ACTION",
  "points": 50
}
```

**Response:**
```json
{
  "type": "https://errors.abc.com/INVALID_ARGUMENT",
  "title": "Invalid Argument",
  "status": 400,
  "detail": "Invalid ELO action: INVALID_ACTION. Must be: WIN, LOSE, or MANUAL",
  "instance": "/users/elo",
  "errorCode": "INVALID_ARGUMENT",
  "traceId": "f5a6b7c8-d9e0-41f2-3a4b-5c6d7e8f9a0b",
  "timestamp": "2025-10-10T10:32:30.123Z"
}
```

---

## ❓ QUESTION SERVICE ERROR CODES

### QUESTION_NOT_FOUND (404)

**Khi nào xảy ra:** Truy cập question không tồn tại

**Response:**
```json
{
  "type": "https://errors.abc.com/QUESTION_NOT_FOUND",
  "title": "Resource Not Found",
  "status": 404,
  "detail": "Question not found with id: '999'",
  "instance": "/questions/999",
  "errorCode": "QUESTION_NOT_FOUND",
  "traceId": "a6b7c8d9-e0f1-42a3-4b5c-6d7e8f9a0b1c",
  "timestamp": "2025-10-10T10:33:00.456Z"
}
```

---

### FIELD_NOT_FOUND (404)

**Response:**
```json
{
  "type": "https://errors.abc.com/FIELD_NOT_FOUND",
  "title": "Resource Not Found",
  "status": 404,
  "detail": "Field not found with id: '10'",
  "instance": "/fields/10",
  "errorCode": "FIELD_NOT_FOUND",
  "traceId": "b7c8d9e0-f1a2-43b4-5c6d-7e8f9a0b1c2d",
  "timestamp": "2025-10-10T10:34:15.789Z"
}
```

---

### TOPIC_NOT_FOUND (404)

**Response:**
```json
{
  "type": "https://errors.abc.com/TOPIC_NOT_FOUND",
  "title": "Resource Not Found",
  "status": 404,
  "detail": "Topic not found with id: '50'",
  "instance": "/topics/50",
  "errorCode": "TOPIC_NOT_FOUND",
  "traceId": "c8d9e0f1-a2b3-44c5-6d7e-8f9a0b1c2d3e",
  "timestamp": "2025-10-10T10:35:30.123Z"
}
```

---

## 📝 EXAM SERVICE ERROR CODES

### EXAM_NOT_FOUND (404)

**Response:**
```json
{
  "type": "https://errors.abc.com/EXAM_NOT_FOUND",
  "title": "Resource Not Found",
  "status": 404,
  "detail": "Exam not found with id: '100'",
  "instance": "/exams/100",
  "errorCode": "EXAM_NOT_FOUND",
  "traceId": "d9e0f1a2-b3c4-45d6-7e8f-9a0b1c2d3e4f",
  "timestamp": "2025-10-10T10:36:00.456Z"
}
```

---

### EXAM_ALREADY_COMPLETED (409)

**Response:**
```json
{
  "type": "https://errors.abc.com/EXAM_ALREADY_COMPLETED",
  "title": "Illegal State",
  "status": 409,
  "detail": "Cannot modify exam. Exam has already been completed.",
  "instance": "/exams/1/start",
  "errorCode": "EXAM_ALREADY_COMPLETED",
  "traceId": "e0f1a2b3-c4d5-46e7-8f9a-0b1c2d3e4f5a",
  "timestamp": "2025-10-10T10:37:15.789Z"
}
```

---

### REGISTRATION_EXISTS (409)

**Response:**
```json
{
  "type": "https://errors.abc.com/REGISTRATION_EXISTS",
  "title": "Duplicate Resource",
  "status": 409,
  "detail": "User is already registered for this exam",
  "instance": "/exams/registrations",
  "errorCode": "REGISTRATION_EXISTS",
  "traceId": "f1a2b3c4-d5e6-47f8-9a0b-1c2d3e4f5a6b",
  "timestamp": "2025-10-10T10:38:30.123Z"
}
```

---

## 📰 NEWS SERVICE ERROR CODES

### NEWS_NOT_FOUND (404)

**Response:**
```json
{
  "type": "https://errors.abc.com/NEWS_NOT_FOUND",
  "title": "Resource Not Found",
  "status": 404,
  "detail": "News not found with id: '200'",
  "instance": "/news/200",
  "errorCode": "NEWS_NOT_FOUND",
  "traceId": "a2b3c4d5-e6f7-48a9-0b1c-2d3e4f5a6b7c",
  "timestamp": "2025-10-10T10:39:00.456Z"
}
```

---

### NEWS_NOT_APPROVED (403)

**Response:**
```json
{
  "type": "https://errors.abc.com/NEWS_NOT_APPROVED",
  "title": "Access Denied",
  "status": 403,
  "detail": "Cannot publish news. News has not been approved yet.",
  "instance": "/news/5/publish",
  "errorCode": "NEWS_NOT_APPROVED",
  "traceId": "b3c4d5e6-f7a8-49b0-1c2d-3e4f5a6b7c8d",
  "timestamp": "2025-10-10T10:40:15.789Z"
}
```

---

## 💼 CAREER SERVICE ERROR CODES

### CAREER_PREFERENCE_NOT_FOUND (404)

**Response:**
```json
{
  "type": "https://errors.abc.com/CAREER_PREFERENCE_NOT_FOUND",
  "title": "Resource Not Found",
  "status": 404,
  "detail": "Career preference not found with id: '50'",
  "instance": "/career/50",
  "errorCode": "CAREER_PREFERENCE_NOT_FOUND",
  "traceId": "c4d5e6f7-a8b9-40c1-2d3e-4f5a6b7c8d9e",
  "timestamp": "2025-10-10T10:41:30.123Z"
}
```

---

## ✅ VALIDATION ERROR CODES

### VALIDATION_FAILED (400)

**Khi nào xảy ra:** Input validation thất bại

**Request:**
```json
POST /users/elo
{
  "action": "WIN",
  "points": 50
}
```

**Response:**
```json
{
  "type": "https://errors.abc.com/VALIDATION_FAILED",
  "title": "Validation Failed",
  "status": 400,
  "detail": "Input validation failed. Please check the provided fields.",
  "instance": "/users/elo",
  "errorCode": "VALIDATION_FAILED",
  "traceId": "d5e6f7a8-b9c0-41d2-3e4f-5a6b7c8d9e0f",
  "timestamp": "2025-10-10T10:42:00.456Z",
  "details": {
    "userId": "must not be null",
    "description": "must not be blank"
  }
}
```

---

## 🌐 COMMON ERROR CODES

### INTERNAL_SERVER_ERROR (500)

**Khi nào xảy ra:** Lỗi không xác định từ server

**Response:**
```json
{
  "type": "https://errors.abc.com/INTERNAL_SERVER_ERROR",
  "title": "Internal Server Error",
  "status": 500,
  "detail": "An unexpected error occurred. Please contact support if the problem persists.",
  "instance": "/users/3",
  "errorCode": "INTERNAL_SERVER_ERROR",
  "traceId": "e6f7a8b9-c0d1-42e3-4f5a-6b7c8d9e0f1a",
  "timestamp": "2025-10-10T10:43:15.789Z"
}
```

---

### INVALID_REQUEST (400)

**Khi nào xảy ra:** Request không hợp lệ

**Response:**
```json
{
  "type": "https://errors.abc.com/INVALID_REQUEST",
  "title": "Invalid Request",
  "status": 400,
  "detail": "Request body is malformed or missing required fields",
  "instance": "/users",
  "errorCode": "INVALID_REQUEST",
  "traceId": "f7a8b9c0-d1e2-43f4-5a6b-7c8d9e0f1a2b",
  "timestamp": "2025-10-10T10:44:30.123Z"
}
```

---

## 📊 ERROR CODE SUMMARY

### By HTTP Status

| Status | Error Code | Service | Description |
|--------|-----------|---------|-------------|
| **400** | VALIDATION_FAILED | All | Input validation failed |
| **400** | INVALID_REQUEST | All | Invalid request format |
| **400** | INVALID_ARGUMENT | All | Invalid argument value |
| **401** | INVALID_CREDENTIALS | Auth | Wrong email/password |
| **401** | TOKEN_EXPIRED | Auth | JWT token expired |
| **403** | ACCESS_DENIED | All | Insufficient permissions |
| **403** | NEWS_NOT_APPROVED | News | News not approved yet |
| **404** | ROLE_NOT_FOUND | Auth | Role doesn't exist |
| **404** | USER_NOT_FOUND | User | User doesn't exist |
| **404** | QUESTION_NOT_FOUND | Question | Question doesn't exist |
| **404** | FIELD_NOT_FOUND | Question | Field doesn't exist |
| **404** | TOPIC_NOT_FOUND | Question | Topic doesn't exist |
| **404** | EXAM_NOT_FOUND | Exam | Exam doesn't exist |
| **404** | NEWS_NOT_FOUND | News | News doesn't exist |
| **404** | CAREER_PREFERENCE_NOT_FOUND | Career | Career preference doesn't exist |
| **409** | DUPLICATE_RESOURCE | Auth | Email already exists |
| **409** | USER_ALREADY_EXISTS | User | User already exists |
| **409** | REGISTRATION_EXISTS | Exam | Already registered |
| **409** | EXAM_ALREADY_COMPLETED | Exam | Exam already completed |
| **409** | ILLEGAL_STATE | All | Invalid state transition |
| **500** | INTERNAL_SERVER_ERROR | All | Unexpected server error |

---

## 🛠️ USING ERROR CODES

### In Frontend

```javascript
// Handle errors by error code
async function registerUser(data) {
  try {
    const response = await fetch('/auth/register', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });
    
    if (!response.ok) {
      const error = await response.json();
      
      switch (error.errorCode) {
        case 'ROLE_NOT_FOUND':
          alert('Role không tồn tại. Vui lòng chọn role khác.');
          break;
        case 'DUPLICATE_RESOURCE':
          alert('Email đã được sử dụng.');
          break;
        case 'VALIDATION_FAILED':
          displayValidationErrors(error.details);
          break;
        default:
          alert(`Error: ${error.detail}`);
      }
      
      // Log trace ID for support
      console.error('Trace ID:', error.traceId);
    }
  } catch (err) {
    console.error('Network error:', err);
  }
}
```

### In Logging

```java
// Log with trace ID for debugging
log.error("Error processing request. TraceId: {}, ErrorCode: {}, Detail: {}", 
    error.getTraceId(), 
    error.getErrorCode(), 
    error.getDetail());
```

---

## 📞 SUPPORT

Khi báo lỗi cho support team, hãy cung cấp:

1. **traceId** - UUID để trace trong logs
2. **timestamp** - Thời điểm xảy ra lỗi
3. **instance** - URI của request
4. **errorCode** - Mã lỗi
5. **detail** - Chi tiết lỗi

**Example:**
```
TraceId: d6b87c15-5bc5-43f0-bb57-da7b29e85e12
Timestamp: 2025-10-10T10:25:33.514Z
Instance: /auth/register
ErrorCode: ROLE_NOT_FOUND
Detail: Role 'ADMINXX' not found
```

---

**Created:** 2025-10-10  
**Version:** 1.0  
**Standard:** RFC 7807 Problem Details



