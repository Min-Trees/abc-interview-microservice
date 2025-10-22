# ABC Interview Platform - Complete API Documentation

## Table of Contents
1. [Overview](#overview)
2. [Authentication](#authentication)
3. [Environment Setup](#environment-setup)
4. [Services](#services)
5. [Testing Guide](#testing-guide)

---

## Overview

This document provides comprehensive API documentation for all microservices in the ABC Interview Platform. The system uses a microservices architecture with the following services:

- **API Gateway**: `http://localhost:8080` - Entry point for all requests
- **Auth Service**: `http://localhost:8081` - Authentication & JWT token management
- **User Service**: `http://localhost:8082` - User profile management
- **Question Service**: `http://localhost:8085` - Question bank management
- **Exam Service**: `http://localhost:8086` - Exam lifecycle management
- **Career Service**: `http://localhost:8087` - Career path management
- **News Service**: `http://localhost:8088` - News & articles management
- **NLP Service**: `http://localhost:5000` - Natural Language Processing (Python FastAPI)

---

## Authentication

### JWT Token Authentication

All authenticated endpoints require a Bearer token in the Authorization header:

```
Authorization: Bearer <access_token>
```

### Authentication Flow

1. **Register** - Create new account
   ```
   POST /auth/register
   Body: {
     "email": "user@example.com",
     "password": "password123",
     "fullName": "John Doe",
     "role": "USER"
   }
   ```

2. **Login** - Get access token
   ```
   POST /auth/login
   Body: {
     "email": "user@example.com",
     "password": "password123"
   }
   Response: {
     "accessToken": "eyJhbGc...",
     "refreshToken": "eyJhbGc...",
     "userId": 1
   }
   ```

3. **Refresh Token** - Get new access token
   ```
   POST /auth/refresh
   Body: {
     "refreshToken": "eyJhbGc..."
   }
   ```

4. **Validate Token** - Check token validity
   ```
   GET /auth/validate?token=eyJhbGc...
   ```

---

## Environment Setup

### Postman Environment Variables

Import `ABC-Interview-Environment.postman_environment.json` with these variables:

| Variable | Description | Example |
|----------|-------------|---------|
| `base_url` | API Gateway URL | `http://localhost:8080` |
| `access_token` | JWT access token | Auto-populated from login |
| `refresh_token` | JWT refresh token | Auto-populated from login |
| `user_id` | Current user ID | Auto-populated from login |
| `auth_service_url` | Auth service direct URL | `http://localhost:8081` |
| `user_service_url` | User service direct URL | `http://localhost:8082` |
| `question_service_url` | Question service direct URL | `http://localhost:8085` |
| `exam_service_url` | Exam service direct URL | `http://localhost:8086` |
| `career_service_url` | Career service direct URL | `http://localhost:8087` |
| `news_service_url` | News service direct URL | `http://localhost:8088` |
| `nlp_service_url` | NLP service direct URL | `http://localhost:5000` |

### Auto-Save Token Script

Add this script to Login request's **Tests** tab (already included in Postman collection):

```javascript
if (pm.response.code === 200) {
    var jsonData = pm.response.json();
    pm.environment.set("access_token", jsonData.accessToken);
    pm.environment.set("refresh_token", jsonData.refreshToken);
    pm.environment.set("user_id", jsonData.userId);
}
```

---

## Services

### 1. Auth Service

**Base Path**: `/auth`

#### Endpoints

| Method | Endpoint | Auth Required | Description |
|--------|----------|---------------|-------------|
| POST | `/auth/register` | No | Register new user |
| POST | `/auth/login` | No | Login and get JWT token |
| POST | `/auth/refresh` | No | Refresh access token |
| GET | `/auth/validate` | No | Validate token |

#### Request/Response Examples

**Register**
```json
POST /auth/register
{
  "email": "newuser@example.com",
  "password": "SecurePass123!",
  "fullName": "New User",
  "role": "USER"
}

Response 201:
{
  "id": 5,
  "email": "newuser@example.com",
  "fullName": "New User",
  "role": "USER",
  "createdAt": "2024-01-15T10:30:00"
}
```

**Login**
```json
POST /auth/login
{
  "email": "admin@example.com",
  "password": "admin123"
}

Response 200:
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "userId": 1,
  "email": "admin@example.com",
  "role": "ADMIN"
}
```

---

### 2. User Service

**Base Path**: `/users`

#### Endpoints

| Method | Endpoint | Auth Required | Roles | Description |
|--------|----------|---------------|-------|-------------|
| GET | `/users` | Yes | ADMIN | Get all users (paginated) |
| GET | `/users/{id}` | Yes | USER, ADMIN | Get user by ID |
| GET | `/users/me` | Yes | USER | Get current user profile |
| PUT | `/users/{id}` | Yes | USER, ADMIN | Update user |
| DELETE | `/users/{id}` | Yes | ADMIN | Delete user |
| GET | `/users/search?email=` | Yes | ADMIN | Search users by email |

#### Request/Response Examples

**Get All Users**
```
GET /users?page=0&size=10&sort=id,desc
Authorization: Bearer {{access_token}}

Response 200:
{
  "content": [
    {
      "id": 1,
      "email": "admin@example.com",
      "fullName": "Admin User",
      "role": "ADMIN",
      "active": true,
      "createdAt": "2024-01-01T00:00:00"
    }
  ],
  "totalElements": 50,
  "totalPages": 5,
  "size": 10,
  "number": 0
}
```

**Update User**
```json
PUT /users/5
Authorization: Bearer {{access_token}}
{
  "email": "updated@example.com",
  "fullName": "Updated Name",
  "role": "USER"
}

Response 200:
{
  "id": 5,
  "email": "updated@example.com",
  "fullName": "Updated Name",
  "role": "USER",
  "active": true
}
```

---

### 3. Question Service

**Base Path**: `/questions`

#### Endpoints

##### Fields

| Method | Endpoint | Auth Required | Roles | Description |
|--------|----------|---------------|-------|-------------|
| GET | `/questions/fields` | No | - | Get all fields |
| GET | `/questions/fields/{id}` | No | - | Get field by ID |
| POST | `/questions/fields` | Yes | ADMIN | Create field |
| PUT | `/questions/fields/{id}` | Yes | ADMIN | Update field |
| DELETE | `/questions/fields/{id}` | Yes | ADMIN | Delete field |

##### Topics

| Method | Endpoint | Auth Required | Roles | Description |
|--------|----------|---------------|-------|-------------|
| GET | `/questions/topics` | No | - | Get all topics (with fieldName) |
| GET | `/questions/topics/{id}` | No | - | Get topic by ID |
| POST | `/questions/topics` | Yes | ADMIN | Create topic |
| PUT | `/questions/topics/{id}` | Yes | ADMIN | Update topic |
| DELETE | `/questions/topics/{id}` | Yes | ADMIN | Delete topic |

##### Levels

| Method | Endpoint | Auth Required | Roles | Description |
|--------|----------|---------------|-------|-------------|
| GET | `/questions/levels` | No | - | Get all difficulty levels |
| GET | `/questions/levels/{id}` | No | - | Get level by ID |
| POST | `/questions/levels` | Yes | ADMIN | Create level |
| PUT | `/questions/levels/{id}` | Yes | ADMIN | Update level |
| DELETE | `/questions/levels/{id}` | Yes | ADMIN | Delete level |

##### Question Types

| Method | Endpoint | Auth Required | Roles | Description |
|--------|----------|---------------|-------|-------------|
| GET | `/questions/question-types` | No | - | Get all question types |
| GET | `/questions/question-types/{id}` | No | - | Get type by ID |
| POST | `/questions/question-types` | Yes | ADMIN | Create question type |
| PUT | `/questions/question-types/{id}` | Yes | ADMIN | Update question type |
| DELETE | `/questions/question-types/{id}` | Yes | ADMIN | Delete question type |

##### Questions

| Method | Endpoint | Auth Required | Roles | Description |
|--------|----------|---------------|-------|-------------|
| GET | `/questions` | No | - | Get all questions (paginated, with relationships) |
| GET | `/questions/{id}` | No | - | Get question by ID |
| POST | `/questions` | Yes | ADMIN | Create question |
| PUT | `/questions/{id}` | Yes | ADMIN | Update question |
| DELETE | `/questions/{id}` | Yes | ADMIN | Delete question |

##### Answers

| Method | Endpoint | Auth Required | Roles | Description |
|--------|----------|---------------|-------|-------------|
| GET | `/questions/{questionId}/answers` | No | - | Get answers for a question |
| POST | `/questions/{questionId}/answers` | Yes | ADMIN | Create answer |
| PUT | `/questions/{questionId}/answers/{answerId}` | Yes | ADMIN | Update answer |
| DELETE | `/questions/{questionId}/answers/{answerId}` | Yes | ADMIN | Delete answer |

#### Request/Response Examples

**Create Field**
```json
POST /questions/fields
Authorization: Bearer {{access_token}}
{
  "name": "Java Programming",
  "description": "Questions about Java language and ecosystem"
}

Response 201:
{
  "id": 1,
  "name": "Java Programming",
  "description": "Questions about Java language and ecosystem"
}
```

**Create Topic**
```json
POST /questions/topics
Authorization: Bearer {{access_token}}
{
  "name": "Spring Boot",
  "fieldId": 1,
  "description": "Spring Boot framework questions"
}

Response 201:
{
  "id": 1,
  "name": "Spring Boot",
  "fieldId": 1,
  "fieldName": "Java Programming",
  "description": "Spring Boot framework questions"
}
```

**Get All Questions**
```
GET /questions?page=0&size=10
Authorization: Bearer {{access_token}}

Response 200:
{
  "content": [
    {
      "id": 1,
      "content": "What is dependency injection?",
      "fieldId": 1,
      "fieldName": "Java Programming",
      "topicId": 1,
      "topicName": "Spring Boot",
      "levelId": 1,
      "levelName": "Medium",
      "questionTypeId": 1,
      "questionTypeName": "Multiple Choice",
      "explanation": "Dependency injection is...",
      "createdAt": "2024-01-15T10:00:00"
    }
  ],
  "totalElements": 100,
  "totalPages": 10,
  "size": 10,
  "number": 0
}
```

**Create Question**
```json
POST /questions
Authorization: Bearer {{access_token}}
{
  "content": "What is the default scope of Spring beans?",
  "fieldId": 1,
  "topicId": 1,
  "levelId": 2,
  "questionTypeId": 1,
  "explanation": "The default scope is Singleton"
}

Response 201:
{
  "id": 101,
  "content": "What is the default scope of Spring beans?",
  "fieldId": 1,
  "fieldName": "Java Programming",
  "topicId": 1,
  "topicName": "Spring Boot",
  "levelId": 2,
  "levelName": "Easy",
  "questionTypeId": 1,
  "questionTypeName": "Multiple Choice",
  "explanation": "The default scope is Singleton",
  "createdAt": "2024-01-15T15:30:00"
}
```

**Create Answer**
```json
POST /questions/101/answers
Authorization: Bearer {{access_token}}
{
  "content": "Singleton",
  "isCorrect": true,
  "explanation": "Spring beans are singleton by default"
}

Response 201:
{
  "id": 1,
  "questionId": 101,
  "content": "Singleton",
  "isCorrect": true,
  "explanation": "Spring beans are singleton by default"
}
```

---

### 4. Exam Service

**Base Path**: `/exams`

#### Endpoints

| Method | Endpoint | Auth Required | Roles | Description |
|--------|----------|---------------|-------|-------------|
| GET | `/exams` | Yes | USER | Get all exams |
| GET | `/exams/{id}` | Yes | USER | Get exam by ID |
| POST | `/exams` | Yes | ADMIN | Create exam |
| PUT | `/exams/{id}` | Yes | ADMIN | Update exam |
| DELETE | `/exams/{id}` | Yes | ADMIN | Delete exam |
| POST | `/exams/{id}/start` | Yes | USER | Start exam session |
| POST | `/exams/{id}/submit` | Yes | USER | Submit exam answers |
| GET | `/exams/{id}/results` | Yes | USER | Get exam results |

#### Request/Response Examples

**Create Exam**
```json
POST /exams
Authorization: Bearer {{access_token}}
{
  "title": "Spring Boot Advanced Test",
  "description": "Advanced level Spring Boot knowledge test",
  "duration": 60,
  "totalQuestions": 20,
  "passingScore": 70,
  "fieldId": 1,
  "levelId": 3
}

Response 201:
{
  "id": 1,
  "title": "Spring Boot Advanced Test",
  "description": "Advanced level Spring Boot knowledge test",
  "duration": 60,
  "totalQuestions": 20,
  "passingScore": 70,
  "fieldId": 1,
  "levelId": 3,
  "active": true,
  "createdAt": "2024-01-15T10:00:00"
}
```

**Start Exam**
```json
POST /exams/1/start
Authorization: Bearer {{access_token}}

Response 200:
{
  "sessionId": 123,
  "examId": 1,
  "userId": 5,
  "startTime": "2024-01-15T15:00:00",
  "endTime": "2024-01-15T16:00:00",
  "questions": [
    {
      "id": 1,
      "content": "What is dependency injection?",
      "answers": [
        {"id": 1, "content": "Design pattern"},
        {"id": 2, "content": "Framework"}
      ]
    }
  ]
}
```

**Submit Exam**
```json
POST /exams/1/submit
Authorization: Bearer {{access_token}}
{
  "sessionId": 123,
  "answers": [
    {"questionId": 1, "answerId": 1},
    {"questionId": 2, "answerId": 5}
  ]
}

Response 200:
{
  "sessionId": 123,
  "score": 85,
  "totalQuestions": 20,
  "correctAnswers": 17,
  "passed": true,
  "submittedAt": "2024-01-15T15:45:00"
}
```

---

### 5. Career Service

**Base Path**: `/careers`

#### Endpoints

| Method | Endpoint | Auth Required | Roles | Description |
|--------|----------|---------------|-------|-------------|
| GET | `/careers` | No | - | Get all career paths |
| GET | `/careers/{id}` | No | - | Get career by ID |
| POST | `/careers` | Yes | ADMIN | Create career path |
| PUT | `/careers/{id}` | Yes | ADMIN | Update career path |
| DELETE | `/careers/{id}` | Yes | ADMIN | Delete career path |
| GET | `/careers/search?keyword=` | No | - | Search careers |

#### Request/Response Examples

**Create Career Path**
```json
POST /careers
Authorization: Bearer {{access_token}}
{
  "title": "Full Stack Developer",
  "description": "Complete roadmap to become a full stack developer",
  "requirements": ["Java", "Spring Boot", "React", "PostgreSQL"],
  "salary": "50000-80000 USD",
  "level": "Junior to Mid-level"
}

Response 201:
{
  "id": 1,
  "title": "Full Stack Developer",
  "description": "Complete roadmap to become a full stack developer",
  "requirements": ["Java", "Spring Boot", "React", "PostgreSQL"],
  "salary": "50000-80000 USD",
  "level": "Junior to Mid-level",
  "createdAt": "2024-01-15T10:00:00"
}
```

---

### 6. News Service

**Base Path**: `/news`

#### Endpoints

| Method | Endpoint | Auth Required | Roles | Description |
|--------|----------|---------------|-------|-------------|
| GET | `/news` | No | - | Get all news articles |
| GET | `/news/{id}` | No | - | Get news by ID |
| POST | `/news` | Yes | ADMIN | Create news article |
| PUT | `/news/{id}` | Yes | ADMIN | Update news article |
| DELETE | `/news/{id}` | Yes | ADMIN | Delete news article |
| GET | `/news/category/{category}` | No | - | Get news by category |

#### Request/Response Examples

**Create News Article**
```json
POST /news
Authorization: Bearer {{access_token}}
{
  "title": "Spring Boot 3.2 Released",
  "content": "Spring Boot 3.2 brings exciting new features...",
  "category": "Technology",
  "author": "John Doe",
  "tags": ["Spring Boot", "Java", "Framework"]
}

Response 201:
{
  "id": 1,
  "title": "Spring Boot 3.2 Released",
  "content": "Spring Boot 3.2 brings exciting new features...",
  "category": "Technology",
  "author": "John Doe",
  "tags": ["Spring Boot", "Java", "Framework"],
  "publishedAt": "2024-01-15T10:00:00"
}
```

---

### 7. NLP Service (Python FastAPI)

**Base Path**: `/nlp`

#### Endpoints

| Method | Endpoint | Auth Required | Description |
|--------|----------|---------------|-------------|
| POST | `/nlp/similarity` | No | Calculate text similarity |
| POST | `/nlp/keywords` | No | Extract keywords from text |
| POST | `/nlp/sentiment` | No | Analyze text sentiment |

#### Request/Response Examples

**Text Similarity**
```json
POST /nlp/similarity
{
  "text1": "What is dependency injection in Spring?",
  "text2": "Explain dependency injection pattern in Spring Framework"
}

Response 200:
{
  "similarity": 0.87,
  "method": "cosine",
  "confidence": 0.92
}
```

**Extract Keywords**
```json
POST /nlp/keywords
{
  "text": "Spring Boot is a powerful framework for building Java applications with minimal configuration",
  "topN": 5
}

Response 200:
{
  "keywords": [
    {"word": "Spring Boot", "score": 0.95},
    {"word": "framework", "score": 0.88},
    {"word": "Java applications", "score": 0.82},
    {"word": "configuration", "score": 0.75},
    {"word": "building", "score": 0.68}
  ]
}
```

**Sentiment Analysis**
```json
POST /nlp/sentiment
{
  "text": "This is an excellent platform for interview preparation!"
}

Response 200:
{
  "sentiment": "positive",
  "score": 0.92,
  "confidence": 0.88
}
```

---

## Testing Guide

### Step 1: Import Postman Collection

1. Open Postman
2. Click **Import** button
3. Import these files:
   - `Complete-API-Collection-V2.postman_collection.json`
   - `ABC-Interview-Environment.postman_environment.json`
4. Select **ABC Interview Platform - Development** environment

### Step 2: Authentication Flow

1. **Register** a new user (optional):
   ```
   POST /auth/register
   ```

2. **Login** to get access token:
   ```
   POST /auth/login
   ```
   The `access_token`, `refresh_token`, and `user_id` will be automatically saved to environment variables.

3. **Verify** token is saved:
   - Check environment variables (eye icon in top right)
   - `access_token` should have a JWT value

### Step 3: Test Endpoints

All authenticated endpoints will automatically use the saved `access_token`.

**Test Sequence:**

1. **Auth Service**: Login → Validate → Refresh
2. **User Service**: Get current user → Get all users (if ADMIN)
3. **Question Service**:
   - Get fields → Create field (ADMIN)
   - Get topics → Create topic (ADMIN)
   - Get questions → Create question (ADMIN)
   - Get answers → Create answer (ADMIN)
4. **Exam Service**: Create exam → Start exam → Submit exam → Get results
5. **Career Service**: Get careers → Create career (ADMIN)
6. **News Service**: Get news → Create article (ADMIN)
7. **NLP Service**: Test similarity, keywords, sentiment

### Step 4: Common Issues & Solutions

**Issue**: 401 Unauthorized
- **Solution**: Run login request again to refresh token

**Issue**: 403 Forbidden
- **Solution**: Check if user has required role (ADMIN for POST/PUT/DELETE)

**Issue**: 404 Not Found
- **Solution**: Verify service is running and endpoint path is correct

**Issue**: 500 Internal Server Error
- **Solution**: Check service logs: `docker logs interview-<service-name>`

### Step 5: Swagger UI

Access Swagger documentation for each service:

- **Auth Service**: `http://localhost:8081/swagger-ui.html`
- **User Service**: `http://localhost:8082/swagger-ui.html`
- **Question Service**: `http://localhost:8085/swagger-ui.html`
- **Exam Service**: `http://localhost:8086/swagger-ui.html`
- **Career Service**: `http://localhost:8087/swagger-ui.html`
- **News Service**: `http://localhost:8088/swagger-ui.html`
- **NLP Service**: `http://localhost:5000/docs` (FastAPI auto-docs)

### Step 6: Direct Service Testing

You can also test services directly (bypass gateway):

```bash
# Auth Service
curl http://localhost:8081/auth/login -d '{"email":"admin@example.com","password":"admin123"}'

# Question Service
curl http://localhost:8085/questions/fields

# NLP Service
curl http://localhost:5000/nlp/keywords -d '{"text":"Spring Boot framework","topN":3}'
```

---

## Appendix

### Environment Variables Summary

| Variable | Default Value | Description |
|----------|---------------|-------------|
| `base_url` | `http://localhost:8080` | API Gateway entry point |
| `access_token` | (dynamic) | JWT access token from login |
| `refresh_token` | (dynamic) | JWT refresh token from login |
| `user_id` | (dynamic) | Current user ID from login |

### HTTP Status Codes

| Code | Meaning | When It Occurs |
|------|---------|----------------|
| 200 | OK | Successful GET/PUT request |
| 201 | Created | Successful POST (create) request |
| 204 | No Content | Successful DELETE request |
| 400 | Bad Request | Invalid request body or parameters |
| 401 | Unauthorized | Missing or invalid access token |
| 403 | Forbidden | User lacks required role/permission |
| 404 | Not Found | Resource does not exist |
| 500 | Internal Server Error | Server-side error (check logs) |

### Pagination Parameters

All list endpoints support pagination:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | integer | 0 | Page number (0-indexed) |
| `size` | integer | 20 | Number of items per page |
| `sort` | string | `id,asc` | Sort field and direction |

Example: `GET /questions?page=0&size=10&sort=id,desc`

### Role-Based Access Control

| Role | Permissions |
|------|-------------|
| `USER` | Read own profile, take exams, view public content |
| `ADMIN` | All USER permissions + Create/Update/Delete resources |

---

## Support

For issues or questions:
1. Check service logs: `docker logs interview-<service-name>`
2. Verify services are running: `docker ps`
3. Check Eureka dashboard: `http://localhost:8761`
4. Review this documentation
5. Contact development team

---

**Last Updated**: January 2024
**Version**: 1.0
