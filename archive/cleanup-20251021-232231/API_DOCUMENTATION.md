# 📚 API Documentation - Interview Microservice System

## 🚀 Quick Start

### Base URLs
- **Gateway (Main)**: `http://localhost:8080`
- **Auth Service**: `http://localhost:8081`
- **User Service**: `http://localhost:8082`
- **Question Service**: `http://localhost:8085`
- **Exam Service**: `http://localhost:8083`
- **Career Service**: `http://localhost:8084`
- **News Service**: `http://localhost:8086`

### Authentication
All protected endpoints require JWT token in Authorization header:
```
Authorization: Bearer <your-jwt-token>
```

## 🔐 Authentication Flow

### 1. Register User
```http
POST /auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "123456",
  "roleName": "USER",
  "fullName": "John Doe",
  "dateOfBirth": "1990-01-01",
  "address": "123 Main St",
  "isStudying": true
}
```

**Response:**
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiJ9...",
  "tokenType": "Bearer",
  "refreshToken": "eyJhbGciOiJIUzI1NiJ9...",
  "expiresIn": 3600,
  "verifyToken": "uuid-verification-token"
}
```

### 2. Login
```http
POST /auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "123456"
}
```

### 3. Get User Info
```http
GET /auth/user-info
Authorization: Bearer <token>
```

## 📝 Question Management APIs

### Create Field
```http
POST /questions/fields
Authorization: Bearer <admin-token>
Content-Type: application/json

{
  "name": "Programming",
  "description": "Programming languages and concepts"
}
```

### Create Topic
```http
POST /questions/topics
Authorization: Bearer <admin-token>
Content-Type: application/json

{
  "fieldId": 1,
  "name": "Java",
  "description": "Java programming language"
}
```

### Create Level
```http
POST /questions/levels
Authorization: Bearer <admin-token>
Content-Type: application/json

{
  "name": "Beginner",
  "description": "Beginner level questions",
  "minScore": 0,
  "maxScore": 50
}
```

### Create Question Type
```http
POST /questions/question-types
Authorization: Bearer <admin-token>
Content-Type: application/json

{
  "name": "Multiple Choice",
  "description": "Multiple choice questions"
}
```

### Create Question
```http
POST /questions/questions
Authorization: Bearer <token>
Content-Type: application/json

{
  "userId": 1,
  "topicId": 1,
  "fieldId": 1,
  "levelId": 1,
  "questionTypeId": 1,
  "content": "What is Java programming language?",
  "answer": "Java is a high-level programming language",
  "language": "en"
}
```

**Response:**
```json
{
  "id": 1,
  "userId": 1,
  "topicId": 1,
  "fieldId": 1,
  "levelId": 1,
  "questionTypeId": 1,
  "questionContent": "What is Java programming language?",
  "questionAnswer": "Java is a high-level programming language",
  "similarityScore": null,
  "status": "PENDING",
  "language": "en",
  "createdAt": "2025-10-10T12:02:56.8653",
  "approvedAt": null,
  "approvedBy": null,
  "usefulVote": 0,
  "unusefulVote": 0,
  "fieldName": "Programming",
  "topicName": "Java",
  "levelName": "Beginner",
  "questionTypeName": "Multiple Choice"
}
```

## 👥 User Management APIs

### Get All Users (Admin only)
```http
GET /users?page=0&size=10
Authorization: Bearer <admin-token>
```

### Get User by ID
```http
GET /users/1
Authorization: Bearer <token>
```

### Update User Role (Admin only)
```http
PUT /users/1/role
Authorization: Bearer <admin-token>
Content-Type: application/json

{
  "roleId": 2
}
```

## 📊 Exam Management APIs

### Create Exam
```http
POST /exams
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "Java Basic Exam",
  "description": "Basic Java programming exam",
  "duration": 60,
  "maxScore": 100,
  "questionIds": [1, 2, 3]
}
```

### Get All Exams
```http
GET /exams?page=0&size=10
Authorization: Bearer <token>
```

## 📰 News Management APIs

### Create News
```http
POST /news
Authorization: Bearer <admin-token>
Content-Type: application/json

{
  "title": "New Java Features",
  "content": "Java 17 introduces new features...",
  "author": "John Doe",
  "category": "Technology"
}
```

### Get All News
```http
GET /news?page=0&size=10
Authorization: Bearer <token>
```

## 🎯 Career Management APIs

### Create Career
```http
POST /careers
Authorization: Bearer <admin-token>
Content-Type: application/json

{
  "title": "Java Developer",
  "description": "Senior Java Developer position",
  "requirements": "5+ years experience",
  "salary": "50000-70000",
  "location": "Ho Chi Minh City"
}
```

### Get All Careers
```http
GET /careers?page=0&size=10
Authorization: Bearer <token>
```

## 🔧 Error Handling

All APIs return standardized error responses:

```json
{
  "type": "https://errors.abc.com/RESOURCE_NOT_FOUND",
  "title": "Resource Not Found",
  "status": 404,
  "detail": "User with id 999 not found",
  "instance": "/users/999",
  "errorCode": "RESOURCE_NOT_FOUND",
  "traceId": "uuid-trace-id",
  "timestamp": "2025-10-10T12:00:00Z"
}
```

## 📋 Common HTTP Status Codes

- `200` - OK
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `500` - Internal Server Error

## 🔑 Role-Based Access

- **USER**: Can create questions, take exams, view news/careers
- **RECRUITER**: Can manage careers, view all questions
- **ADMIN**: Full access to all resources

## 📱 Frontend Integration Tips

1. **Store JWT token** in localStorage/sessionStorage
2. **Add token to all requests** in Authorization header
3. **Handle 401 errors** by redirecting to login
4. **Use pagination** for list endpoints (?page=0&size=10)
5. **Implement error handling** for standardized error responses
