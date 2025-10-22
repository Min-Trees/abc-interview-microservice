# Rebuild & Test Guide

## Overview

After implementing global exception handlers across all services, you need to rebuild and test the system.

---

## Step 1: Stop Current Services

```powershell
docker-compose down
```

Expected output:
```
[+] Running 11/11
 ✔ Container interview-gateway-service      Removed
 ✔ Container interview-news-service         Removed
 ✔ Container interview-career-service       Removed
 ✔ Container interview-exam-service         Removed
 ✔ Container interview-question-service     Removed
 ✔ Container interview-user-service         Removed
 ✔ Container interview-auth-service         Removed
 ✔ Container interview-discovery-service    Removed
 ✔ Container interview-config-service       Removed
 ✔ Container interview-postgres             Removed
 ✔ Network interview-network                Removed
```

---

## Step 2: Clean Build (Rebuild All Services)

```powershell
docker-compose build --no-cache
```

This will:
- Build all 9 services from scratch
- Include new exception handling code
- Take 3-5 minutes

**Services being rebuilt:**
1. ✅ config-service
2. ✅ discovery-service
3. ✅ auth-service (with new exception handlers)
4. ✅ user-service (with new exception handlers)
5. ✅ question-service (with new exception handlers)
6. ✅ exam-service (with new exception handlers)
7. ✅ career-service (with new exception handlers)
8. ✅ news-service (with new exception handlers)
9. ✅ gateway-service

---

## Step 3: Start All Services

```powershell
docker-compose up -d
```

Wait 30-60 seconds for all services to start.

---

## Step 4: Verify Services Are Running

```powershell
docker-compose ps
```

Expected output:
```
NAME                             STATUS
interview-auth-service           Up
interview-career-service         Up
interview-config-service         Up
interview-discovery-service      Up
interview-exam-service           Up
interview-gateway-service        Up
interview-news-service           Up
interview-postgres               Up
interview-question-service       Up
interview-user-service           Up
```

**All services should show "Up" status.**

---

## Step 5: Check Service Logs

### Check for errors:
```powershell
docker-compose logs auth-service | Select-String "ERROR"
docker-compose logs user-service | Select-String "ERROR"
docker-compose logs question-service | Select-String "ERROR"
docker-compose logs exam-service | Select-String "ERROR"
docker-compose logs career-service | Select-String "ERROR"
docker-compose logs news-service | Select-String "ERROR"
```

**Expected:** No critical errors. Some "ERROR" logs during startup are normal.

### Check exception handler registration:
```powershell
docker-compose logs auth-service | Select-String "GlobalExceptionHandler"
```

**Expected:** Should see log indicating `@RestControllerAdvice` component registered.

---

## Step 6: Test Exception Handling

### A. Test with Postman

1. **Import Collection:**
   - Open Postman
   - Import `INTERVIEW_APIS_COMPLETE.postman_collection.json`

2. **Test Error Scenarios:**

#### Test 1: Resource Not Found (404)
```
GET http://localhost:8222/api/v1/users/999999
Authorization: Bearer <token>
```

**Expected Response:**
```json
{
  "type": "https://errors.abc.com/USER_NOT_FOUND",
  "title": "Resource Not Found",
  "status": 404,
  "detail": "User not found with id: '999999'",
  "instance": "/api/v1/users/999999",
  "errorCode": "USER_NOT_FOUND",
  "traceId": "uuid-here",
  "timestamp": "2025-10-10T10:25:33.514Z"
}
```

#### Test 2: Duplicate Resource (409)
```
POST http://localhost:8222/api/v1/auth/register
Content-Type: application/json

{
  "email": "admin@example.com",
  "password": "password123",
  "roleName": "USER"
}
```

**Expected Response:**
```json
{
  "type": "https://errors.abc.com/EMAIL_ALREADY_EXISTS",
  "title": "Duplicate Resource",
  "status": 409,
  "detail": "User already exists with email: 'admin@example.com'",
  "instance": "/api/v1/auth/register",
  "errorCode": "EMAIL_ALREADY_EXISTS",
  "traceId": "uuid-here",
  "timestamp": "2025-10-10T10:25:33.514Z"
}
```

#### Test 3: Validation Failed (400)
```
POST http://localhost:8222/api/v1/auth/register
Content-Type: application/json

{
  "email": "invalid-email",
  "password": "123",
  "roleName": "USER"
}
```

**Expected Response:**
```json
{
  "type": "https://errors.abc.com/VALIDATION_FAILED",
  "title": "Validation Failed",
  "status": 400,
  "detail": "Input validation failed. Please check the provided fields.",
  "instance": "/api/v1/auth/register",
  "errorCode": "VALIDATION_FAILED",
  "traceId": "uuid-here",
  "timestamp": "2025-10-10T10:25:33.514Z",
  "details": {
    "email": "must be a well-formed email address",
    "password": "size must be between 6 and 50"
  }
}
```

#### Test 4: Invalid Credentials (401)
```
POST http://localhost:8222/api/v1/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "wrongpassword"
}
```

**Expected Response:**
```json
{
  "type": "https://errors.abc.com/INVALID_CREDENTIALS",
  "title": "Invalid Credentials",
  "status": 401,
  "detail": "Invalid email or password",
  "instance": "/api/v1/auth/login",
  "errorCode": "INVALID_CREDENTIALS",
  "traceId": "uuid-here",
  "timestamp": "2025-10-10T10:25:33.514Z"
}
```

#### Test 5: Role Not Found (404)
```
POST http://localhost:8222/api/v1/auth/register
Content-Type: application/json

{
  "email": "newuser@example.com",
  "password": "password123",
  "roleName": "INVALID_ROLE"
}
```

**Expected Response:**
```json
{
  "type": "https://errors.abc.com/ROLE_NOT_FOUND",
  "title": "Role Not Found",
  "status": 404,
  "detail": "Role 'INVALID_ROLE' not found",
  "instance": "/api/v1/auth/register",
  "errorCode": "ROLE_NOT_FOUND",
  "traceId": "uuid-here",
  "timestamp": "2025-10-10T10:25:33.514Z"
}
```

#### Test 6: Access Denied (403)
```
DELETE http://localhost:8222/api/v1/users/1
Authorization: Bearer <regular-user-token>
```

**Expected Response:**
```json
{
  "type": "https://errors.abc.com/ACCESS_DENIED",
  "title": "Access Denied",
  "status": 403,
  "detail": "You don't have permission to access this resource",
  "instance": "/api/v1/users/1",
  "errorCode": "ACCESS_DENIED",
  "traceId": "uuid-here",
  "timestamp": "2025-10-10T10:25:33.514Z"
}
```

### B. Test with cURL

```powershell
# Test 404 Not Found
curl -X GET http://localhost:8222/api/v1/users/999999 `
  -H "Authorization: Bearer YOUR_TOKEN" | ConvertFrom-Json

# Test 409 Conflict
curl -X POST http://localhost:8222/api/v1/auth/register `
  -H "Content-Type: application/json" `
  -d '{"email":"admin@example.com","password":"password123","roleName":"USER"}' | ConvertFrom-Json

# Test 401 Unauthorized
curl -X POST http://localhost:8222/api/v1/auth/login `
  -H "Content-Type: application/json" `
  -d '{"email":"user@example.com","password":"wrongpassword"}' | ConvertFrom-Json
```

---

## Step 7: Verify All Error Fields

For each error response, verify it contains:

✅ `type` - URI with error code  
✅ `title` - Human-readable title  
✅ `status` - HTTP status code  
✅ `detail` - Detailed message  
✅ `instance` - Request URI  
✅ `errorCode` - Machine-readable code  
✅ `traceId` - UUID for tracking  
✅ `timestamp` - ISO 8601 format  
✅ `details` (optional) - Validation errors  

---

## Step 8: Test Each Service

### Auth Service
- ✅ Role not found
- ✅ Email already exists
- ✅ Invalid credentials
- ✅ Token expired

### User Service
- ✅ User not found
- ✅ Validation failed
- ✅ Access denied

### Question Service
- ✅ Question not found
- ✅ Question already exists
- ✅ Invalid request

### Exam Service
- ✅ Exam not found
- ✅ Exam already exists
- ✅ Business rule violation

### Career Service
- ✅ Career not found
- ✅ Career already exists
- ✅ Invalid request

### News Service
- ✅ News not found
- ✅ News already exists
- ✅ Invalid request

---

## Common Issues & Solutions

### Issue 1: Service Won't Start
```
ERROR: Service 'auth-service' failed to build
```

**Solution:**
```powershell
# Check Java files for syntax errors
docker-compose logs auth-service

# Rebuild specific service
docker-compose build auth-service --no-cache
docker-compose up -d auth-service
```

### Issue 2: 500 Internal Server Error Instead of Custom Error
```json
{
  "timestamp": "2025-10-10T10:25:33.514Z",
  "status": 500,
  "error": "Internal Server Error"
}
```

**Cause:** Exception handler not registered or exception not caught.

**Solution:**
```powershell
# Check if GlobalExceptionHandler is registered
docker-compose logs auth-service | Select-String "GlobalExceptionHandler"

# Verify @RestControllerAdvice annotation is present
# Check exception package is scanned by Spring Boot
```

### Issue 3: Old Error Format Still Showing

**Cause:** Old service still running (not rebuilt).

**Solution:**
```powershell
# Force rebuild
docker-compose down
docker-compose build --no-cache auth-service
docker-compose up -d
```

### Issue 4: traceId is Missing

**Cause:** `ErrorResponse.builder()` not used properly.

**Solution:** Verify `GlobalExceptionHandler` uses `ErrorResponse.builder()` with all fields.

---

## Validation Checklist

- [ ] All services built successfully
- [ ] All services are running (docker-compose ps)
- [ ] No critical errors in logs
- [ ] 404 errors return RFC 7807 format
- [ ] 409 errors return RFC 7807 format
- [ ] 400 validation errors include `details` field
- [ ] 401 auth errors return proper error codes
- [ ] 403 permission errors work correctly
- [ ] All error responses include `traceId`
- [ ] All error responses include `timestamp`
- [ ] Error codes match documentation
- [ ] Postman tests pass

---

## Success Criteria

✅ **All services start without errors**  
✅ **All error responses follow RFC 7807 format**  
✅ **Error codes are consistent and documented**  
✅ **traceId is unique for each error**  
✅ **Validation errors include field details**  
✅ **Postman tests pass for all error scenarios**  

---

## Next Steps After Testing

1. **Update Frontend:**
   - Parse `errorCode` field
   - Display `detail` messages
   - Show `details` for validation
   - Log `traceId` for support

2. **Update Documentation:**
   - Share `ERROR-CODES.md` with frontend team
   - Update API documentation
   - Create error handling guidelines

3. **Monitor Production:**
   - Track error patterns by `errorCode`
   - Use `traceId` for debugging
   - Alert on high error rates

---

## Quick Reference

| Command | Purpose |
|---------|---------|
| `docker-compose down` | Stop all services |
| `docker-compose build --no-cache` | Rebuild all services |
| `docker-compose up -d` | Start all services |
| `docker-compose ps` | Check service status |
| `docker-compose logs <service>` | View service logs |

---

**Ready to rebuild?**
```powershell
# Full rebuild process
docker-compose down
docker-compose build --no-cache
docker-compose up -d

# Wait 60 seconds, then test
Start-Sleep -Seconds 60
docker-compose ps
```

Good luck! 🚀



