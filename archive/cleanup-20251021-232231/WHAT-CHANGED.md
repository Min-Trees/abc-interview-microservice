# What Changed - Exception Handling Implementation

## TL;DR

✅ Tất cả 6 services (Auth, User, Question, Exam, Career, News) giờ đã có **Global Exception Handler** trả về lỗi chi tiết theo chuẩn **RFC 7807**.

---

## What You Asked For

> "áp dụng cho tất cả lỗi của tất cả service để phía client dễ dàng sử dụng và gắn api"

✅ **Done!** Tất cả services giờ trả về lỗi với format nhất quán, dễ parse cho client.

---

## Before (Old Error Format) ❌

```json
{
  "timestamp": "2025-10-10T10:25:33.514Z",
  "status": 404,
  "error": "Not Found",
  "message": "User not found",
  "path": "/api/v1/users/999"
}
```

**Problems:**
- Không có error code để parse
- Không có trace ID để debug
- Format không nhất quán giữa các service
- Khó xử lý ở frontend

---

## After (New Error Format) ✅

```json
{
  "type": "https://errors.abc.com/USER_NOT_FOUND",
  "title": "Resource Not Found",
  "status": 404,
  "detail": "User not found with id: '999'",
  "instance": "/api/v1/users/999",
  "errorCode": "USER_NOT_FOUND",
  "traceId": "d6b87c15-5bc5-43f0-bb57-da7b29e85e12",
  "timestamp": "2025-10-10T10:25:33.514Z"
}
```

**Benefits:**
✅ Có `errorCode` để xử lý programmatic  
✅ Có `traceId` để debug dễ dàng  
✅ Format nhất quán RFC 7807  
✅ Chi tiết và dễ hiểu  

---

## Files Created

### Exception Handlers (per service)
```
<service>/src/main/java/com/abc/<service>/exception/
├── ErrorResponse.java              # RFC 7807 structure
├── GlobalExceptionHandler.java     # Catch all exceptions
├── ResourceNotFoundException.java  # 404 errors
├── DuplicateResourceException.java # 409 conflicts
├── InvalidRequestException.java    # 400 bad requests
└── BusinessException.java          # Business rules
```

### Documentation
- `GLOBAL-EXCEPTION-HANDLING.md` - Chi tiết đầy đủ
- `ERROR-CODES.md` - Danh sách error codes
- `EXCEPTION-HANDLING-COMPLETE.md` - Implementation summary
- `REBUILD-AND-TEST.md` - Hướng dẫn rebuild & test
- `WHAT-CHANGED.md` - File này

---

## Error Codes by Service

| Service | Prefix | Examples |
|---------|--------|----------|
| Auth | `AUTH_*`, `ROLE_*` | `ROLE_NOT_FOUND`, `INVALID_CREDENTIALS` |
| User | `USER_*` | `USER_NOT_FOUND`, `EMAIL_ALREADY_EXISTS` |
| Question | `QUESTION_*` | `QUESTION_NOT_FOUND` |
| Exam | `EXAM_*` | `EXAM_NOT_FOUND` |
| Career | `CAREER_*` | `CAREER_NOT_FOUND` |
| News | `NEWS_*` | `NEWS_NOT_FOUND` |
| Common | `*` | `VALIDATION_FAILED`, `ACCESS_DENIED` |

**Full list:** See `ERROR-CODES.md`

---

## How to Use (Frontend)

### Parse Error Code
```javascript
// Easy to handle programmatically
try {
  const response = await api.post('/api/v1/auth/register', data);
} catch (error) {
  const err = error.response.data;
  
  switch(err.errorCode) {
    case 'EMAIL_ALREADY_EXISTS':
      showError('Email đã được đăng ký');
      break;
    case 'ROLE_NOT_FOUND':
      showError('Role không tồn tại');
      break;
    case 'VALIDATION_FAILED':
      showValidationErrors(err.details);
      break;
    default:
      showError(err.detail);
  }
  
  // Log for support
  console.error('TraceId:', err.traceId);
}
```

### Display Validation Errors
```javascript
// For VALIDATION_FAILED errors
if (err.errorCode === 'VALIDATION_FAILED') {
  Object.keys(err.details).forEach(field => {
    showFieldError(field, err.details[field]);
  });
}

// Example err.details:
// {
//   "email": "must be a well-formed email address",
//   "password": "size must be between 6 and 50"
// }
```

---

## Example Error Scenarios

### 1️⃣ User Not Found (404)
```
GET /api/v1/users/999999
→ USER_NOT_FOUND
```

### 2️⃣ Email Already Exists (409)
```
POST /api/v1/auth/register
{"email": "admin@example.com", ...}
→ EMAIL_ALREADY_EXISTS
```

### 3️⃣ Invalid Role (404)
```
POST /api/v1/auth/register
{"roleName": "INVALID_ROLE", ...}
→ ROLE_NOT_FOUND
```

### 4️⃣ Wrong Password (401)
```
POST /api/v1/auth/login
{"password": "wrongpassword"}
→ INVALID_CREDENTIALS
```

### 5️⃣ Validation Failed (400)
```
POST /api/v1/auth/register
{"email": "invalid-email", ...}
→ VALIDATION_FAILED (with details)
```

### 6️⃣ Permission Denied (403)
```
DELETE /api/v1/users/1 (as regular user)
→ ACCESS_DENIED
```

---

## What You Need to Do

### 1. Rebuild Services
```powershell
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### 2. Test with Postman
- Import `INTERVIEW_APIS_COMPLETE.postman_collection.json`
- Test error scenarios
- Verify RFC 7807 format

### 3. Update Frontend
- Parse `errorCode` field
- Display `detail` messages
- Show `details` for validation
- Log `traceId` for support

---

## Files to Read

1. **Quick Overview:** `WHAT-CHANGED.md` ← You are here
2. **Complete Guide:** `GLOBAL-EXCEPTION-HANDLING.md`
3. **Error Codes:** `ERROR-CODES.md`
4. **How to Test:** `REBUILD-AND-TEST.md`
5. **Implementation Details:** `EXCEPTION-HANDLING-COMPLETE.md`

---

## Status

| Item | Status |
|------|--------|
| Auth Service | ✅ Done |
| User Service | ✅ Done |
| Question Service | ✅ Done |
| Exam Service | ✅ Done |
| Career Service | ✅ Done |
| News Service | ✅ Done |
| Documentation | ✅ Done |
| **Ready to Test** | ✅ Yes |

---

## Benefits Summary

### For You (Backend)
✅ Consistent error handling  
✅ Easy to debug with trace IDs  
✅ Professional error responses  
✅ Follows industry standards (RFC 7807)  

### For Frontend Team
✅ Predictable error format  
✅ Machine-readable error codes  
✅ Easy to display validation errors  
✅ Better UX with clear messages  

### For Support/DevOps
✅ Trace IDs for log correlation  
✅ Consistent logging  
✅ Better debugging  

---

## Quick Test

After rebuild, test this:

```powershell
# Test 404 error
curl http://localhost:8222/api/v1/users/999999 `
  -H "Authorization: Bearer YOUR_TOKEN"

# Expected: RFC 7807 format with errorCode "USER_NOT_FOUND"
```

---

**Ready?** 🚀  
Read: `REBUILD-AND-TEST.md` for step-by-step instructions.



