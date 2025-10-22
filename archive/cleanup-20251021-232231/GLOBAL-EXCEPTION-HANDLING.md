# Global Exception Handling - RFC 7807 Problem Details

## Overview

All services in this microservices architecture now implement **RFC 7807 Problem Details** standard for consistent, detailed error responses.

## Services Covered

✅ **Auth Service** (`AUTH_*` error codes)  
✅ **User Service** (`USER_*` error codes)  
✅ **Question Service** (`QUESTION_*` error codes)  
✅ **Exam Service** (`EXAM_*` error codes)  
✅ **Career Service** (`CAREER_*` error codes)  
✅ **News Service** (`NEWS_*` error codes)

---

## Error Response Format

All error responses follow this consistent structure:

```json
{
  "type": "https://errors.abc.com/ERROR_CODE",
  "title": "Error Title",
  "status": 404,
  "detail": "Detailed human-readable explanation",
  "instance": "/api/v1/endpoint",
  "errorCode": "ERROR_CODE",
  "traceId": "d6b87c15-5bc5-43f0-bb57-da7b29e85e12",
  "timestamp": "2025-10-10T10:25:33.514Z",
  "details": {
    "fieldName": "validation error message"
  }
}
```

### Fields

| Field | Type | Description |
|-------|------|-------------|
| `type` | string | URI identifying the problem type |
| `title` | string | Short, human-readable summary |
| `status` | integer | HTTP status code |
| `detail` | string | Detailed explanation of the error |
| `instance` | string | URI of the specific occurrence |
| `errorCode` | string | Application-specific error code |
| `traceId` | string | UUID for tracking/debugging |
| `timestamp` | string | ISO 8601 timestamp |
| `details` | object | Additional context (optional, e.g., validation errors) |

---

## Error Codes by Service

### 🔐 Auth Service

| Error Code | HTTP Status | Description |
|------------|-------------|-------------|
| `ROLE_NOT_FOUND` | 404 | Role does not exist |
| `USER_NOT_FOUND` | 404 | User does not exist |
| `EMAIL_ALREADY_EXISTS` | 409 | Email is already registered |
| `INVALID_CREDENTIALS` | 401 | Incorrect email or password |
| `TOKEN_EXPIRED` | 401 | JWT token has expired |
| `VALIDATION_FAILED` | 400 | Input validation failed |
| `ACCESS_DENIED` | 403 | Insufficient permissions |

### 👤 User Service

| Error Code | HTTP Status | Description |
|------------|-------------|-------------|
| `USER_NOT_FOUND` | 404 | User does not exist |
| `EMAIL_ALREADY_EXISTS` | 409 | Email is already in use |
| `INVALID_REQUEST` | 400 | Invalid request parameters |
| `BUSINESS_ERROR` | 400 | Business rule violation |
| `VALIDATION_FAILED` | 400 | Input validation failed |
| `ACCESS_DENIED` | 403 | Insufficient permissions |

### ❓ Question Service

| Error Code | HTTP Status | Description |
|------------|-------------|-------------|
| `QUESTION_NOT_FOUND` | 404 | Question does not exist |
| `QUESTION_ALREADY_EXISTS` | 409 | Question already exists |
| `INVALID_REQUEST` | 400 | Invalid request parameters |
| `BUSINESS_ERROR` | 400 | Business rule violation |
| `VALIDATION_FAILED` | 400 | Input validation failed |
| `ACCESS_DENIED` | 403 | Insufficient permissions |

### 📝 Exam Service

| Error Code | HTTP Status | Description |
|------------|-------------|-------------|
| `EXAM_NOT_FOUND` | 404 | Exam does not exist |
| `EXAM_ALREADY_EXISTS` | 409 | Exam already exists |
| `INVALID_REQUEST` | 400 | Invalid request parameters |
| `BUSINESS_ERROR` | 400 | Business rule violation |
| `VALIDATION_FAILED` | 400 | Input validation failed |
| `ACCESS_DENIED` | 403 | Insufficient permissions |

### 💼 Career Service

| Error Code | HTTP Status | Description |
|------------|-------------|-------------|
| `CAREER_NOT_FOUND` | 404 | Career opportunity not found |
| `CAREER_ALREADY_EXISTS` | 409 | Career opportunity already exists |
| `INVALID_REQUEST` | 400 | Invalid request parameters |
| `BUSINESS_ERROR` | 400 | Business rule violation |
| `VALIDATION_FAILED` | 400 | Input validation failed |
| `ACCESS_DENIED` | 403 | Insufficient permissions |

### 📰 News Service

| Error Code | HTTP Status | Description |
|------------|-------------|-------------|
| `NEWS_NOT_FOUND` | 404 | News article not found |
| `NEWS_ALREADY_EXISTS` | 409 | News article already exists |
| `INVALID_REQUEST` | 400 | Invalid request parameters |
| `BUSINESS_ERROR` | 400 | Business rule violation |
| `VALIDATION_FAILED` | 400 | Input validation failed |
| `ACCESS_DENIED` | 403 | Insufficient permissions |

### 🌐 Common Error Codes (All Services)

| Error Code | HTTP Status | Description |
|------------|-------------|-------------|
| `VALIDATION_FAILED` | 400 | Input validation failed |
| `INVALID_ARGUMENT` | 400 | Invalid method argument |
| `INVALID_REQUEST` | 400 | Invalid request |
| `ACCESS_DENIED` | 403 | Insufficient permissions |
| `ILLEGAL_STATE` | 409 | Illegal state transition |
| `RUNTIME_ERROR` | 400 | Runtime error |
| `INTERNAL_SERVER_ERROR` | 500 | Unexpected server error |

---

## Example Error Responses

### 1. Resource Not Found

**Request:** `GET /api/v1/users/9999`

**Response (404):**
```json
{
  "type": "https://errors.abc.com/USER_NOT_FOUND",
  "title": "Resource Not Found",
  "status": 404,
  "detail": "User not found with id: '9999'",
  "instance": "/api/v1/users/9999",
  "errorCode": "USER_NOT_FOUND",
  "traceId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "timestamp": "2025-10-10T10:25:33.514Z"
}
```

### 2. Validation Failed

**Request:** `POST /api/v1/auth/register`
```json
{
  "email": "invalid-email",
  "password": "123"
}
```

**Response (400):**
```json
{
  "type": "https://errors.abc.com/VALIDATION_FAILED",
  "title": "Validation Failed",
  "status": 400,
  "detail": "Input validation failed. Please check the provided fields.",
  "instance": "/api/v1/auth/register",
  "errorCode": "VALIDATION_FAILED",
  "traceId": "b2c3d4e5-f6a7-8901-bcde-f12345678901",
  "timestamp": "2025-10-10T10:26:15.234Z",
  "details": {
    "email": "must be a well-formed email address",
    "password": "size must be between 6 and 50"
  }
}
```

### 3. Duplicate Resource

**Request:** `POST /api/v1/auth/register`
```json
{
  "email": "admin@example.com",
  "password": "password123",
  "roleName": "USER"
}
```

**Response (409):**
```json
{
  "type": "https://errors.abc.com/EMAIL_ALREADY_EXISTS",
  "title": "Duplicate Resource",
  "status": 409,
  "detail": "User already exists with email: 'admin@example.com'",
  "instance": "/api/v1/auth/register",
  "errorCode": "EMAIL_ALREADY_EXISTS",
  "traceId": "c3d4e5f6-a7b8-9012-cdef-123456789012",
  "timestamp": "2025-10-10T10:27:42.156Z"
}
```

### 4. Invalid Credentials

**Request:** `POST /api/v1/auth/login`
```json
{
  "email": "user@example.com",
  "password": "wrongpassword"
}
```

**Response (401):**
```json
{
  "type": "https://errors.abc.com/INVALID_CREDENTIALS",
  "title": "Invalid Credentials",
  "status": 401,
  "detail": "Invalid email or password",
  "instance": "/api/v1/auth/login",
  "errorCode": "INVALID_CREDENTIALS",
  "traceId": "d4e5f6a7-b8c9-0123-def1-234567890123",
  "timestamp": "2025-10-10T10:28:19.987Z"
}
```

### 5. Access Denied

**Request:** `DELETE /api/v1/users/1` (as regular user)

**Response (403):**
```json
{
  "type": "https://errors.abc.com/ACCESS_DENIED",
  "title": "Access Denied",
  "status": 403,
  "detail": "You don't have permission to access this resource",
  "instance": "/api/v1/users/1",
  "errorCode": "ACCESS_DENIED",
  "traceId": "e5f6a7b8-c9d0-1234-ef12-345678901234",
  "timestamp": "2025-10-10T10:29:05.321Z"
}
```

---

## Benefits for Clients

### 1. **Consistent Structure**
All services return errors in the same format, simplifying client-side error handling.

### 2. **Machine-Readable**
`errorCode` field allows programmatic error handling:

```javascript
// Frontend error handling example
if (error.errorCode === 'USER_NOT_FOUND') {
  showNotification('User does not exist', 'error');
} else if (error.errorCode === 'VALIDATION_FAILED') {
  showValidationErrors(error.details);
}
```

### 3. **Human-Readable**
`title` and `detail` fields provide clear messages for users.

### 4. **Traceable**
`traceId` enables quick debugging and log correlation.

### 5. **RFC 7807 Compliant**
Industry-standard format used by major APIs (Stripe, Twilio, etc.).

---

## Integration with Postman

The Postman collection (`INTERVIEW_APIS_COMPLETE.postman_collection.json`) includes:

1. ✅ **Tests for error scenarios**
2. ✅ **Automatic parsing of error responses**
3. ✅ **Display of `traceId` for debugging**
4. ✅ **Validation of error structure**

Example Postman test:
```javascript
pm.test("Error response has RFC 7807 structure", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData).to.have.property('type');
    pm.expect(jsonData).to.have.property('title');
    pm.expect(jsonData).to.have.property('status');
    pm.expect(jsonData).to.have.property('detail');
    pm.expect(jsonData).to.have.property('errorCode');
    pm.expect(jsonData).to.have.property('traceId');
});
```

---

## Implementation Details

Each service now includes:

```
service/
└── src/main/java/com/abc/{service}/exception/
    ├── ErrorResponse.java              # RFC 7807 structure
    ├── GlobalExceptionHandler.java     # Centralized exception handling
    ├── ResourceNotFoundException.java  # Custom exceptions
    ├── DuplicateResourceException.java
    ├── InvalidRequestException.java
    └── BusinessException.java
```

### Exception Handler Priority

1. **Specific Exceptions** (highest priority)
   - `ResourceNotFoundException`
   - `DuplicateResourceException`
   - `InvalidRequestException`
   - `BusinessException`

2. **Framework Exceptions**
   - `MethodArgumentNotValidException`
   - `AccessDeniedException`

3. **Generic Exceptions**
   - `IllegalArgumentException`
   - `IllegalStateException`
   - `RuntimeException`

4. **Fallback** (lowest priority)
   - `Exception` (catches all unhandled exceptions)

---

## Next Steps

### For Developers:
1. Use custom exceptions in service layer:
   ```java
   throw new ResourceNotFoundException("User", "id", userId);
   throw new DuplicateResourceException("User", "email", email);
   throw new InvalidRequestException("Invalid input");
   throw new BusinessException("Cannot delete active user", "ACTIVE_USER_DELETION");
   ```

2. Avoid generic exceptions:
   ```java
   // ❌ BAD
   throw new RuntimeException("User not found");
   
   // ✅ GOOD
   throw new ResourceNotFoundException("User", "id", userId);
   ```

### For Frontend Developers:
1. Parse `errorCode` for programmatic handling
2. Use `detail` for user-facing messages
3. Log `traceId` for support tickets
4. Display `details` for validation errors

---

## Status

✅ **Implementation Complete** - All 6 services now have global exception handlers  
✅ **RFC 7807 Compliant** - Standard problem details format  
✅ **Consistent Error Codes** - Documented and categorized  
✅ **Client-Friendly** - Easy to parse and handle  
✅ **Traceable** - Unique trace IDs for debugging  

**Last Updated:** 2025-10-10



